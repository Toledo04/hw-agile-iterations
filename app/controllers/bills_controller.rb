# frozen_string_literal: true

class BillsController < ApplicationController
  BILL_TYPES = %w[hr s hjres sjres hconres sconres hres sres].freeze

  def index
    @bill_types = BILL_TYPES
    @congress = params[:congress].presence
    @bill_type = params[:bill_type].presence
    @bills = []
    return @error = 'Enter a congress number to search by bill type.' if @bill_type && @congress.nil?

    load_bills
  end

  private

  def load_bills
    data = congress_client.get(search_path, { limit: 50 })
    @bills = data['bills'] || []
    @total_count = data.dig('pagination', 'count') || @bills.size
  rescue Congress::Error, Faraday::Error => e
    @error = "Could not load bills from congress.gov: #{e.message}"
  end

  def search_path
    return 'bill' if @congress.nil?
    return "bill/#{@congress}" if @bill_type.nil?

    "bill/#{@congress}/#{@bill_type}"
  end

  def congress_client
    Congress::Client.new(Rails.application.credentials.congress_gov_api_key)
  end
end
