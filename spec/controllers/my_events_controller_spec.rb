# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MyEventsController do
  let(:user) { User.create!(uid: 'event-tester', provider: :github, first_name: 'Test', last_name: 'User') }
  let(:state) do
    State.create!(name: 'California', symbol: 'CA', fips_code: 6, is_territory: 0,
                  lat_min: 32.30, lat_max: 40.00, long_min: 114.8, long_max: 124.24)
  end
  let(:county) { state.counties.create!(name: 'Alameda', fips_code: 1, fips_class: 'CA') }
  let(:event_attributes) do
    { name: 'Town hall', county_id: county.id, description: 'Meet with neighbors',
      start_time: 1.day.from_now, end_time: 2.days.from_now }
  end

  context 'when not logged in' do
    it 'redirects to login' do
      get :new

      expect(response).to redirect_to(login_url)
    end
  end

  context 'when logged in' do
    before { session[:user_id] = user.id }

    it 'renders the form when the start date is in the past' do
      post :create, params: { event: event_attributes.merge(start_time: 1.day.ago) }

      expect(response).to have_http_status(:ok)
      expect(assigns(:event).errors[:start_time]).to be_present
    end

    it 'renders the form when the end date is before the start date' do
      post :create, params: { event: event_attributes.merge(end_time: 1.hour.from_now) }

      expect(response).to have_http_status(:ok)
      expect(assigns(:event).errors[:end_time]).to be_present
    end
  end
end
