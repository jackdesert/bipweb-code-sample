module FinancialReport
  class TransfersSection < FinancialReport::Section

    def title
      'Transfers'
    end

    def capabilities
      {
        'Bedbound' => :transfers_bed_bound,
        'Side Rails' => :side_rail,
        'Hoyer Lift' => :transfers_hoyer_lift,
        'Transfer Board' => :transfers_bed_board,

        'Pole' => :transfers_poles,
        'Gait Belt' => :transfer_gait_belt,
        'Walker' => :transfers_walker,
        'Arm' => :transfers_arms,
      }
    end


    def notes
      {
        'Resident' => :transfers_notes,
        'Staff'    => :transfers_caretaker_notes,
      }
    end


    def subtotal_key
      :transfers_minutes
    end
  end
end
