require 'rails_helper'

RSpec.describe TodoItem, type: :model do
  context 'validations' do
    it { should validate_presence_of(:description) }
  end

  context 'relations' do
    it { should belong_to(:todo_list) }
  end
end
