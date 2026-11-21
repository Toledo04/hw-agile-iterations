# frozen_string_literal: true

require 'spec_helper'
# require 'congress_api'

RSpec.describe Congress::Client do
  it 'errors without an api key' do
    expect { described_class.new(nil) }.to raise_error(ArgumentError)
  end

  it 'can be initialized' do
    expect(described_class.new('test')).not_to be_nil
  end

  it 'requests summaries for a bill' do
    client = described_class.new('test')
    allow(client).to receive(:get).and_return({ 'summaries' => [] })

    client.bill_summaries(congress: 119, bill_type: 'hr', bill_number: 123)

    expect(client).to have_received(:get).with('bill/119/hr/123/summaries', {})
  end
end
