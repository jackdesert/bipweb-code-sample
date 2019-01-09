module FinancialReport
  class ShoweringSection < FinancialReport::Section

    def title
      'Showering'
    end

    def capabilities
      {
        'Shower'      => :shower_help_expect,
        'Sponge Bath' => :sponge_bath_help_expect,
      }
    end

    def notes
      {
        'Resident' => :bathing_notes,
        'Staff'    => :bathing_caretaker_notes,
      }
    end


    def subtotal_key
      :bathing_minutes
    end
  end
end
