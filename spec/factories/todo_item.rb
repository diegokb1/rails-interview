FactoryBot.define do
  factory :todo_item do
    description { Faker::Lorem.word }
    completed { false }
    external_id { SecureRandom.uuid }
    association :todo_list
  end
end
