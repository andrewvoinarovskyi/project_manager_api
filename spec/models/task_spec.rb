require 'rails_helper'

RSpec.describe Task, type: :model do
  it "has a valid factory" do
    expect(build(:task)).to be_valid
  end

  it "is invalid without a title" do
    task = build(:task, title: nil)
    expect(task).not_to be_valid
  end

  it "belongs_to :project" do
    assoc = described_class.reflect_on_association(:project)
    expect(assoc.macro).to eq(:belongs_to)
  end

  it "defines enum statuses correctly" do
    expect(Task.statuses.keys).to match_array(["new", "in_progress", "done"])
  end
end
