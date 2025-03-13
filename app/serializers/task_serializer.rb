class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :status
  belongs_to :project
end
