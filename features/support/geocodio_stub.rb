# frozen_string_literal: true

require 'cucumber/rspec/doubles'

Before do
  allow(Representative).to receive(:geocodio_search).and_return(nil)
end
