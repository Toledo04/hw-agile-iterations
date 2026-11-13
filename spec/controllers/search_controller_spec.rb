# frozen_string_literal: true

require 'rails_helper'

describe SearchController do
  let(:geocodio_response) do
    legislator = { 'type'       => 'senator',
                   'bio'        => { 'first_name' => 'Alex', 'last_name' => 'Padilla' },
                   'references' => { 'govtrack_id' => '456791' } }
    fields = { 'congressional_districts' => [{ 'current_legislators' => [legislator] }] }
    { 'results' => [{ 'response' => { 'results' => [{ 'fields' => fields }] } }] }
  end

  before { allow(Representative).to receive(:geocodio_search).and_return(geocodio_response) }

  describe 'GET search' do
    it 'looks up the address with Geocodio' do
      get :search, params: { address: 'Berkeley, CA' }
      expect(Representative).to have_received(:geocodio_search).with('Berkeley, CA')
    end

    it 'assigns the search term' do
      get :search, params: { address: 'Berkeley, CA' }
      expect(assigns(:search_term)).to eq('Berkeley, CA')
    end

    it 'assigns the representatives from the response' do
      get :search, params: { address: 'Berkeley, CA' }
      expect(assigns(:representatives).map(&:name)).to eq(['Alex Padilla'])
    end

    it 'renders the representatives search template' do
      get :search, params: { address: 'Berkeley, CA' }
      expect(response).to render_template('representatives/search')
    end
  end
end
