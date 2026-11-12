# frozen_string_literal: true

require 'rails_helper'

describe MapController do
  before do
    # TODO: It would be good to move these to factories.
    @california = State.create({ name: 'California', symbol: 'CA', fips_code: 6,
                            is_territory: 0, lat_min: 32.30, lat_max: 40.00,
                            long_min: 114.8, long_max: 124.24 })
    @washington = State.create({ name: 'Washington', symbol: 'WA', fips_code: 53,
                            is_territory: 0, lat_min: 32.30, lat_max: 40.00,
                            long_min: 114.8, long_max: 124.24 })

    @alameda = @california.counties.create({ name: 'Alameda', fips_code: 1, fips_class: 'CA' })
    @alpine = @california.counties.create({ name: 'Alpine', fips_code: 3, fips_class: 'CA' })
  end

  describe 'GET index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @states' do
      get :index
      expect(assigns(:states)).to eq(State.all)
    end

    it 'assigns @states_by_fips_code' do
      get :index
      expect(assigns(:states_by_fips_code)).to eq(State.all.index_by(&:std_fips_code))
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET state' do
    it 'returns a successful response' do
      get :state, params: { use_route: '/state/', state_symbol: 'CA' }
      expect(response).to be_successful
    end

    it 'assigns @state' do
      get :state, params: { use_route: '/state/', state_symbol: 'CA' }
      expect(assigns(:state)).to eq(@california)
    end

    it 'assigns @county_details' do
      get :state, params: { use_route: '/state/', state_symbol: 'CA' }
      expect(assigns(:county_details)).to eq(@california.counties.index_by(&:std_fips_code))
    end

    it 'redirects to home page if invalid state' do
      get :state, params: { use_route: '/state/', state_symbol: 'XX' }
      expect(response).to redirect_to root_path
    end
  end

  describe 'GET county' do
    before { allow(Representative).to receive(:geocodio_search).and_return(nil) }

    it 'returns a successful response' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA',
std_fips_code: '001' }
      expect(response).to be_successful
    end

    it 'assigns @state' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA',
std_fips_code: '001' }
      expect(assigns(:state)).to eq(@california)
    end

    it 'assigns @county' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA',
std_fips_code: '001' }
      expect(assigns(:county)).to eq(@alameda)
    end

    it 'assigns @county_details' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA',
std_fips_code: '001' }
      expect(assigns(:county_details)).to eq(@california.counties.index_by(&:std_fips_code))
    end

    it 'redirects to home page if invalid state' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'XX',
std_fips_code: '001' }
      expect(response).to redirect_to root_path
    end

    context 'when loading representatives' do
      let(:geocodio_response) do
        legislator = { 'type'       => 'representative',
                       'bio'        => { 'first_name' => 'Barbara', 'last_name' => 'Lee' },
                       'references' => { 'govtrack_id' => '400237' } }
        fields = { 'congressional_districts' => [{ 'current_legislators' => [legislator] }] }
        { 'results' => [{ 'response' => { 'results' => [{ 'fields' => fields }] } }] }
      end
      let(:county_params) { { state_symbol: 'CA', std_fips_code: '001' } }

      it 'searches Geocodio with the county and state' do
        allow(Representative).to receive(:geocodio_search).and_return(geocodio_response)
        get :county, params: county_params
        expect(Representative).to have_received(:geocodio_search).with('Alameda, CA')
      end

      it 'assigns the representatives for the county' do
        allow(Representative).to receive(:geocodio_search).and_return(geocodio_response)
        get :county, params: county_params
        expect(assigns(:representatives).map(&:name)).to eq(['Barbara Lee'])
      end

      it 'assigns an empty list when the lookup fails' do
        allow(Representative).to receive(:geocodio_search).and_raise(StandardError, 'API down')
        get :county, params: county_params
        expect(assigns(:representatives)).to eq([])
      end
    end
  end
end
