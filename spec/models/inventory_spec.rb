require 'rails_helper'


RSpec.describe Inventory, type: :model do
  
  let!(:inventory) do
    Inventory.create(
      code: "test_code", 
      name: "test_name",
      price: 1.23
      )
  end

  describe "#update_price" do
    subject do 
      inventory.update_price("456.123")
    end

    it "" do
      expect(subject).to be_truthy
      
    end

    it "" do
      subject
      expect(inventory.price).to eq(456.123)
    end
  end
end