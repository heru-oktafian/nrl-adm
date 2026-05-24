class AdminResourcesController < ApplicationController
  before_action :require_valid_admin!
  skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy, :update_profile]

  MENU_ITEMS = [
    { key: "dashboard", label: "Dashboard", path_helper: :dashboard_path },
    { key: "profile", label: "Profile", path: "/admin/profile" },
    { key: "skills", label: "Skills", path: "/admin/skills" },
    { key: "tools", label: "Tools", path: "/admin/tools" },
    { key: "projects", label: "Projects", path: "/admin/projects" },
    { key: "experiences", label: "Experiences", path: "/admin/experiences" },
    { key: "social_links", label: "Social Links", path: "/admin/social-links" },
    { key: "messages", label: "Messages", path: "/admin/contact-messages" }
  ].freeze

  helper_method :navigation_items, :active_nav_key

  def navigation_items
    MENU_ITEMS.map do |item|
      item.merge(path: item[:path] || send(item[:path_helper]))
    end
  end

  def active_nav_key
    @resource_key
  end

  RESOURCE_CONFIG = {
    "skills" => {
      title: "Skills",
      endpoint: "/admin/skills",
      summary: "Kelola skill dan kemampuan kamu di portfolio."
    },
    "projects" => {
      title: "Projects",
      endpoint: "/admin/projects",
      summary: "Kelola project yang pernah kamu kerjakan."
    },
    "experiences" => {
      title: "Experiences",
      endpoint: "/admin/experiences",
      summary: "Kelola pengalaman kerja kamu."
    },
    "social-links" => {
      title: "Social Links",
      endpoint: "/admin/social-links",
      summary: "Kelola link social media kamu."
    },
    "tools" => {
      title: "Tools",
      endpoint: "/admin/tools",
      summary: "Kelola tools yang kamu gunakan."
    },
    "contact-messages" => {
      title: "Contact Messages",
      endpoint: "/admin/contact-messages",
      summary: "Lihat pesan yang masuk dari visitor."
    },
    "profile" => {
      title: "Profile",
      endpoint: "/admin/profile",
      summary: "Kelola data profile portfolio kamu."
    }
  }.freeze

  def index
    @resource_key = params[:resource] || "skills"
    @resource = RESOURCE_CONFIG[@resource_key] || RESOURCE_CONFIG["skills"]

    response = HTTParty.get(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}#{@resource[:endpoint]}",
      headers: { "Authorization" => "Bearer #{session[:admin_token]}" }
    )

    if response.success?
      data = response.parsed_response["data"] || []
      @items = data.is_a?(Array) ? data : []
      @data = { status: :ok, message: "Success" }
    else
      @items = []
      @data = { status: :error, message: response.parsed_response["error"] || "Failed to fetch data" }
    end
  end

  def datatable
    index
  end

  def show
    @resource_key = params[:resource]
    @resource = RESOURCE_CONFIG[@resource_key]
    @item_id = params[:id]

    response = HTTParty.get(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}#{@resource[:endpoint]}/#{@item_id}",
      headers: { "Authorization" => "Bearer #{session[:admin_token]}" }
    )

    if response.success?
      @item = response.parsed_response["data"]
      @data = { status: :ok }
    else
      @data = { status: :error, message: "Item not found" }
    end
  end

  def new
    @resource_key = params[:resource]
    @resource = RESOURCE_CONFIG[@resource_key]
  end

  def create
    @resource_key = params[:resource]
    @resource = RESOURCE_CONFIG[@resource_key]

    body = build_create_body

    response = HTTParty.post(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}#{@resource[:endpoint]}",
      headers: { 
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{session[:admin_token]}" 
      },
      body: body.to_json
    )

    if response.success?
      redirect_to "/admin/#{@resource_key}", notice: "#{@resource[:title]} created successfully."
    else
      flash[:alert] = response.parsed_response["error"] || "Failed to create #{@resource[:title]}."
      redirect_to "/admin/#{@resource_key}"
    end
  end

  def edit
    @resource_key = params[:resource]
    @resource = RESOURCE_CONFIG[@resource_key]
    @item_id = params[:id]

    response = HTTParty.get(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}#{@resource[:endpoint]}/#{@item_id}",
      headers: { "Authorization" => "Bearer #{session[:admin_token]}" }
    )

    if response.success?
      @item = response.parsed_response["data"]
    else
      flash[:alert] = "Item not found."
      redirect_to "/admin/#{@resource_key}"
    end
  end

  def update
    @resource_key = params[:resource]
    @resource = RESOURCE_CONFIG[@resource_key]
    @item_id = params[:id]

    body = build_update_body

    response = HTTParty.put(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}#{@resource[:endpoint]}/#{@item_id}",
      headers: { 
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{session[:admin_token]}" 
      },
      body: body.to_json
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
    @item_id = params[:id]

    response = HTTParty.delete(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}#{@resource[:endpoint]}/#{@item_id}",
      headers: { "Authorization" => "Bearer #{session[:admin_token]}" }
    )

    if response.success?
      redirect_to "/admin/#{@resource_key}", notice: "#{@resource[:title]} deleted successfully."
    else
      flash[:alert] = response.parsed_response["error"] || "Failed to delete #{@resource[:title]}."
      redirect_to "/admin/#{@resource_key}"
    end
  end

  def profile
    @resource_key = "profile"
    @resource = RESOURCE_CONFIG["profile"]

    response = HTTParty.get(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}/admin/profile",
      headers: { "Authorization" => "Bearer #{session[:admin_token]}" }
    )

    if response.success?
      @profile = response.parsed_response["data"] || {}
      @data = { status: :ok }
    else
      @profile = {}
      @data = { status: :error, message: "Failed to fetch profile" }
    end
  end

  def update_profile
    body = {
      full_name: params[:full_name],
      title: params[:title],
      bio: params[:bio],
      email: params[:email],
      phone: params[:phone],
      location: params[:location]
    }.compact

    response = HTTParty.put(
      "#{ENV.fetch('NRL_BE_API_URL', 'http://localhost:3101/api/v1')}/admin/profile",
      headers: { 
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{session[:admin_token]}" 
      },
      body: body.to_json
    )

    if response.success?
      redirect_to admin_profile_path, notice: "Profile updated successfully."
    else
      flash[:alert] = response.parsed_response["error"] || "Failed to update profile."
      redirect_to admin_profile_path
    end
  end

  private

  def build_create_body
    case @resource_key
    when "skills"
      { name: params[:name], level: params[:level].to_i, category: params[:category], icon: params[:icon] }.compact
    when "projects"
      { 
        title: params[:title], 
        description: params[:description], 
        tech_stack: params[:tech_stack], 
        image_url: params[:image_url], 
        url: params[:url] 
      }.compact
    when "experiences"
      { 
        company: params[:company], 
        position: params[:position], 
        start_date: params[:start_date], 
        end_date: params[:end_date], 
        description: params[:description] 
      }.compact
    when "social-links"
      { platform: params[:platform], url: params[:url], icon: params[:icon] }.compact
    when "tools"
      { name: params[:name], icon: params[:icon], url: params[:url] }.compact
    else
      {}
    end
  end

  def build_update_body
    build_create_body
  end
end
