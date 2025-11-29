class ApplicationController < ActionController::Base
  include ActionController::Flash
  include Respondable
  include ErrorHandling

  protect_from_forgery with: :exception, if: -> { request.format.html? }
end
