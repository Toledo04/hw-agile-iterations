# frozen_string_literal: true

require 'rails_helper'

describe BillsController do
  let(:client) { instance_double(Congress::Client) }
  let(:api_response) do
    { 'bills'      => [{ 'type' => 'HR', 'number' => '123', 'title' => 'A test bill' }],
      'pagination' => { 'count' => 431_259 } }
  end

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

    it 'loads the 50 most recent bills when no search is given' do
      get :index
      expect(client).to have_received(:get).with('bill', { limit: 50 })
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
end
