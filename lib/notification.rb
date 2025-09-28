# frozen_string_literal: true

class Notification
  attr_reader :company, :type, :country

  VALID_TYPES = %w[sms email].freeze
  VALID_COUNTRIES = %w[AU NZ UK].freeze

  def initialize(company:, type:, country:)
    @company = company.to_s.strip
    @type = type.to_s.downcase.strip
    @country = country.to_s.upcase.strip

    validate_attributes!
  end

  def self.from_hash(data)
    new(
      company: data['company'] || data[:company],
      type: data['type'] || data[:type],
      country: data['country'] || data[:country]
    )
  end

  def matches?(type:, country:)
    @type == type.to_s.downcase && @country == country.to_s.upcase
  end

  private

  def validate_attributes!
    raise ArgumentError, "Invalid company: '#{@company}'" if @company.empty?
    raise ArgumentError, "Invalid type: '#{@type}'" unless VALID_TYPES.include?(@type)
    raise ArgumentError, "Invalid country: '#{@country}'" unless VALID_COUNTRIES.include?(@country)
  end
end
