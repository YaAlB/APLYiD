# frozen_string_literal: true

class Pricing
  attr_reader :prices

  def initialize(prices_data)
    @prices = parse_prices(prices_data)
    validate_prices!
  end

  def cost_for(type:, country:)
    type_key = type.to_s.downcase
    country_key = country.to_s.upcase

    raise ArgumentError, "Unknown notification type: #{type}" unless @prices.key?(type_key)
    raise ArgumentError, "Unknown country: #{country}" unless @prices[type_key].key?(country_key)

    @prices[type_key][country_key]
  end

  def available_types
    @prices.keys
  end

  def available_countries_for(type)
    type_key = type.to_s.downcase
    raise ArgumentError, "Unknown notification type: #{type}" unless @prices.key?(type_key)
    @prices[type_key].keys
  end

  private

  def parse_prices(prices_data)
    case prices_data
    when String
      begin
        JSON.parse(prices_data)
      rescue JSON::ParserError => e
        raise ArgumentError, "Invalid JSON in pricing data: #{e.message}"
      end
    when Array, Hash
      prices_data
    else
      raise ArgumentError, "Invalid pricing data format"
    end
  end

  def validate_prices!
    raise ArgumentError, "Pricing data must be an array" unless @prices.is_a?(Array)

    @prices = @prices.each_with_object({}) do |item, result|
      type = item['notification_type']
      prices = item['prices']

      raise ArgumentError, "Missing notification_type" if type.nil? || type.empty?
      raise ArgumentError, "Missing prices for #{type}" if prices.nil? || !prices.is_a?(Hash)

      result[type] = prices.transform_keys(&:upcase)
    end

    raise ArgumentError, "No pricing data found" if @prices.empty?
  end
end
