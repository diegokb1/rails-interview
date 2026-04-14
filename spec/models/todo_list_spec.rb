require 'rails_helper'

RSpec.describe TodoList, type: :model do
  context 'validations' do
    it { should validate_presence_of(:name) }
    
  end

  context 'relations' do
    it { should have_many(:todo_items) }
  end
end
