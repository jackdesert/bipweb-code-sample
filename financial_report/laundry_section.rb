module FinancialReport
  class LaundrySection < FinancialReport::Section

    def title
      'Laundry'
    end

    def capabilities
      {}
    end

    # MISSING: Dropdown Single that uses the "grading" enumeration
    # ( entries: [:good, :average, :below_average, :poor] )

    def notes
      {
        'Resident' => :laundry_notes,
        'Staff'    => :laundry_caretaker_notes,
      }
    end


    def subtotal_key
      :laundry_minutes
    end

    def able_to_render?
      model.laundry_minutes > model.class::ZERO
    end
  end
end
