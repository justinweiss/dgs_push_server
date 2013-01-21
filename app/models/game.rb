class Game < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :player
end
