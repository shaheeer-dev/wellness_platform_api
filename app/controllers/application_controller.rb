class ApplicationController < ActionController::API
  include ErrorHandler
  include Pagy::Backend
end
