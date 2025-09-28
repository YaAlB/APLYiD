# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CostCalculator do
  let(:pricing_data) do
    [
      {
        'notification_type' => 'sms',
        'prices' => { 'AU' => 0.50, 'NZ' => 0.45, 'UK' => 0.40 }
      },
      {
        'notification_type' => 'email',
        'prices' => { 'AU' => 0.10, 'NZ' => 0.08, 'UK' => 0.12 }
      }
    ]
  end

  let(:notification_logs) do
    [
      { 'company' => 'Apple', 'type' => 'sms', 'country' => 'AU' },
      { 'company' => 'Apple', 'type' => 'email', 'country' => 'NZ' },
      { 'company' => 'Google', 'type' => 'sms', 'country' => 'UK' },
      { 'company' => 'Apple', 'type' => 'sms', 'country' => 'AU' }
    ]
  end

  describe '#initialize' do
    it 'creates calculator with valid data' do
      calculator = CostCalculator.new(pricing_data, notification_logs)
      expect(calculator).to be_a(CostCalculator)
    end

    it 'handles JSON string input for logs' do
      calculator = CostCalculator.new(pricing_data, notification_logs.to_json)
      expect(calculator).to be_a(CostCalculator)
    end

    it 'raises error for invalid JSON in logs' do
      expect {
        CostCalculator.new(pricing_data, 'invalid json')
      }.to raise_error(ArgumentError, /Invalid JSON in notification logs/)
    end

    it 'raises error for invalid logs format' do
      expect {
        CostCalculator.new(pricing_data, { 'invalid' => 'format' })
      }.to raise_error(ArgumentError, 'Invalid notification logs format')
    end
  end

  describe '#calculate' do
    let(:calculator) { CostCalculator.new(pricing_data, notification_logs) }

    it 'calculates costs correctly for all companies' do
      result = calculator.calculate
      
      # Apple: 2 SMS to AU (2 * 0.50 = 1.00) + 1 Email to NZ (0.08) = 1.08
      # Google: 1 SMS to UK (0.40) = 0.40
      expect(result).to contain_exactly(
        {
          'company' => 'Apple',
          'notification_count' => 3,
          'cost' => 1.08
        },
        {
          'company' => 'Google',
          'notification_count' => 1,
          'cost' => 0.40
        }
      )
    end

    it 'sorts results by company name' do
      logs = [
        { 'company' => 'Zebra', 'type' => 'sms', 'country' => 'AU' },
        { 'company' => 'Apple', 'type' => 'sms', 'country' => 'AU' }
      ]
      
      calculator = CostCalculator.new(pricing_data, logs)
      result = calculator.calculate
      
      expect(result.first['company']).to eq('Apple')
      expect(result.last['company']).to eq('Zebra')
    end

    it 'excludes companies with no notifications' do
      logs = [
        { 'company' => 'Apple', 'type' => 'sms', 'country' => 'AU' }
      ]
      
      calculator = CostCalculator.new(pricing_data, logs)
      result = calculator.calculate
      
      expect(result.size).to eq(1)
      expect(result.first['company']).to eq('Apple')
    end

    context 'with empty logs' do
      it 'returns empty array' do
        calculator = CostCalculator.new(pricing_data, [])
        result = calculator.calculate
        
        expect(result).to eq([])
      end
    end

    context 'with malformed notification data' do
      let(:malformed_logs) do
        [
          { 'company' => 'Apple', 'type' => 'sms', 'country' => 'AU' },
          { 'company' => '', 'type' => 'sms', 'country' => 'AU' } # Invalid company
        ]
      end

      it 'raises error for invalid notification data' do
        expect {
          CostCalculator.new(pricing_data, malformed_logs)
        }.to raise_error(ArgumentError, "Invalid company: ''")
      end
    end
  end
end
