module FinancialReport
  class CalculationsSection < FinancialReport::Section

    class KeyNotFoundError < Exception; end

    PLUS      = '+'
    LINE_FEED = "\n"

    SECTION_INDENT = 9 * BASE_SIZE

    LABELS = {
      behavior_minutes_from_subform: 'Behavior',
      diet_minutes: 'Diet',
      am_minutes: 'A.M. Routine',
      pm_minutes: 'P.M. Routine',
      bathing_minutes: 'Bathing',
      toileting_minutes: 'Toileting',
      transfers_minutes: 'Transfers',
      locomotion_minutes: 'Locomotion',
      medication_minutes: 'Medication Mgmt',
      nursing_task_minutes: 'Nursing',
      housekeeping_minutes: 'Housekeeping',
      laundry_minutes: 'Laundry',
      medical_coordination_minutes_from_subform: 'Outside Medical Coordination',
      pet_care_minutes: 'Pet Care',
    }.freeze

    SORTED_LABEL_KEYS = LABELS.keys.sort.freeze

    def title
      'Summary'
    end


    def render
      set_defaults
      render_title
      render_section_subtotals
      render_grand_total
      render_colloquial_equation
    end

    # This is a public method because the BillingPresenter calls it
    def keys_from_source
      source = model.class.instance_method(:total_minutes).source.freeze
      inner_source = source.split(LINE_FEED)[1..-2].join.freeze

      # Skip "def <method>" and "end"
      keys = inner_source.split(PLUS).map{|method| method.strip.to_sym}.freeze

      if keys.sort != SORTED_LABEL_KEYS
        raise KeyNotFoundError, "Expected #{keys.sort} to equal #{SORTED_LABEL_KEYS}"
      end

      keys
    end

    private


    def render_colloquial_equation
      rent = model.send(:monthly_rent).round(2)
      rent = smallest_numeric(rent)

      hours_per_month = model.send(:total_points)
      hours_per_month = smallest_numeric(hours_per_month)

      rate = model.person.hourly_rate
      rate = smallest_numeric(rate)

      care_costs = model.send(:monthly_total_care_costs)
      care_costs = smallest_numeric(care_costs)
      care_costs_with_units = "$#{care_costs} /month"

      rent_row = ['Base Rent:', '', '', '', EQUALS, "$#{rent}/month"]
      care_row = ['Care Costs:', "#{hours_per_month} hr/month", MULTIPLY, "$#{rate}/hr", EQUALS, care_costs_with_units]

      table_data = [rent_row, care_row]

      styled_table(table_data)

      grand_total = model.send(:monthly_grand_total)
      grand_total = smallest_numeric(grand_total)
      grand_total_with_units = "$#{grand_total} /month"

      render_value_in_box('Monthly Grand Total', grand_total_with_units, GRAND_TOTAL_BOX_COLOR)
    end

    def render_grand_total
      render_subtitle 'Monthly Cost'
    end

    def render_section_subtotals
      render_subtitle 'Subtotals'

      keys = keys_from_source

      table_data = []

      keys.each do |key|
        table_row = []
        value = model.send(key)

        table_row << LABELS[key]
        table_row << value.round(1)
        table_row << 'min/day'

        table_data << table_row
      end

      styled_table(table_data, 1)

      minutes_per_day = smallest_numeric(model.send(:total_minutes))
      hours_per_month = smallest_numeric(model.send(:total_points))
      space = Prawn::Text::NBSP * 4
      display_value = "#{minutes_per_day} min/day#{space}(#{hours_per_month} hours/month)"

      render_value_in_box('Section Total', display_value, GRAND_TOTAL_BOX_COLOR)

    end

  end
end
