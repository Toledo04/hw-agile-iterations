# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id           :integer          not null, primary key
#  address      :string
#  name         :string
#  ocdid        :string
#  party        :string
#  phone_number :string
#  photo_url    :string
#  title        :string
#  website_url  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require 'rails_helper'

RSpec.describe Representative do
  let(:legislator) do
    {
      'type' => 'representative',
      'bio' => {
        'first_name' => 'Barbara',
        'last_name' => 'Lee',
        'party' => 'Democrat',
        'photo_url' => 'https://example.test/barbara-lee.jpg'
      },
      'contact' => {
        'address' => '123 Capitol Ave, Washington, DC 20510',
        'url' => 'https://lee.house.gov',
        'phone' => '202-555-0100'
      },
      'references' => { 'govtrack_id' => '400237', 'bioguide_id' => 'L000551' }
    }
  end

  let(:other_legislator) do
    {
      'type' => 'senator',
      'bio' => { 'first_name' => 'Alex', 'last_name' => 'Padilla', 'party' => 'Democrat' },
      'references' => { 'govtrack_id' => '456791', 'bioguide_id' => 'P000145' }
    }
  end

  def geocodio_response(*legislators)
    district = { 'current_legislators' => legislators.map(&:deep_dup) }
    fields = { 'congressional_districts' => [district] }
    { 'results' => [{ 'response' => { 'results' => [{ 'fields' => fields }] } }] }
  end

  describe '.civic_api_to_representative_params' do
    let(:expected_profile_details) do
      {
        address: '123 Capitol Ave, Washington, DC 20510',
        photo_url: 'https://example.test/barbara-lee.jpg',
        website_url: 'https://lee.house.gov',
        phone_number: '202-555-0100',
        party: 'Democrat'
      }
    end

    it 'saves profile details returned by Geocodio' do
      rep = described_class.civic_api_to_representative_params(geocodio_response(legislator)).first
      expect(rep.reload).to have_attributes(expected_profile_details)
    end

    context 'when Geocodio omits some optional profile details' do
      let(:expected_profile_details) do
        {
          address: '123 Capitol Ave, Washington, DC 20510',
          photo_url: nil,
          website_url: 'https://lee.house.gov',
          phone_number: nil,
          party: 'Democrat'
        }
      end

      let(:legislator) do
        {
          'type' => 'representative',
          'bio' => { 'first_name' => 'Barbara', 'last_name' => 'Lee', 'party' => 'Democrat' },
          'contact' => {
            'address' => '123 Capitol Ave, Washington, DC 20510',
            'url' => 'https://lee.house.gov'
          },
          'references' => { 'govtrack_id' => '400237', 'bioguide_id' => 'L000551' }
        }
      end

      it 'saves available fields and leaves missing ones nil' do
        rep = described_class.civic_api_to_representative_params(geocodio_response(legislator)).first
        expect(rep.reload).to have_attributes(expected_profile_details)
      end
    end

    it 'creates a representative the first time they are seen' do
      expect { described_class.civic_api_to_representative_params(geocodio_response(legislator)) }
        .to change(described_class, :count).by(1)
    end

    it 'stores the govtrack id as the ocdid' do
      rep = described_class.civic_api_to_representative_params(geocodio_response(legislator)).first
      expect(rep.ocdid).to eq('400237')
    end

    it 'does not create a duplicate when the same representative is searched again' do
      described_class.civic_api_to_representative_params(geocodio_response(legislator))
      expect { described_class.civic_api_to_representative_params(geocodio_response(legislator)) }
        .not_to change(described_class, :count)
    end

    it 'returns the existing record on a repeated search' do
      first = described_class.civic_api_to_representative_params(geocodio_response(legislator)).first
      again = described_class.civic_api_to_representative_params(geocodio_response(legislator)).first
      expect(again.id).to eq(first.id)
    end

    it 'keeps different representatives as separate records' do
      expect { described_class.civic_api_to_representative_params(geocodio_response(legislator, other_legislator)) }
        .to change(described_class, :count).by(2)
    end

    context 'when Geocodio does not return a govtrack id' do
      let(:legislator) do
        {
          'type' => 'representative',
          'bio' => { 'first_name' => 'Barbara', 'last_name' => 'Lee' },
          'references' => {}
        }
      end

      it 'does not create a duplicate when the same representative is searched again' do
        described_class.civic_api_to_representative_params(geocodio_response(legislator))
        expect { described_class.civic_api_to_representative_params(geocodio_response(legislator)) }
          .not_to change(described_class, :count)
      end

      it 'matches the existing record by name and title' do
        first = described_class.civic_api_to_representative_params(geocodio_response(legislator)).first
        again = described_class.civic_api_to_representative_params(geocodio_response(legislator)).first
        expect(again.id).to eq(first.id)
      end
    end
  end
end
