# frozen_string_literal: true

# API Client for communicating with nrl-be backend
class NrlApiClient
  attr_reader :base_url, :token

  def initialize(base_url:, token: nil)
    @base_url = base_url.chomp("/")
    @token = token
  end

  def get(endpoint, params: {})
    request(:get, endpoint, params: params)
  end

  def post(endpoint, body: {})
    request(:post, endpoint, body: body)
  end

  def put(endpoint, body: {})
    request(:put, endpoint, body: body)
  end

  def delete(endpoint)
    request(:delete, endpoint)
  end

  private

  def request(method, endpoint, params: {}, body: {})
    url = "#{@base_url}#{endpoint}"
    headers = {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
    headers["Authorization"] = "Bearer #{@token}" if @token.present?

    case method
    when :get
      HTTParty.get(url, headers: headers, query: params)
    when :post
      HTTParty.post(url, headers: headers, json: body)
    when :put
      HTTParty.put(url, headers: headers, json: body)
    when :delete
      HTTParty.delete(url, headers: headers)
    end
  end
end