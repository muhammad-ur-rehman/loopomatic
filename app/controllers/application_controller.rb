class ApplicationController < ActionController::Base
  include ActionController::Flash
  include Respondable
  include ErrorHandling
  include ReturnRequestParams

  protect_from_forgery with: :exception, if: -> { request.format.html? }
end
