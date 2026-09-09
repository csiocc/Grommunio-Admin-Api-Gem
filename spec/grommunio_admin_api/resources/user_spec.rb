# frozen_string_literal: true

RSpec.describe GrommunioAdminApi::Resources::User do
  describe "#property" do
    let(:user) { described_class.new("properties" => { "storagequotalimit" => 5_242_880 }) }

    it "reads a property by its API string name" do
      expect(user.property("storagequotalimit")).to eq(5_242_880)
    end

    it "accepts a symbol name" do
      expect(user.property(:storagequotalimit)).to eq(5_242_880)
    end

    it "returns nil when the property bag is absent or null" do
      expect(described_class.new({}).property(:storagequotalimit)).to be_nil
      expect(described_class.new("properties" => nil).property(:storagequotalimit)).to be_nil
    end

    it "returns nil for an empty property bag on a shared mailbox" do
      mailbox = described_class.new("status" => 4, "properties" => {})

      expect(mailbox.property(:storagequotalimit)).to be_nil
    end

    it "returns nil for a property that is not present" do
      expect(user.property(:prohibitsendquota)).to be_nil
    end

    it "preserves zero and false property values" do
      values = described_class.new("properties" => { "storagequotalimit" => 0, "hidden" => false })

      expect(values.property(:storagequotalimit)).to eq(0)
      expect(values.property(:hidden)).to be(false)
    end
  end
end
