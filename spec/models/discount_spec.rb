require 'rails_helper'


RSpec.describe Discount, type: :model do
  
  let!(:discount_percentage) do
    Discount.create(
      item_code: "test_percentage", 
      discount_type: "percentage",
      min_quantity: 3,
      discount_percentage: 30.0
      )
  end

    let!(:discount_volume) do
    Discount.create(
      item_code: "test_volume", 
      discount_type: "incremental_volume",
      increment_step: 10,
      discount_per_step: 2.0,
      max_percentage_discount: 30.0
      )
  end

  describe "#discounted_total_for_items" do
    subject do 
      discount.discounted_total_for_items(
        price: 10.0,
        item_code: test_code,
        num_items: test_num_items
        )
    end

    context "when discount type is percentage" do
      let(:discount) { discount_percentage }
      let(:test_code) { "test_percentage" }
      let(:test_num_items) { 3 }

      it "applies a discount since the num_items is 3 or more" do
        expect(subject).to eq(21.0)
      end

      context "when num_items is less than min_quantity" do
        let(:test_num_items) { 2 }

        it "does not apply discount" do
          expect(subject).to eq(20.0)
        end
      end

    end

    context "when discount type is volume" do
      let(:discount) { discount_volume }
      let(:test_code) { "test_volume" }
      let(:test_num_items) { 10 }

      it "applies a 2% discount since num_items is between 10 and 20, inclusive" do
        expect(subject).to eq(98.0)
      end

      context "when num_items is next increment" do
        let(:test_num_items) { 20 }

        it "applies a 4% discount since num_items is between 20 and 30" do
          expect(subject).to eq(192.0)
        end
      end
    end
  end
end