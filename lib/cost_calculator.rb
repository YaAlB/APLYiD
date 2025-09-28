# frozen_string_literal: true

require 'json'
require_relative 'notification'
require_relative 'pricing'
require_relative 'company_summary'

class CostCalculator
  def initialize(pricing_data, notification_logs_data)
    @pricing = Pricing.new(pricing_data)
    @notifications = parse_notifications(notification_logs_data)
    @company_summaries = {}
  end

  def calculate
    process_notifications
    calculate_costs
    format_summaries
  end

  private

  def parse_notifications(logs_data)
    case logs_data
    when String
      JSON.parse(logs_data)
    when Array
      logs_data
    else
      raise ArgumentError, "Invalid notification logs format"
    end.map { |log| Notification.from_hash(log) }
  rescue JSON::ParserError => e
    raise ArgumentError, "Invalid JSON in notification logs: #{e.message}"
  end

  def process_notifications
    @notifications.each do |notification|
      company_name = notification.company
      
      @company_summaries[company_name] ||= CompanySummary.new(company_name)
      @company_summaries[company_name].add_notification(notification)
    end
  end

  def calculate_costs
    @company_summaries.each_value do |summary|
      summary.calculate_cost!(@pricing)
    end
  end

  def format_summaries
    @company_summaries.values
                      .reject(&:empty?)
                      .sort_by(&:company_name)
                      .map(&:to_hash)
  end
end
