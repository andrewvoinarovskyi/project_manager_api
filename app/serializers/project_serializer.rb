class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :title, :description
  has_many :tasks
end
