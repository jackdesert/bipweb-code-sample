module FinancialReport
  class HousekeepingSection < FinancialReport::Section

    def title
      'Housekeeping'
    end

    def capabilities
      {}
    end

    # MISSING: Dropdown Single that uses the "grading" enumeration
    # ( entries: [:good, :average, :below_average, :poor] )

    def notes
      {
        'Resident' => :housekeeping_hints,
        'Staff'    => :housekeeping_caretaker_hints,
      }
    end


    def subtotal_key
      :housekeeping_minutes
    end

    def able_to_render?
      model.housekeeping_minutes > model.class::ZERO
    end

  end
end
