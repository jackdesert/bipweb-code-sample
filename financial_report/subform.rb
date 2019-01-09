module FinancialReport
  module Subform
    # include this module in any Section that pulls data from a subform

    BASE_SIZE      = FinancialReport::Section::BASE_SIZE
    SUBTITLE_SIZE = FinancialReport::Section::SUBTITLE_SIZE

    INDENT_A =  4 * SUBTITLE_SIZE
    INDENT_B =  3 * SUBTITLE_SIZE
    INDENT_C = 10 * SUBTITLE_SIZE

    TABLE_CELL_PADDING = [0.05 * BASE_SIZE, 0.6 * BASE_SIZE]
    TABLE_SPACE_BELOW  = 0.5 * BASE_SIZE

    DESCRIPTION_TOP_AND_BOTTOM_PADDING = 0.4 * BASE_SIZE

    def datum_value
      model.subform_datum_value(outer_key)
    end

    def capabilities
      # No capabilities
      {}
    end

    def notes
      # no notes
      {}
    end

    def render_title
      # Do not render this section at all unless there is data to show

      return unless able_to_render?
      super
    end

    def render_subtotal
      # Do not render this section at all unless there is data to show

      return unless able_to_render?
      super
    end

    def render_subform_data
      return unless able_to_render?

      data_for_multiple_forms = JSON.parse(datum_value)

      numbered = false

      data_for_multiple_forms.each_with_index do |row_data_for_one_form, index|
        friendly_hash = row_data_to_friendly_hash(row_data_for_one_form)
        render_one_form(friendly_hash, index, numbered)
      end
    end

    def row_data_to_friendly_hash(row_data)
      hash = {}
      row_data.each do |row|
        key = row['key']
        value = row['value']
        hash[key] = value
      end

      types_data = hash[type_key]
      item_types = item_types_from_json(types_data)

      hash[type_key] = item_types

      hash
    end


    def initialize_table_data
      return if @table_initialized
      @table_initialized = true

      self.table_data = []
      # table_data << ['Behavior', 'Frequency', '', 'Duration', '', '', '', '']
    end

    def render_colloquial_equation
      style = { borders: [],

                padding: TABLE_CELL_PADDING,

                # There is a bug in prawn-table that breaks when setting width
                # https://github.com/prawnpdf/prawn-table/issues/54
                # width: document.bounds.width
              }

      striped_indices = (0..table_data.count).to_a.select{ |i| i.even? }

      document.table(table_data, cell_style: style) do
        striped_indices.each do |i|
          row(i).background_color = FinancialReport::Section::STRIPE_COLOR
        end
      end

      document.move_down TABLE_SPACE_BELOW
    end

    def lettered_index(index)
      'ABCDEFGHI'[index]
    end
  end
end
