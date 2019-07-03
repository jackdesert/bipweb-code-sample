require 'prawn/measurement_extensions'

class FinancialReportPresenter

  attr_reader :person, :model

  def initialize(person)
    @person = person
    @model = Person::FinancialModel.new(person)
  end

  def document
    options = { right_margin: 60.mm,
                print_scaling: :none, # Do not show an option for "scale to fit" when printing dialog opens
                info: metadata,
              }

    @document ||= Prawn::Document.new(options)
  end

  def render

    page_number = 1
    sections.each do |section|

      if section.able_to_render? && section.start_on_new_page
        page_number += 1
      end

      section.render
      section.footer("page #{page_number} of #{total_pages}")
    end

  end

  private
  def metadata
    # Add whatever arbitrary keys you want
    {
      title: "Service Plan for #{person.full_name}",
      facility: 'EliteCare',
      author: 'Jack Desert',
      generated_at: Time.now.to_s,
    }
  end


  def symbols
    { TitlePageSection: false,

      BehaviorSubformSection: true,

      #### Needs DietSection

      AmCareSection:    true,
      PmCareSection:    true,

      ShoweringSection: true,
      ToiletingSection: false,

      TransfersSection:  true,
      LocomotionSection: false,

      #### Needs MedicationManagment

      #### Needs Nursing



      HousekeepingSection: true,
      LaundrySection: false,

      MedicalCoordinationSubformSection: true,
      PetCareSection: false,


      CalculationsSection:    true,
    }
  end


  def total_pages
    count = 1
    sections.each do |section|
      count += 1 if (section.able_to_render? && section.start_on_new_page)
    end

    count
  end

  def sections

    symbols.map do  |symbol, start_on_new_page|
      klass = "FinancialReport::#{symbol}".constantize
      klass.new(model, document, start_on_new_page)
    end
  end
end
