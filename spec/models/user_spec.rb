require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  it "has_many :projects" do
    assoc = described_class.reflect_on_association(:projects)
    expect(assoc.macro).to eq(:has_many)
  end
end
