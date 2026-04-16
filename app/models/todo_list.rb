class TodoList < ApplicationRecord
  STALE_LIMIT = 1.week

  has_many :todo_items

  validates :name, presence: true
end