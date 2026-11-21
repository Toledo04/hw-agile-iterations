# frozen_string_literal: true

class BillsController < ApplicationController
  BILL_TYPES = %w[hr s hjres sjres hconres sconres hres sres].freeze
  CURRENT_CONGRESS = 119

  def index
    @bill_types = BILL_TYPES
    @congress = params[:congress].presence
    @bill_type = params[:bill_type].presence
    @bills = []
    return @error = 'Enter a congress number to search by bill type.' if @bill_type && @congress.nil?

    load_bills
  end

  def show
    @bill = Bill.find(params[:id])
  end

  def saved
    @bills = Bill.order(created_at: :desc)
  end

  def create
    selected_bill = params.permit(:congress, :bill_type, :number)
    unless selected_bill.values.all?(&:present?)
      return redirect_to bills_path, alert: 'Select a bill from the search results before saving.'
    end

    existing_bill = find_saved_bill(selected_bill)
    return redirect_to bill_path(existing_bill), notice: 'Bill already saved.' if existing_bill

    bill = build_bill(selected_bill)
    return redirect_to_bill_search(selected_bill) unless bill
    return redirect_to_bill_search(selected_bill, bill.errors.full_messages.to_sentence) unless bill.save

    redirect_to bill_path(bill), notice: 'Bill saved.'
  rescue Congress::Error, Faraday::Error => e
    redirect_to_bill_search(selected_bill, "Could not save this bill: #{e.message}")
  rescue ActiveRecord::RecordNotUnique
    redirect_to bill_path(find_saved_bill(selected_bill)), notice: 'Bill already saved.'
  end

  private

  def find_saved_bill(selected_bill)
    Bill.find_by(congress: selected_bill[:congress], bill_type: selected_bill[:bill_type].downcase,
                 number: selected_bill[:number])
  end

  def build_bill(selected_bill)
    congress = selected_bill[:congress]
    bill_type = selected_bill[:bill_type].downcase
    number = selected_bill[:number]
    details = congress_client.bill_detail(congress: congress, bill_type: bill_type, bill_number: number)
    summaries = congress_client.bill_summaries(congress: congress, bill_type: bill_type, bill_number: number)
    summary = summaries.fetch('summaries', []).first&.fetch('text', nil)

    return if summary.blank?

    bill_data = details['bill'] || {}
    Bill.new(
      title: bill_data['title'], congress: bill_data['congress'], number: bill_data['number'],
      original_chamber: bill_data['originChamber'], bill_type: bill_data['type'].to_s.downcase,
      summary: summary
    )
  end

  def redirect_to_bill_search(selected_bill, alert=nil)
    flash[:alert] = alert || 'This bill has no summary available and was not saved.'
    redirect_to bills_path(congress: selected_bill[:congress], bill_type: selected_bill[:bill_type])
  end

  def load_bills
    data = congress_client.get(search_path, { limit: 50 })
    @bills = data['bills'] || []
    @total_count = data.dig('pagination', 'count') || @bills.size
  rescue Congress::Error, Faraday::Error => e
    @error = "Could not load bills from congress.gov: #{e.message}"
  end

  def search_path
    return "bill/#{CURRENT_CONGRESS}" if @congress.nil?
    return "bill/#{@congress}" if @bill_type.nil?

    "bill/#{@congress}/#{@bill_type}"
  end

  def congress_client
    Congress::Client.new(Rails.application.credentials.congress_gov_api_key)
  end
end
