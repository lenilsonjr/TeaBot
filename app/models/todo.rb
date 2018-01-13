class Todo < ApplicationRecord

  validates_presence_of :todo, :username

end
