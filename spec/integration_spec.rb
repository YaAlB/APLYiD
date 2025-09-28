# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Integration Tests' do
  let(:pricing_file) { File.join(File.dirname(__FILE__), '..', 'data', 'notification_prices.json') }
  let(:logs_file) { File.join(File.dirname(__FILE__), '..', 'data', 'notification_logs.json') }

  describe 'with actual data files' do
    it 'processes real notification data correctly' do
      pricing_json = File.read(pricing_file)
      logs_json = File.read(logs_file)
      
      result = NotificationApp.call(pricing_json, logs_json)
      
      # Verify we get results for all companies in the data
      expect(result).to be_an(Array)
      expect(result.size).to eq(3) # Sharesies, Mighty Ape, TradeMe
      
      # Verify all companies are present
      company_names = result.map { |r| r['company'] }
      expect(company_names).to contain_exactly('Sharesies', 'Mighty Ape', 'TradeMe')
      
      # Verify each result has required fields
      result.each do |summary|
        expect(summary).to have_key('company')
        expect(summary).to have_key('notification_count')
        expect(summary).to have_key('cost')
        expect(summary['notification_count']).to be > 0
        expect(summary['cost']).to be >= 0
      end
    end

    it 'calculates correct costs for Sharesies' do
      pricing_json = File.read(pricing_file)
      logs_json = File.read(logs_file)
      
      result = NotificationApp.call(pricing_json, logs_json)
      sharesies = result.find { |r| r['company'] == 'Sharesies' }
      
      # Sharesies has: 1 SMS to AU (0.50) + 1 SMS to NZ (0.45) + 2 SMS to UK (2 * 0.40 = 0.80)
      # Total: 0.50 + 0.45 + 0.80 = 1.75
      expect(sharesies['notification_count']).to eq(4)
      expect(sharesies['cost']).to eq(1.75)
    end

    it 'calculates correct costs for Mighty Ape' do
      pricing_json = File.read(pricing_file)
      logs_json = File.read(logs_file)
      
      result = NotificationApp.call(pricing_json, logs_json)
      mighty_ape = result.find { |r| r['company'] == 'Mighty Ape' }
      
      # Mighty Ape has: 2 Email to NZ (2 * 0.08 = 0.16) + 1 SMS to AU (0.50)
      # Total: 0.16 + 0.50 = 0.66
      expect(mighty_ape['notification_count']).to eq(3)
      expect(mighty_ape['cost']).to eq(0.66)
    end

    it 'calculates correct costs for TradeMe' do
      pricing_json = File.read(pricing_file)
      logs_json = File.read(logs_file)
      
      result = NotificationApp.call(pricing_json, logs_json)
      trademe = result.find { |r| r['company'] == 'TradeMe' }
      
      # TradeMe has: 1 SMS to NZ (0.45) + 2 Email to NZ (2 * 0.08 = 0.16) + 1 SMS to NZ (0.45)
      # Total: 0.45 + 0.16 + 0.45 = 1.06
      expect(trademe['notification_count']).to eq(4)
      expect(trademe['cost']).to eq(1.06)
    end
  end

  describe 'rake task integration' do
    it 'can be called from rake task without errors' do
      pricing_json = File.read(pricing_file)
      logs_json = File.read(logs_file)
      
      # This simulates what the rake task does
      summaries = NotificationApp.call(pricing_json, logs_json)
      
      # Verify output format matches rake task expectations
      expect(summaries).to be_an(Array)
      summaries.each do |summary|
        expect(summary).to have_key('company')
        expect(summary).to have_key('notification_count')
        expect(summary).to have_key('cost')
      end
    end
  end
end


