module FinancialReport
  class MedicalCoordinationSubformSection < FinancialReport::Section
    include FinancialReport::Utils
    include FinancialReport::Subform

    MEDICAL_COORDINATION_ENUM_ID = '26d8ad8b-fc19-4cd4-b4e6-20b4b50d1d0a'


    attr_accessor :table_data

    def able_to_render?
      datum_value.present?
    end

    def title
      'Medical Coordination'
    end

    private


    def datum
      model.subform_datum_value(outer_key)
    end

    def outer_key
      model.class::OUTSIDE_SERVICES_COORDINATION_SUBFORM_OUTER_KEY
    end

    def type_key
      'subform.service_provider_1'
    end

    def enum_id
      MEDICAL_COORDINATION_ENUM_ID
    end


    def add_table_data(name, minutes_per_week)
      minutes_per_week = BigDecimal.new(minutes_per_week)

      row = [name]
      row << "#{smallest_numeric(minutes_per_week)} min/week"

      minutes_per_day = minutes_per_week / 7.0
      row << "( #{smallest_numeric(minutes_per_day)} min/day )"

      table_data << row
    end

    def item_types_from_json(json_data)
      # This method is distinct because behavior uses a dropdown-multiple,
      # whereas medical_coordination uses a dropdown-single
      types = []

      hash = JSON.parse(json_data)
      key = hash['key']

      enum = Enumeration.find(enum_id)
      entries_hash = enum.entries


      entries_hash[key].try!(:[], 'en') || key
    end


    def render_one_form(hash, index, numbered)
      name = hash['subform.service_provider_1']
      if numbered
        name = "#{lettered_index(index)}. #{name}"
      end

      initialize_table_data

      minutes_per_week = hash['subform.minutes_per_week'] || Person::FinancialModel::ZERO

      add_table_data(name, minutes_per_week)


      # Default to SPACE to preserve vertical spacing
      comment = hash['subform.outside_service_notes'] || SPACE

      render_subtitle(name)

      document.pad(DESCRIPTION_TOP_AND_BOTTOM_PADDING) do
        text_in_place 'details:'
        document.indent(INDENT_A) do
          document.text comment
        end
      end


      text_in_place 'duration:'
      document.indent(INDENT_A) do
        document.text "#{minutes_per_week} min/week"
      end



    end

    def subtotal_key
      :medical_coordination_minutes_from_subform
    end

  end
end
