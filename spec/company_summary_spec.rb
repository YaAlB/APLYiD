# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CompanySummary do
  let(:company_name) { 'Apple' }
  let(:summary) { CompanySummary.new(company_name) }
  let(:pricing) do
    Pricing.new([
      {
        'notification_type' => 'sms',
        'prices' => { 'AU' => 0.50, 'NZ' => 0.45, 'UK' => 0.40 }
      },
      {
        'notification_type' => 'email',
        'prices' => { 'AU' => 0.10, 'NZ' => 0.08, 'UK' => 0.12 }
      }
    ])
  end

  describe '#initialize' do
    it 'creates summary with correct company name' do
      expect(summary.company_name).to eq('Apple')
      expect(summary.notification_count).to eq(0)
      expect(summary.total_cost).to eq(0.0)
    end

    it 'strips whitespace from company name' do
      summary = CompanySummary.new('  Apple  ')
      expect(summary.company_name).to eq('Apple')
    end

    it 'raises error for empty company name' do
      expect {
        CompanySummary.new('')
      }.to raise_error(ArgumentError, 'Company name cannot be empty')
    end
  end

  describe '#add_notification' do
    let(:notification) { Notification.new(company: 'Apple', type: 'sms', country: 'AU') }

    it 'adds notification to the summary' do
      summary.add_notification(notification)
      
      expect(summary.notification_count).to eq(1)
      expect(summary.notifications).to include(notification)
    end

    it 'can add multiple notifications' do
      notification2 = Notification.new(company: 'Apple', type: 'email', country: 'NZ')
      
      summary.add_notification(notification)
      summary.add_notification(notification2)
      
      expect(summary.notification_count).to eq(2)
    end
  end

  describe '#calculate_cost!' do
    before do
      summary.add_notification(Notification.new(company: 'Apple', type: 'sms', country: 'AU'))
      summary.add_notification(Notification.new(company: 'Apple', type: 'email', country: 'NZ'))
    end

    it 'calculates total cost correctly' do
      summary.calculate_cost!(pricing)
      
      # SMS to AU: 0.50, Email to NZ: 0.08
      expect(summary.total_cost).to eq(0.58)
    end

    it 'can be called multiple times safely' do
      summary.calculate_cost!(pricing)
      first_cost = summary.total_cost
      
      summary.calculate_cost!(pricing)
      expect(summary.total_cost).to eq(first_cost)
    end
  end

  describe '#count_by_type' do
    before do
      summary.add_notification(Notification.new(company: 'Apple', type: 'sms', country: 'AU'))
      summary.add_notification(Notification.new(company: 'Apple', type: 'sms', country: 'NZ'))
      summary.add_notification(Notification.new(company: 'Apple', type: 'email', country: 'AU'))
    end

    it 'returns correct count for each type' do
      expect(summary.count_by_type('sms')).to eq(2)
      expect(summary.count_by_type('email')).to eq(1)
    end

    it 'handles case insensitive type' do
      expect(summary.count_by_type('SMS')).to eq(2)
    end
  end

  describe '#count_by_country' do
    before do
      summary.add_notification(Notification.new(company: 'Apple', type: 'sms', country: 'AU'))
      summary.add_notification(Notification.new(company: 'Apple', type: 'email', country: 'AU'))
      summary.add_notification(Notification.new(company: 'Apple', type: 'sms', country: 'NZ'))
    end

    it 'returns correct count for each country' do
      expect(summary.count_by_country('AU')).to eq(2)
      expect(summary.count_by_country('NZ')).to eq(1)
      expect(summary.count_by_country('UK')).to eq(0)
    end

    it 'handles case insensitive country' do
      expect(summary.count_by_country('au')).to eq(2)
    end
  end

  describe '#to_hash' do
    before do
      summary.add_notification(Notification.new(company: 'Apple', type: 'sms', country: 'AU'))
      summary.calculate_cost!(pricing)
    end

    it 'returns correct hash format' do
      hash = summary.to_hash
      
      expect(hash).to eq({
        'company' => 'Apple',
        'notification_count' => 1,
        'cost' => 0.50
      })
    end
  end

  describe '#empty?' do
    it 'returns true when no notifications' do
      expect(summary.empty?).to be true
    end

    it 'returns false when notifications exist' do
      summary.add_notification(Notification.new(company: 'Apple', type: 'sms', country: 'AU'))
      expect(summary.empty?).to be false
    end
  end
end


