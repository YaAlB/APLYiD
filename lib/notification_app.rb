# frozen_string_literal: true

require 'json'
require_relative 'notification'
require_relative 'pricing'
require_relative 'company_summary'
require_relative 'cost_calculator'

class NotificationApp
  def self.call(pricing_json, logs_json)
    new(pricing_json, logs_json).call
  end

  def initialize(pricing_json, logs_json)
    @pricing_json = pricing_json
    @logs_json = logs_json
  end

  def call
    calculator = CostCalculator.new(@pricing_json, @logs_json)
    calculator.calculate
  rescue StandardError => e
    puts "Error processing notification data: #{e.message}"
    raise
  end
end
