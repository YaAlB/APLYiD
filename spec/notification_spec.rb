# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Notification do
  describe '#initialize' do
    context 'with valid attributes' do
      it 'creates a notification with correct attributes' do
        notification = Notification.new(company: 'Apple', type: 'sms', country: 'AU')
        
        expect(notification.company).to eq('Apple')
        expect(notification.type).to eq('sms')
        expect(notification.country).to eq('AU')
      end

      it 'normalizes type to lowercase' do
        notification = Notification.new(company: 'Apple', type: 'SMS', country: 'AU')
        expect(notification.type).to eq('sms')
      end

      it 'normalizes country to uppercase' do
        notification = Notification.new(company: 'Apple', type: 'sms', country: 'au')
        expect(notification.country).to eq('AU')
      end

      it 'strips whitespace from company name' do
        notification = Notification.new(company: '  Apple  ', type: 'sms', country: 'AU')
        expect(notification.company).to eq('Apple')
      end
    end

    context 'with invalid attributes' do
      it 'raises error for empty company' do
        expect {
          Notification.new(company: '', type: 'sms', country: 'AU')
        }.to raise_error(ArgumentError, "Invalid company: ''")
      end

      it 'raises error for invalid type' do
        expect {
          Notification.new(company: 'Apple', type: 'push', country: 'AU')
        }.to raise_error(ArgumentError, "Invalid type: 'push'")
      end

      it 'raises error for invalid country' do
        expect {
          Notification.new(company: 'Apple', type: 'sms', country: 'US')
        }.to raise_error(ArgumentError, "Invalid country: 'US'")
      end
    end
  end

  describe '.from_hash' do
    it 'creates notification from hash data' do
      data = { 'company' => 'Apple', 'type' => 'sms', 'country' => 'AU' }
      notification = Notification.from_hash(data)
      
      expect(notification.company).to eq('Apple')
      expect(notification.type).to eq('sms')
      expect(notification.country).to eq('AU')
    end

    it 'handles symbol keys' do
      data = { company: 'Apple', type: 'sms', country: 'AU' }
      notification = Notification.from_hash(data)
      
      expect(notification.company).to eq('Apple')
      expect(notification.type).to eq('sms')
      expect(notification.country).to eq('AU')
    end
  end

  describe '#matches?' do
    let(:notification) { Notification.new(company: 'Apple', type: 'sms', country: 'AU') }

    it 'returns true for matching type and country' do
      expect(notification.matches?(type: 'sms', country: 'AU')).to be true
    end

    it 'returns false for different type' do
      expect(notification.matches?(type: 'email', country: 'AU')).to be false
    end

    it 'returns false for different country' do
      expect(notification.matches?(type: 'sms', country: 'NZ')).to be false
    end

    it 'handles case insensitive matching' do
      expect(notification.matches?(type: 'SMS', country: 'au')).to be true
    end
  end
end
