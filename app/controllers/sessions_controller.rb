# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_valid_admin!, raise: false
  skip_before_action :verify_authenticity_token, raise: false

  def new
    redirect_to dashboard_path if session[:admin_token].present?
  end

  def create
    username = params[:username]
    password = params[:password]

    unless username.present? && password.present?
      flash[:alert] = "Username and password are required"
      return redirect_to login_path
    end

    response = HTTParty.post(
      "http://localhost:3101/api/v1/admin/auth/login",
      headers: { "Content-Type" => "application/json", "Accept" => "application/json" },
      body: { username: username, password: password }.to_json
    )

    if response.success?
      data = response.parsed_response["data"]
      session[:admin_token] = data["token"]
      session[:admin_user] = data["user"]
      flash[:notice] = "Welcome back, #{data.dig('user', 'name') || username}!"
      redirect_to dashboard_path
    else
      flash[:alert] = response.parsed_response["error"] || "Invalid credentials"
      redirect_to login_path
    end
  rescue StandardError => e
    Rails.logger.error "Login error: #{e.message}"
    flash[:alert] = "Unable to connect to authentication service"
    redirect_to login_path
  end

  def destroy
    session.delete(:admin_token)
    session.delete(:admin_user)
    flash[:notice] = "You have been logged out"
    redirect_to login_path
  end
end
