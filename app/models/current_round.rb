class CurrentRound < ApplicationRecord
  validates :question, :answer, :room, presence: true
end
