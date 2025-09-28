# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pricing do
  let(:valid_pricing_data) do
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

  describe '#initialize' do
    context 'with valid data' do
      it 'creates pricing with correct data' do
        pricing = Pricing.new(valid_pricing_data)
        
        expect(pricing.prices).to eq({
          'sms' => { 'AU' => 0.50, 'NZ' => 0.45, 'UK' => 0.40 },
          'email' => { 'AU' => 0.10, 'NZ' => 0.08, 'UK' => 0.12 }
        })
      end

      it 'handles JSON string input' do
        json_data = valid_pricing_data.to_json
        pricing = Pricing.new(json_data)
        
        expect(pricing.prices).to eq({
          'sms' => { 'AU' => 0.50, 'NZ' => 0.45, 'UK' => 0.40 },
          'email' => { 'AU' => 0.10, 'NZ' => 0.08, 'UK' => 0.12 }
        })
      end

      it 'normalizes country keys to uppercase' do
        data = [{ 'notification_type' => 'sms', 'prices' => { 'au' => 0.50 } }]
        pricing = Pricing.new(data)
        
        expect(pricing.prices['sms']).to eq({ 'AU' => 0.50 })
      end
    end

    context 'with invalid data' do
      it 'raises error for non-array data' do
        expect {
          Pricing.new({ 'invalid' => 'data' })
        }.to raise_error(ArgumentError, 'Pricing data must be an array')
      end

      it 'raises error for missing notification_type' do
        data = [{ 'prices' => { 'AU' => 0.50 } }]
        expect {
          Pricing.new(data)
        }.to raise_error(ArgumentError, 'Missing notification_type')
      end

      it 'raises error for missing prices' do
        data = [{ 'notification_type' => 'sms' }]
        expect {
          Pricing.new(data)
        }.to raise_error(ArgumentError, 'Missing prices for sms')
      end

      it 'raises error for empty pricing data' do
        expect {
          Pricing.new([])
        }.to raise_error(ArgumentError, 'No pricing data found')
      end

      it 'raises error for invalid JSON' do
        expect {
          Pricing.new('invalid json')
        }.to raise_error(ArgumentError, /Invalid JSON in pricing data/)
      end
    end
  end

  describe '#cost_for' do
    let(:pricing) { Pricing.new(valid_pricing_data) }

    it 'returns correct cost for valid type and country' do
      expect(pricing.cost_for(type: 'sms', country: 'AU')).to eq(0.50)
      expect(pricing.cost_for(type: 'email', country: 'NZ')).to eq(0.08)
    end

    it 'handles case insensitive input' do
      expect(pricing.cost_for(type: 'SMS', country: 'au')).to eq(0.50)
      expect(pricing.cost_for(type: 'Email', country: 'nz')).to eq(0.08)
    end

    it 'raises error for unknown type' do
      expect {
        pricing.cost_for(type: 'push', country: 'AU')
      }.to raise_error(ArgumentError, 'Unknown notification type: push')
    end

    it 'raises error for unknown country' do
      expect {
        pricing.cost_for(type: 'sms', country: 'US')
      }.to raise_error(ArgumentError, 'Unknown country: US')
    end
  end

  describe '#available_types' do
    let(:pricing) { Pricing.new(valid_pricing_data) }

    it 'returns all available notification types' do
      expect(pricing.available_types).to contain_exactly('sms', 'email')
    end
  end

  describe '#available_countries_for' do
    let(:pricing) { Pricing.new(valid_pricing_data) }

    it 'returns available countries for given type' do
      expect(pricing.available_countries_for('sms')).to contain_exactly('AU', 'NZ', 'UK')
      expect(pricing.available_countries_for('email')).to contain_exactly('AU', 'NZ', 'UK')
    end

    it 'handles case insensitive type' do
      expect(pricing.available_countries_for('SMS')).to contain_exactly('AU', 'NZ', 'UK')
    end

    it 'raises error for unknown type' do
      expect {
        pricing.available_countries_for('push')
      }.to raise_error(ArgumentError, 'Unknown notification type: push')
    end
  end
end
