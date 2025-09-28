# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NotificationApp do
  let(:pricing_json) do
    [
      {
        'notification_type' => 'sms',
        'prices' => { 'AU' => 0.50, 'NZ' => 0.45, 'UK' => 0.40 }
      },
      {
        'notification_type' => 'email',
        'prices' => { 'AU' => 0.10, 'NZ' => 0.08, 'UK' => 0.12 }
      }
    ].to_json
  end

  let(:logs_json) do
    [
      { 'company' => 'Apple', 'type' => 'sms', 'country' => 'AU' },
      { 'company' => 'Apple', 'type' => 'email', 'country' => 'NZ' },
      { 'company' => 'Google', 'type' => 'sms', 'country' => 'UK' }
    ].to_json
  end

  describe '.call' do
    it 'processes data and returns company summaries' do
      result = NotificationApp.call(pricing_json, logs_json)
      
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      
      apple_summary = result.find { |s| s['company'] == 'Apple' }
      google_summary = result.find { |s| s['company'] == 'Google' }
      
      expect(apple_summary).to eq({
        'company' => 'Apple',
        'notification_count' => 2,
        'cost' => 0.58 # SMS to AU (0.50) + Email to NZ (0.08)
      })
      
      expect(google_summary).to eq({
        'company' => 'Google',
        'notification_count' => 1,
        'cost' => 0.40 # SMS to UK
      })
    end

    it 'handles empty logs' do
      result = NotificationApp.call(pricing_json, [].to_json)
      expect(result).to eq([])
    end

    it 'propagates errors with context' do
      expect {
        NotificationApp.call('invalid json', logs_json)
      }.to raise_error(ArgumentError, /Invalid JSON in pricing data/)
    end
  end

  describe '#call' do
    let(:app) { NotificationApp.new(pricing_json, logs_json) }

    it 'returns the same result as class method' do
      class_result = NotificationApp.call(pricing_json, logs_json)
      instance_result = app.call
      
      expect(instance_result).to eq(class_result)
    end

    it 'handles errors gracefully' do
      app = NotificationApp.new('invalid', logs_json)
      
      expect {
        app.call
      }.to raise_error(ArgumentError, /Invalid JSON in pricing data/)
    end
  end
end
