FactoryBot.define do
  factory :task do
    title { "Task #{rand(1000)}" }
    description { "Task description" }
    status { "new" }
    association :project
  end
end
