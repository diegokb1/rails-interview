FactoryBot.define do
  factory :todo_item do
    description { Faker::Lorem.word }
    completed { false}
    association :todo_list
  end
end
