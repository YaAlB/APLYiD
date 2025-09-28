# frozen_string_literal: true

class CompanySummary
  attr_reader :company_name, :notifications, :total_cost

  def initialize(company_name)
    @company_name = company_name.to_s.strip
    @notifications = []
    @total_cost = 0.0

    raise ArgumentError, "Company name cannot be empty" if @company_name.empty?
  end

  def add_notification(notification)
    @notifications << notification
  end

  def calculate_cost!(pricing)
    @total_cost = @notifications.sum do |notification|
      pricing.cost_for(type: notification.type, country: notification.country)
    end
  end

  def notification_count
    @notifications.size
  end

  def count_by_type(type)
    @notifications.count { |n| n.type == type.to_s.downcase }
  end

  def count_by_country(country)
    @notifications.count { |n| n.country == country.to_s.upcase }
  end

  def to_hash
    {
      'company' => @company_name,
      'notification_count' => notification_count,
      'cost' => @total_cost
    }
  end

  def empty?
    @notifications.empty?
  end
end

