# frozen_string_literal: true

require 'rails_helper'

describe BillsHelper do
  let(:bill) do
    { 'type'          => 'HR',
      'number'        => '123',
      'originChamber' => 'House',
      'latestAction'  => { 'actionDate' => '2024-04-06', 'text' => 'Became Public Law No: 117-108.' } }
  end

  describe '#bill_number_label' do
    it 'shows the bill type and number' do
      expect(helper.bill_number_label(bill)).to eq('HR 123')
    end
  end

  describe '#bill_type_name' do
    it 'shows the full name of the bill type' do
      expect(helper.bill_type_name(bill)).to eq('House Bill')
    end

    it 'falls back to the raw type when it is not known' do
      expect(helper.bill_type_name(bill.merge('type' => 'XYZ'))).to eq('XYZ')
    end
  end

  describe '#bill_last_action' do
    it 'shows the last action text followed by its date' do
      expect(helper.bill_last_action(bill)).to eq('Became Public Law No: 117-108 on Apr 6, 2024')
    end

    it 'shows only the text when there is no date' do
      no_date = bill.merge('latestAction' => { 'text' => 'Introduced in House' })
      expect(helper.bill_last_action(no_date)).to eq('Introduced in House')
    end

    it 'is empty when there is no last action' do
      expect(helper.bill_last_action(bill.except('latestAction'))).to eq('')
    end
  end
end
