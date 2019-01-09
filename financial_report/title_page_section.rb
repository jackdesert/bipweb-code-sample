module FinancialReport
  class TitlePageSection < FinancialReport::Section

    include PronounHelper

    WHITESPACE_REGEX = /\s+/

    PHOTO_PADDING = 1.0 * BASE_SIZE
    LOGO_PADDING  = 5.0 * BASE_SIZE

    def title
      #name = model.person.full_name.strip.sub(WHITESPACE_REGEX, Prawn::Text::NBSP)
      model.person.full_name
    end


    def render
      set_defaults
      render_logo
      render_title_tag
      render_title
      render_profile_photo
      render_about_service_plan
    end

    private

    def render_profile_photo
      datum = model.person.person_data.find_by(key: Person::PROFILE_PHOTO_KEY)

      return unless datum

      photo_id = datum.try!(:value)
      photo = Photo.find_by(id: photo_id)

      return unless photo

      absolute_filepath = photo.bitmap.path(:print_4x6)


      document.pad(PHOTO_PADDING) do
        document.image absolute_filepath, height: 120.mm
      end

    end

    def render_about_service_plan
      render_subtitle('What is a Service Plan?')

      pronoun = possessive_pronoun(model.person)

      words = "A <i><b>service plan</b></i> details how independent #{model.person.first_name} is, and how that affects #{pronoun} care costs."

      document.text words, inline_format: true
    end

    def render_logo
      document.image "#{Rails.root}/app/assets/images/logo.png"
      document.move_down LOGO_PADDING
    end

    def render_title_tag
      document.font(SANS_BOLD_OBLIQUE, size: TITLE_TAG_SIZE) do
        document.text 'Service Plan:'
      end
    end
  end
end
