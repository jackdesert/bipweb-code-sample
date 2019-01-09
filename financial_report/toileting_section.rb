module FinancialReport
  class ToiletingSection < FinancialReport::Section

    def title
      'Toileting'
    end

    def capabilities
      {
        'Toileting'      => :toileting_help_expect,
        'Incontinence Products' => :toileting_incontinence_help_expect,

        # Should this be labeled "Bed Pan"?
        'Commode' => :toileting_bed_pan_help_expect,
      }
    end

    # MISSING: Dropdown Multiple that uses the "bladder_incontinence" enumeration
    # ( entries: [:frequent, :occasional] )
    # and field names: [:toileting_incontinent_1, :toileting_incontinent_2]
    # PERHAPS this could be better served with a different row type

    def notes
      {
        'Resident' => :toileting_notes,
        'Staff'    => :toileting_caretaker_notes,
        'Products' => :incontinence_products_needed,
      }
    end


    def subtotal_key
      :toileting_minutes
    end
  end
end
