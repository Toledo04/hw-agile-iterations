# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  description :text
#  end_time    :datetime
#  name        :string           not null
#  start_time  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  county_id   :integer          not null
#
# Indexes
#
#  index_events_on_county_id  (county_id)
#
require 'rails_helper'

describe Event do
  let(:state) do
    State.create!(name: 'California', symbol: 'CA', fips_code: 6, is_territory: 0,
                  lat_min: 32.30, lat_max: 40.00, long_min: 114.8, long_max: 124.24)
  end
  let(:county) { state.counties.create!(name: 'Alameda', fips_code: 1, fips_class: 'CA') }

  def build_event(start_time:, end_time:)
    described_class.new(name: 'Town hall', county: county, start_time: start_time, end_time: end_time)
  end

  it 'is valid when it starts in the future and ends after it starts' do
    event = build_event(start_time: 1.day.from_now, end_time: 2.days.from_now)
    expect(event).to be_valid
  end

  it 'is invalid when it starts in the past' do
    event = build_event(start_time: 1.day.ago, end_time: 1.day.from_now)
    event.validate
    expect(event.errors[:start_time]).to be_present
  end

  it 'is invalid when it ends before it starts' do
    event = build_event(start_time: 2.days.from_now, end_time: 1.day.from_now)
    event.validate
    expect(event.errors[:end_time]).to be_present
  end

  it 'gets its state from the county' do
    event = build_event(start_time: 1.day.from_now, end_time: 2.days.from_now)
    expect(event.state).to eq(state)
  end

  it 'lists the counties in its state by name' do
    event = build_event(start_time: 1.day.from_now, end_time: 2.days.from_now)
    expect(event.county_names_by_id).to eq({ 'Alameda' => county.id })
  end
end
