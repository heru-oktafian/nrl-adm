# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_valid_admin!, raise: false
  skip_before_action :verify_authenticity_token, raise: false

  def new
    redirect_to dashboard_path if session[:admin_token].present?
  end

  def create
    body = { username: params.dig(:session, :username), password: params.dig(:session, :password) }

    response = HTTParty.post(
      "http://localhost:3101/api/v1/admin/auth/login",
      headers: { "Content-Type" => "application/json", "Accept" => "application/json" },
      body: body.to_json
    )

    if response.success?
      data = response.parsed_response["data"]
      session[:admin_token] = data["token"]
      session[:admin_user] = data["user"]
      redirect_to dashboard_path
    else
      flash[:alert] = response.parsed_response["error"] || "Login failed"
      render :new
    end
  end

  def destroy
    session.delete(:admin_token)
    session.delete(:admin_user)
    redirect_to login_path
  end
end