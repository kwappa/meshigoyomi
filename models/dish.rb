class Dish
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :eaten_at,          type: Time
  field :title,             type: String
  field :description,       type: String
  field :original_filename, type: String
end
