module FinancialReport
  class LocomotionSection < FinancialReport::Section

    def title
      'Locomotion'
    end

    def capabilities
      {
        'Wheel Chair' => :locomotion_wheel_chairs,
        'Four Wheeled Chair' => :locomotion_walkers,
        'Two-wheeled Walker' => :locomotion_walkers4,
        'Scooter' => :locomotion_scooters,
        'Gait Belt' => :locomotion_gait_belts,
        'Cane' => :locomotion_canes,
        'Walking Assisted' => :locomotion_walking_assist,
      }
    end

    # SKIPPED: Activity Level (drop-down-single) with enum "activity_level"
    #  entries:
    #   hyper | very_active | active | normal | inactive | sedentary

    def notes
      {
        'Ability'    => :walking_assist,
        'Steadiness' => :walking_steadiness,
        'Resident'   => :locomotion_notes,
        'Staff'      => :locomotion_caretaker_notes,
      }
    end


    def subtotal_key
      :locomotion_minutes
    end
  end
end
