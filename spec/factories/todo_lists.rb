FactoryBot.define do
  factory :todo_list do
    name { Faker::Lorem.word }
    external_id { SecureRandom.uuid }
  end
end
