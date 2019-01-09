module FinancialReport
  class PetCareSection < FinancialReport::Section

    def title
      'Pet Care'
    end

    def capabilities
      {}
    end

    # MISSING: Dropdown Multiple that uses the "pet_care_activities" enumeration
    # ( entries: [:grooming, :feeding_am, :feeding_pm, :walking, :kitty_litter, :attention, :not_applicable]

    def notes
      {
        'Resident' => :pet_care_notes,
        'Staff'    => :pet_care_caretaker_notes,
      }
    end


    def subtotal_key
      :pet_care_minutes
    end

    def able_to_render?
      model.pet_care_minutes > model.class::ZERO
    end

  end
end
