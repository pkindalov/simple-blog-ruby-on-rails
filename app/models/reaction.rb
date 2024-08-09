# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :user
  belongs_to :reactionable, polymorphic: true

  validates :reaction_type, presence: true, inclusion: { in: %w[like love laugh wow sad angry] }
end
