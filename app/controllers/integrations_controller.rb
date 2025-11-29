class IntegrationsController < ApplicationController
  def vehicle_models
    make = params[:make]
    year = params[:year]&.to_i

    if make.blank? || year.blank?
      render_error("make and year parameters are required", status: :bad_request)
      return
    end

    models = Services::VehicleModelsClient.fetch_models(make: make, year: year)

    render_success({
      make: make,
      year: year,
      models: models
    })
  end

  def discontinued_models
    make = params[:make]
    from_year = params[:from_year]&.to_i
    to_year = params[:to_year]&.to_i
    gap_years = params[:gap_years]&.to_i || 2

    if make.blank? || from_year.blank? || to_year.blank?
      render_error("make, from_year, and to_year parameters are required", status: :bad_request)
      return
    end

    result = Services::DiscontinuedModelsCalculator.calculate(
      make: make,
      from_year: from_year,
      to_year: to_year,
      gap_years: gap_years
    )

    render_success(result)
  rescue ArgumentError => e
    render_error(e.message, status: :bad_request)
  end
end

