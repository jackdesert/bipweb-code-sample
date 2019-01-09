module FinancialReport
  module Utils
    # Include this module anywhere you need these utilities


    # Unable to access FinancialReport::Section::BASE_SIZE when these are read in.
    # Hence, only storing the multipliers here
    TABLE_CELL_PADDING_MULTIPLIERS = [0.05, 0.6]
    TABLE_SPACE_BELOW_MULTIPLIER  = 0.5

    def smallest_numeric(number)
      raise ArgumentError, "Expected BigDecimal, but got #{number.class}" unless number.is_a?(BigDecimal)
      rounded = if number.to_s.match /\.0+\z/
                  number.round
                else
                  number.round(2)
                end

      rounded.to_s
    end


    def styled_table(data, cols_align_right=[])

      base_size = FinancialReport::Section::BASE_SIZE.freeze

      padding = TABLE_CELL_PADDING_MULTIPLIERS.map{ |number| number * base_size }

      style = { borders: [],
                padding: padding,

                # There is a bug in prawn-table that breaks when setting width
                # https://github.com/prawnpdf/prawn-table/issues/54
                # width: document.bounds.width
              }

      striped_indices = (0..data.count).to_a.select{ |i| i.even? }

      document.table(data, cell_style: style) do


        striped_indices.each do |i|
          row(i).background_color = FinancialReport::Section::STRIPE_COLOR
        end

        columns(cols_align_right).align = :right
      end

      document.move_down(TABLE_SPACE_BELOW_MULTIPLIER * base_size)
    end

  end
end
