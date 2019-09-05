# frozen_string_literal: true

require "shared_examples/local"
require "shared_examples/cacheable"

RSpec.describe IronBank::Resources::ProductRatePlanCharge do
  let(:id) { "a-zuora-product-rate-plan-charge-id" }

  it_behaves_like "a resource with local records"
  it_behaves_like "a cacheable resource"
end
