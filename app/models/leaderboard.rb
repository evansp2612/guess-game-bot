class Leaderboard < ApplicationRecord
  validates :user_id, :room, presence: true
end
