FactoryBot.define do
  factory :project do
    title { "Project #{rand(1000)}" }
    description { "Project description" }
    association :user
  end
end
