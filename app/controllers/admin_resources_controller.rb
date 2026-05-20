# frozen_string_literal: true

class AdminResourcesController < ApplicationController
  before_action :require_valid_admin!

  RESOURCE_CONFIG = {
    "profile" => {
      title: "Profile",
      endpoint: "/admin/profile",
      summary: "Kelola identitas utama, headline, bio, dan kontak portfolio."
    },
    "projects" => {
      title: "Projects",
      endpoint: "/admin/projects",
      summary: "Daftar project portfolio yang tampil di website publik."
    },
    "skills" => {
      title: "Skills",
      endpoint: "/admin/skills",
      summary: "Teknologi dan kemampuan utama yang ingin ditampilkan."
    },
    "experiences" => {
      title: "Experiences",
      endpoint: "/admin/experiences",
      summary: "Riwayat pengalaman kerja atau proyek profesional."
    },
    "tools" => {
      title: "Tools",
      endpoint: "/admin/tools",
      summary: "Daftar tools dan technologies yang tampil di portfolio publik."
    },
    "social-links" => {
      title: "Social Links",
      endpoint: "/admin/social-links",
      summary: "Link sosial dan platform publik yang terhubung ke profil."
    },
    "contact-messages" => {
      title: "Messages",
      endpoint: "/admin/contact-messages",
      summary: "Daftar pesan masuk dari form Hubungi Kami di website publik."
    }
  }.freeze

  helper_method :navigation_items, :active_nav_key, :template_for_resource, :resource_data, :resource_config

  def index
    # Handle /admin/profile separately since it's defined before :resource route
    @resource_key = params[:resource]
    @resource_key = 'profile' if request.path == '/admin/profile'
    @resource = RESOURCE_CONFIG[@resource_key]

    unless @resource
      redirect_to dashboard_path, alert: "Menu tidak ditemukan."
      return
    end

    @data = fetch_resource_data
    @items = @data[:items]
  end

  def update_profile
    @resource_key = "profile"
    @resource = RESOURCE_CONFIG[@resource_key]
    
    response = HTTParty.put(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}#{@resource[:endpoint]}",
      headers: { "Content-Type" => "application/json", "Authorization" => "Bearer #{session[:admin_token]}" },
      body: profile_params.to_json
    )

    if response.success?
      redirect_to admin_resources_path("profile"), notice: "Profile updated successfully."
    else
      flash[:alert] = response.parsed_response["error"] || "Failed to update profile."
      redirect_to admin_resources_path("profile")
    end
  end

  def create
    @resource_key = params[:resource]
    @resource = RESOURCE_CONFIG[@resource_key]

    response = HTTParty.post(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}#{@resource[:endpoint]}",
      headers: { "Content-Type" => "application/json", "Authorization" => "Bearer #{session[:admin_token]}" },
      body: resource_params.to_json
    )

    if response.success?
      redirect_to "/admin/#{@resource_key}", notice: "#{@resource[:title]} created successfully."
    else
      flash[:alert] = response.parsed_response["error"] || "Failed to create #{@resource[:title]}."
      redirect_to "/admin/#{@resource_key}"
    end
  end

  def update
    @resource_key = params[:resource]
    @resource = RESOURCE_CONFIG[@resource_key]

    response = HTTParty.put(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}#{@resource[:endpoint]}/#{params[:id]}",
      headers: { "Content-Type" => "application/json", "Authorization" => "Bearer #{session[:admin_token]}" },
      body: resource_params.to_json
    )

    if response.success?
      redirect_to "/admin/#{@resource_key}", notice: "#{@resource[:title]} updated successfully."
    else
      flash[:alert] = response.parsed_response["error"] || "Failed to update #{@resource[:title]}."
      redirect_to "/admin/#{@resource_key}"
    end
  end

  def destroy
    @resource_key = params[:resource]
    @resource = RESOURCE_CONFIG[@resource_key]

    response = HTTParty.delete(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}#{@resource[:endpoint]}/#{params[:id]}",
      headers: { "Authorization" => "Bearer #{session[:admin_token]}" }
    )

    if response.success?
      redirect_to "/admin/#{@resource_key}", notice: "#{@resource[:title]} deleted successfully."
    else
      flash[:alert] = response.parsed_response["error"] || "Failed to delete #{@resource[:title]}."
      redirect_to "/admin/#{@resource_key}"
    end
  end

  private

  def navigation_items
    DashboardController::MENU_ITEMS.map do |item|
      item.merge(path: item[:path] || send(item[:path_helper]))
    end
  end

  def active_nav_key
    params[:resource] || "dashboard"
  end

  def resource_config
    @resource
  end

  def resource_data
    @data
  end

  def template_for_resource
    return :profile if @resource_key == "profile"
    return :datatable if %w[projects skills experiences tools social-links contact-messages].include?(@resource_key)
    :datatable
  end

  def fetch_resource_data
    response = HTTParty.get(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}#{@resource[:endpoint]}",
      headers: { "Authorization" => "Bearer #{session[:admin_token]}" }
    )

    payload = response.parsed_response
    data = payload["data"]

    if response.success?
      items = data.is_a?(Array) ? data : (data.present? ? [data] : [])
      { status: :ok, items: items, raw: data, message: payload["message"].presence || "Data loaded." }
    else
      { status: :error, items: [], raw: payload, message: payload["error"].presence || "Gagal mengambil data." }
    end
  rescue StandardError => e
    { status: :error, items: [], raw: nil, message: "Gagal terhubung ke backend: #{e.message}" }
  end

  def resource_params
    singular = @resource_key == "profile" ? "profile" : @resource_key.singularize
    params.require(singular.to_sym).permit! if params[singular]
  end

  def profile_params
    params.require(:profile).permit!
  end
end