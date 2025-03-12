class Task < ApplicationRecord
  belongs_to :project

  enum status: { new: 0, in_progress: 1, done: 2 }, _prefix: :status

  validates :title, presence: true
  validates :status, presence: true
end
