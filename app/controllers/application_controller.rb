class ApplicationController < ActionController::Base
  rescue_from StandardError,                      with: :render_internal_error
  rescue_from ActiveRecord::RecordInvalid,        with: :render_internal_error
  rescue_from ActionController::UnknownFormat,    with: :render_not_found
  rescue_from ActionController::RoutingError,     with: :render_not_found
  rescue_from ActiveRecord::RecordNotFound,       with: :render_not_found

  private

  def render_not_found
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found }
      format.json { render json: { error: "Not found" }, status: :not_found }
    end
  end

  def render_internal_error
    respond_to do |format|
      format.html { render "errors/internal_server_error", status: :internal_server_error }
      format.json { render json: { error: "Internal server error" }, status: :internal_server_error }
    end
  end
end
