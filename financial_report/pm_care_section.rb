module FinancialReport
  class PmCareSection < FinancialReport::Section

    def title
      'PM Care'
    end

    def capabilities
      {
        'Brushing Hair'   => :pm_brushing_hair_expect,
        'Brushing Teeth'  => :pm_brushing_teeth_expect,
        'Dentures'        => :pm_dentures_expect,
        'Washing Face'    => :pm_washing_face_expect,

        'Socks and Shoes' => :pm_socks_expect,
        'Undressing'      => :undressing_assist,
        'Pyjamas'         => :pm_undressing_expect,
        'Washing Hands'   => :pm_washing_hands_expect,

        'Removing Makeup' => :pm_makeup_expect,
        'Applying Lotion' => :pm_lotion_expect,
        'Turn down Bed'   => :pm_making_bed_expect,
      }
    end

    def notes
      {
        # SKIPPED because it's an ENUM and it's irrelevant to a detailed invoice
        # 'Goes to Bed At' => :pm_sleep_time,
        # 'Outfit Preferences' => :pm_preferences,
        #
        # SKIPPED because they are irrelevant to a detailed invoice


        # Why does PM Care have four notes, whereas AM Care has only two?
        'Resident'      => :pm_care_notes,
        'Resident Need' => :pm_needs_resident,

        'Staff'         => :pm_care_caretaker_notes,
        'Staff Need'    => :pm_needs,
      }
    end


    def subtotal_key
      :pm_minutes
    end
  end
end
