# frozen_string_literal: true

require 'rails_helper'

describe NewsItem do
  let(:representative) { Representative.create!(name: 'Alex Padilla', title: 'senator', ocdid: '456791') }

  describe '.find_for' do
    it 'returns the news item for the representative' do
      item = described_class.create!(title: 'Floor speech', link: 'https://example.com/speech',
                                     representative: representative)
      expect(described_class.find_for(representative.id)).to eq(item)
    end

    it 'returns nil when the representative has no news items' do
      expect(described_class.find_for(representative.id)).to be_nil
    end
  end
end
