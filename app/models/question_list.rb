class QuestionList < ApplicationRecord
  validates :question, uniqueness: true
end
