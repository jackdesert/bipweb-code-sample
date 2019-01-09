require 'prawn/measurement_extensions'

module FinancialReport
  class Section
    class EnumKeyNotFoundError < Exception; end
    include FinancialReport::Utils

    # Constants used when displaying colloquial equation
    EQUALS   = '='
    MULTIPLY = 'x'
    DIVIDE   = '÷'
    SPACE    = ' '
    SLASH    = '/'

    METHOD_REGEX = '[a-z_]+'
    VALUE_REGEX = /value\(:(#{METHOD_REGEX})\)/


    NOT_APPLICABLE = 'none'
    EMPTY_STRING   = ''
    LINE_FEED      = "\n"

    # List of fonts available without needing to embed:
    # http://www.enfocus.com/manuals/ReferenceGuide/PP/10/enUS/en-us/concept/c_aa1140975.html
    ROMAN        = 'Times-Roman'
    ITALIC       = 'Times-Italic'
    BOLD         = 'Times-Bold'
    BOLD_ITALIC  = 'Times-BoldItalic'

    SANS              = 'Helvetica'
    SANS_OBLIQUE      = 'Helvetica-Oblique'
    SANS_BOLD         = 'Helvetica-Bold'
    SANS_BOLD_OBLIQUE = 'Helvetica-BoldOblique'

    BASE_SIZE              =  4.0.mm
    TITLE_SIZE             =  2.8 * BASE_SIZE
    TITLE_TAG_SIZE         =  1.70 * BASE_SIZE
    SUBTITLE_SIZE          =  1.25 * BASE_SIZE
    SUBTITLE_HR_THICKNESS  =  0.15 * BASE_SIZE
    VALUE_BOX_PADDING      =  [0.30 * BASE_SIZE, 0.50 * BASE_SIZE]
    SPACE_BETWEEN_SECTIONS =  2.00 * BASE_SIZE

    CAPABILITIES_FIRST_COL_WIDTH  =  8.0 * BASE_SIZE
    CAPABILITIES_SECOND_COL_WIDTH = 25.0 * BASE_SIZE

    V_SPACE_BETWEEN_DETAILS       = 0.5 * BASE_SIZE

    STRIPE_COLOR = 'EEEEEE'
    SUBTOTAL_BOX_COLOR = '7E1C00'  #'CC5555'
    GRAND_TOTAL_BOX_COLOR = '008400'


    attr_reader :model, :document, :start_on_new_page

    def initialize(model, document, start_on_new_page)
      @model = model
      @document = document
      @start_on_new_page = start_on_new_page
    end

    def title
      raise ArgumentError, 'Expected title to be subclassed'
    end

    def capabilities
      {}
    end

    def notes
      {}
    end

    def subtotal_key
      raise ArgumentError, 'Expected subtotal_key to be subclassed'
    end

    def render
      return unless able_to_render?

      set_defaults
      render_title
      render_subform_data
      render_capabilities
      render_notes
      render_subtotal
    end

    def footer(page_number)
      y = -6.mm
      document.draw_text "Jan 16, 2017 Service Plan for #{model.person.full_name}",
                        at: [0, y]


      document.draw_text page_number,
                      at: [129.mm, y]

    end

    def able_to_render?
      # Override in subclasses.
      # For example, if there is no data
      true
    end

    private

    def text_in_place(content)
      # text without moving down
      previous_y = document.cursor
      document.text content

      distance_moved = previous_y - document.cursor
      document.move_up distance_moved
    end

    def set_defaults
      if start_on_new_page
        document.start_new_page
      else
        document.move_down SPACE_BETWEEN_SECTIONS
      end

      document.font ROMAN
      document.font_size BASE_SIZE
    end

    def render_title
      document.font SANS_BOLD_OBLIQUE do
        document.text title, size: TITLE_SIZE
      end
      document.move_up 1 * SUBTITLE_SIZE
    end

    def render_subtitle(text)
      document.move_down 0.5 * SUBTITLE_SIZE
      document.font BOLD do
        document.text text, size: SUBTITLE_SIZE
      end

      horizontal_rule
    end

    def horizontal_rule
      document.move_up 0.2 * SUBTITLE_SIZE
      document.line_width SUBTITLE_HR_THICKNESS
      document.stroke_horizontal_rule
      document.move_down 0.4 * SUBTITLE_SIZE
    end

    def render_subform_data
      # Override in subclasses if there is subform data
    end

    def render_capabilities
      return if capabilities.empty?

      render_subtitle('Capabilities')
      capabilities.each do |label, person_datum_key|

        # TODO Update this to allow a Financial::Report to be run on an SSP
        # instead of always showing current values
        datum = model.person.person_data.find_by(key: person_datum_key)
        json_value = datum.try!(:value)

        if datum.nil? && Rails.env.development? && PersonDatum.where(key: person_datum_key).empty?
          raise ArgumentError, "No PersonDatum found with key '#{person_datum_key}'"
        end

        value = nil
        if json_value
          hash = JSON.parse(json_value)
          value = hash['key']

          next if value == NOT_APPLICABLE
        end

        # Display all fields in development
        if Rails.env.development? || value.present?
          y = document.cursor
          document.text "#{label}:"
          document.text_box capability_label(value),
                            at: [CAPABILITIES_FIRST_COL_WIDTH, y],
                            width: CAPABILITIES_SECOND_COL_WIDTH
        end
      end

    end

    def render_notes
      return if notes.empty?

      render_subtitle('Details')

      first_note = true
      notes.each do |label, person_datum_key|
        begin
        datum = display_datum(person_datum_key, FormDatum::STRING)

        if datum.nil? && Rails.env.development? && PersonDatum.where(key: person_datum_key).empty?
          raise ArgumentError, "No PersonDatum found with key '#{person_datum_key}'"
        end

        if Rails.env.development? || datum.present?
          text_box_with_label_and_move_down(label, datum.try!(:value) || SPACE, first_note)
          first_note = false
        end

        rescue
          binding.pry
        end

      end
    end


    def text_box_with_label_and_move_down(label, text, first_line=false)
      # source: https://stackoverflow.com/questions/15646058/prawn-pdf-how-to-get-the-height-of-a-text-box

      if !first_line
        document.move_down V_SPACE_BETWEEN_DETAILS
      end

      y_1 = document.cursor
      document.text "#{label}:"
      y_2 = document.cursor
      line_height = y_1 - y_2

      options = { at: [CAPABILITIES_FIRST_COL_WIDTH, y_1],
                  width: CAPABILITIES_SECOND_COL_WIDTH,
                  document: document }

      box = Prawn::Text::Box.new text, options

      # Render so we can query height
      box.render(dry_run: true)
      height = box.height

      box.render
      document.move_down height - line_height
    end

    def render_subtotal(custom_key=nil)
      key_to_use = custom_key || subtotal_key

      value = model.send(key_to_use)
      value_rounded = smallest_numeric(value)

      render_subtitle('Costs')
      render_colloquial_equation

      render_value_in_box('Subtotal', "#{value_rounded} min/day")
    end

    def render_value_in_box(label, value, box_color=SUBTOTAL_BOX_COLOR)
      # Renders a label (to left of box) with a colon,
      # Then renders value inside a box

      # Render a one-row, two-cell table
      row = ["#{label}:", value]
      data = [row]

      style = { padding: VALUE_BOX_PADDING,
                border_colors: box_color }



      # right-align table
      document.table(data, cell_style: style, position: :right) do
        # No border around left cell
        columns(0).borders = []
      end



    end

    def render_colloquial_equation
      # Note that SubFormSections have their own implementation of `render_colloquial_equation`
      equation = FinancialReport::Equation.new(model, subtotal_key).colloquial
      document.text equation
    end

    def capability_label(key)
      return EMPTY_STRING if key.nil?

      case key.to_sym
      when :independent
        'Independent'
      when :supervision
        'Supervision'
      when :limited_assistance
        'Some Assistance'
      when :extensive_assistance
        'More Assistance'
      when :total_dependence
        'Total Dependence'
      else
        raise EnumKeyNotFoundError, "key '#{key}' was unexpected"
      end
    end

    # This method may be duplicate of Person::FinancialValidatorSSP#display_datum
    def model_value(person_datum_key)
      model.value(person_datum_key)
    end

  end
end
