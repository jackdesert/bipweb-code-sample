module People
  class FinancialReportController < ApplicationController

    HYPHEN = '-'
    NON_QUERTY_REGEX = /[^a-z]+/


    def index
      require_permission :financial_reports, AccessType::READ
      slug = params[:slug]

      person = Person.find_by(slug: slug)

      if person.nil?
        render html: simple_flash("No Person found with slug '#{slug}'"), layout: true, status: :not_found
        return
      end

      report = FinancialReportPresenter.new(person)
      report.render

      name_without_spaces = person.full_name.downcase.gsub(NON_QUERTY_REGEX, HYPHEN)
      filename = "service-plan__#{name_without_spaces}.pdf"

      send_data report.document.render, filename: filename, type: 'application/pdf', disposition: :inline
    end
  end
end
