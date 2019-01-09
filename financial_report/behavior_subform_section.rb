module FinancialReport
  class BehaviorSubformSection < FinancialReport::Section
    include FinancialReport::Utils
    include FinancialReport::Subform

    BEHAVIORS_ENUM_ID = '924de6c2-2cdf-410b-9ee3-23efb5067465'


    attr_accessor :table_data

    def able_to_render?
      datum_value.present?
    end

    def title
      'Behaviors'
    end

    private


    def outer_key
      model.class::BEHAVIOR_SUBFORM_OUTER_KEY
    end

    def type_key
      'subform.behavior_types_dropdown'
    end

    def enum_id
      BEHAVIORS_ENUM_ID
    end

    def add_table_data(name, episodes_per_week, minutes_per_episode)
      row = [name]
      row << "#{episodes_per_week} /week"
      row << MULTIPLY
      row << "#{minutes_per_episode} min"
      row << EQUALS

      minutes_per_week = BigDecimal.new(episodes_per_week) * BigDecimal.new(minutes_per_episode)

      row << "#{smallest_numeric(minutes_per_week)} min/week"
      row << EQUALS

      minutes_per_day = minutes_per_week / 7.0
      row << "#{smallest_numeric(minutes_per_day)} min/day"

      table_data << row
    end

    def item_types_from_json(json_data)
      # This method is distinct because behavior uses a dropdown-multiple,
      # whereas medical_coordination uses a dropdown-single
      types = []

      hash = JSON.parse(json_data)
      keys = hash['keys']

      enum = Enumeration.find(enum_id)
      entries_hash = enum.entries

      keys.each do |key|
        types << entries_hash[key].try!(:[], 'en')
      end

      types.join(', ')
    end

    def render_one_form(hash, index, numbered)
      name = hash['subform.behavior_types_dropdown']
      if numbered
        name = "#{lettered_index(index)}. #{name}"
      end

      initialize_table_data

      episodes_per_week = hash['subform.episodes_per_week']     || Person::FinancialModel::ZERO
      minutes_per_episode = hash['subform.minutes_per_episode'] || Person::FinancialModel::ZERO

      add_table_data(name, episodes_per_week, minutes_per_episode)


      # Default to SPACE to preserve vertical spacing
      comment = hash['subform.behavior_notes'] || SPACE

      intervention_1 = hash['subform.effective_intervention']
      intervention_2 = hash['subform.effective_intervention_2']
      intervention_3 = hash['subform.effective_intervention_3']

      render_subtitle(name)

      document.pad(DESCRIPTION_TOP_AND_BOTTOM_PADDING) do
        text_in_place 'details:'
        document.indent(INDENT_A) do
          document.text comment
        end
      end


      text_in_place 'frequency:'
      document.indent(INDENT_A) do
        document.text "#{episodes_per_week} times/week"
      end

      text_in_place 'duration:'
      document.indent(INDENT_A) do
        document.text "#{minutes_per_episode} min"
      end

      counter = 1
      interventions = [intervention_1, intervention_2, intervention_3]

      return unless interventions.detect{ |i| i.present? }
      document.text 'interventions:'

      interventions.each do |intervention|

        next if intervention.blank?

        document.indent(INDENT_A) do
          document.text "#{counter}. #{intervention}"
        end

        counter += 1
      end


    end

    def subtotal_key
      :behavior_minutes_from_subform
    end

  end
end














