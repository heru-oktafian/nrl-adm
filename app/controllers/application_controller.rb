# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :require_valid_admin!, :admin_token

  private

  def require_valid_admin!
    unless session[:admin_token].present?
      redirect_to login_path, alert: "Please login first." and return
    end
  end

  def admin_token
    session[:admin_token]
  end
end