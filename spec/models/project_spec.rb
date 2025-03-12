require 'rails_helper'

RSpec.describe Project, type: :model do
  it "has a valid factory" do
    expect(build(:project)).to be_valid
  end

  it "is invalid without a title" do
    project = build(:project, title: nil)
    expect(project).not_to be_valid
  end

  it "belongs_to :user" do
    assoc = described_class.reflect_on_association(:user)
    expect(assoc.macro).to eq(:belongs_to)
  end

  it "has_many :tasks" do
    assoc = described_class.reflect_on_association(:tasks)
    expect(assoc.macro).to eq(:has_many)
  end
end
