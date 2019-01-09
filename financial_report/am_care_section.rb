module FinancialReport
  class AmCareSection < FinancialReport::Section

    def title
      'AM Care'
    end

    def capabilities
      {
        'Brushing Hair'   => :am_brushing_hair_expect,
        'Brushing Teeth'  => :am_brushing_teeth_expect,
        'Dentures'        => :am_dentures_expect,
        'Hearing Aids'    => :hearing_aid,
        'Eyeglasses'      => :glasses_assist,
        'Deodorant'       => :am_deodorant_expect,
        'Washing Face'    => :am_washing_face_expect,
        'Washing Hands'   => :am_washing_hands_expect,
        'Applying Makeup' => :am_makeup_expect,
        'Pyjamas'         => :am_dressing_expect,
        'Applying Lotion' => :am_lotion_expect,
        'Making Bed'      => :am_making_bed_expect,
        'Shaving'         => :am_shaving_expect,
        'Pants and Shirt' => :dressing_pants_expect,
        'Undergarments'   => :dressing_undergarments_expect,
        'Sweater / Vest'  => :dressing_sweater_expect,
        'Dress'           => :dressing_dress_expect,
        'Prosthetics'     => :dressing_prosethetics_expect,
        'Orthotics'       => :dressing_orthotics_expect,
        'Socks and Shoes' => :am_socks_expect,
      }
    end

    def notes
      {
        # SKIPPED because it's an ENUM and it's irrelevant to a detailed invoice
        # 'Wake Up Time' => :wake_up_am,
        # 'Outfit Preferences' => :???,
        #
        # SKIPPED because it's irrelevant to a detailed invoice
        'Resident' => :am_helpful_notes,
        'Staff'    => :am_caretaker_helpful_notes,
      }
    end


    def subtotal_key
      :am_minutes
    end
  end
end
