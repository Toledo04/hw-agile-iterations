# frozen_string_literal: true

require 'rails_helper'

describe BillsController do
  let(:client) { instance_double(Congress::Client) }
  let(:api_response) do
    { 'bills'      => [{ 'type' => 'HR', 'number' => '123', 'title' => 'A test bill' }],
      'pagination' => { 'count' => 431_259 } }
  end
  let(:bill_params) { { congress: '119', bill_type: 'hr', number: '123' } }
  let(:bill_details) do
    { 'bill' => { 'congress' => 119, 'number' => 123, 'title' => 'A test bill',
                  'type' => 'HR', 'originChamber' => 'House' } }
  end
  let(:bill_summaries) { { 'summaries' => [{ 'text' => '<p>A bill summary.</p>' }] } }

  before do
    allow(Congress::Client).to receive(:new).and_return(client)
    allow(client).to receive(:get).and_return(api_response)
  end

  describe 'GET index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end

    it 'loads 50 bills from the current congress when no search is given' do
      get :index
      expect(client).to have_received(:get).with('bill/119', { limit: 50 })
    end

    it 'searches by congress' do
      get :index, params: { congress: '119' }
      expect(client).to have_received(:get).with('bill/119', { limit: 50 })
    end

    it 'searches by congress and bill type' do
      get :index, params: { congress: '119', bill_type: 'hr' }
      expect(client).to have_received(:get).with('bill/119/hr', { limit: 50 })
    end

    it 'assigns the bills from the response' do
      get :index
      expect(assigns(:bills).pluck('title')).to eq(['A test bill'])
    end

    it 'assigns the total count from the API' do
      get :index
      expect(assigns(:total_count)).to eq(431_259)
    end

    it 'does not call the API when a bill type is given without a congress' do
      get :index, params: { bill_type: 'hr' }
      expect(client).not_to have_received(:get)
    end

    it 'asks for a congress number when a bill type is given without one' do
      get :index, params: { bill_type: 'hr' }
      expect(assigns(:error)).to include('congress number')
    end

    it 'shows an error when the API fails' do
      allow(client).to receive(:get).and_raise(Congress::Error, 'Rate limit exceeded')
      get :index
      expect(assigns(:error)).to include('Rate limit exceeded')
    end
  end

  describe 'POST create' do
    before do
      allow(client).to receive_messages(bill_detail: bill_details, bill_summaries: bill_summaries)
    end

    it 'saves the bill and its API summary, then redirects to the bill page' do
      expect { submit_bill }.to change(Bill, :count).by(1)
      expect_saved_bill
    end

    it 'redirects to an existing bill instead of saving it twice' do
      existing = Bill.create!(title: 'A test bill', congress: 119, number: 123,
                              original_chamber: 'House', bill_type: 'hr', summary: 'Saved summary')

      expect { submit_bill }.not_to change(Bill, :count)
      expect(response).to redirect_to(bill_path(existing))
      expect(client).not_to have_received(:bill_detail)
    end

    it 'does not save a bill when the API has no summary' do
      allow(client).to receive(:bill_summaries).and_return({ 'summaries' => [] })

      expect { submit_bill }.not_to change(Bill, :count)
      expect_search_redirect('summary')
    end

    it 'does not save a bill when the API returns an error' do
      allow(client).to receive(:bill_summaries).and_raise(Congress::Error, 'Rate limit exceeded')

      expect { submit_bill }.not_to change(Bill, :count)
      expect_search_redirect('Rate limit exceeded')
    end

    def submit_bill
      post :create, params: bill_params
    end

    def expect_saved_bill
      bill = Bill.last
      expect(bill).to have_attributes(title: 'A test bill', congress: 119, number: 123,
                                      original_chamber: 'House', bill_type: 'hr',
                                      summary: '<p>A bill summary.</p>')
      expect(response).to redirect_to(bill_path(bill))
    end

    def expect_search_redirect(message)
      expect(response).to redirect_to(bills_path(congress: '119', bill_type: 'hr'))
      expect(flash[:alert]).to include(message)
    end
  end

  describe 'GET show' do
    render_views

    it 'displays all saved bill fields' do
      bill = Bill.create!(title: 'A test bill', congress: 119, number: 123, original_chamber: 'House',
                          bill_type: 'hr', summary: '<p>A bill summary.</p>')
      get :show, params: { id: bill.id }
      expect_bill_page
    end

    def expect_bill_page
      expect(response).to be_successful
      expect(response.body).to include('A test bill', '119', '123', 'House', 'HR', 'A bill summary.')
    end
  end

  describe 'GET saved' do
    render_views

    it 'lists saved bills with links to their detail pages' do
      bill = Bill.create!(title: 'Saved bill', congress: 119, number: 123,
                          original_chamber: 'House', bill_type: 'hr', summary: 'Saved summary')

      get :saved

      expect(response).to be_successful
      expect(response.body).to include('Saved bill', bill_path(bill))
    end
  end
end
