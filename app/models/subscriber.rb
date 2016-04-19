class Subscriber < ActiveRecord::Base
  validates :email, presence: true, format: /.+@.+/
end

