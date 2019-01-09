module FinancialReport
  class Equation
    include FinancialReport::Utils

    ARGUMENT_REGEX          = '[a-z_]+'
    VALUE_REGEX             = /value\(:(#{ARGUMENT_REGEX})\)/
    VALUE_DEFAULT_ONE_REGEX = /value_default_one\(:(#{ARGUMENT_REGEX})\)/

    LINE_FEED      = "\n".freeze

    CONSTANTS_TO_REPLACE = {
      'bathing_showers_per_week' => 'showers/week',
      'bathing_minutes_per_shower' => 'min/shower',
      'toileting_minutes_per_incident' => 'min/incident',
      'toileting_incidents_per_day' => 'incidents/day',
      'transfers_minutes_per_incident' => 'min/incident',
      'transfers_incidents_per_day' => 'incidents/day',
      'locomotion_minutes_per_incident' => 'min/incident',
      'locomotion_incidents_per_day' => 'incidents/day',
      'housekeeping_extra_visits_per_week' => 'extra visits/week',
      'laundry_extra_visits_per_week' => 'extra visits/week',
      'HOUSEKEEPING_DURATION_IN_MINUTES' => "#{Person::FinancialModel::HOUSEKEEPING_DURATION_IN_MINUTES.round} min/visit",
      'LAUNDRY_DURATION_IN_MINUTES' => "#{Person::FinancialModel::LAUNDRY_DURATION_IN_MINUTES.round} min/visit",
      'DAYS_PER_WEEK' => '7 days/week',
    }.freeze


    attr_reader :model, :method, :source

    def initialize(model, method)
      @model  = model
      @method = method
      @source = raw_source.dup # .dup because raw_source is frozen
    end

    def colloquial
      replace_division_symbol_first!
      replace_values!(true)
      replace_values!(false)
      replace_constants!

      source
    end

    private

    def raw_source
      source = model.class.instance_method(method).source.freeze
      source.split(LINE_FEED)[1..-2].join.freeze
    end


    def replace_division_symbol_first!
      # Replace this first, because later lots of forward slashes
      # will be in the source as min/week, etc.
      source.sub!(FinancialReport::Section::SLASH, FinancialReport::Section::DIVIDE)
    end

    def replace_values!(default)
      value_regex = VALUE_REGEX
      method = :value
      if default
        value_regex = VALUE_DEFAULT_ONE_REGEX
        method = :value_default_one
      end


      while true
        match = source.match value_regex
        break if match.nil?

        text     = match[0]
        argument = match[1]
        value    = model.send(method, argument)

        label = equation_label(argument)
        new_text = "#{smallest_numeric(value)} #{label}"
        source.sub!(text, new_text)
      end

    end

    def replace_constants!
      CONSTANTS_TO_REPLACE.each do |constant, replacement|
        source.sub!(constant, replacement)
      end

    end

    def replace_values_default_one
    end

    def equation_label(method)
      if method.ends_with?('minutes_per_day')
        'min/day'
      elsif method.ends_with?('number_of_staff')
        'staff'
      else
        method
      end
    end


  end
end
