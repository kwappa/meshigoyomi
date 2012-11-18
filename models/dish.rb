class Dish
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :eaten_at,          type: Time
  field :title,             type: String
  field :description,       type: String

  DISH_PHOTO_ROOT = '/dishes'

  def photo_url
    "#{DISH_PHOTO_ROOT}/#{user.user_name}/#{photo_dirname}/#{photo_filename}"
  end

  def photo_filename
    Digest::SHA256.hexdigest(user.user_name + created_at.to_s) + '.jpg'
  end

  def photo_dirname
    created_at.to_i.to_s.slice(0 .. 3)
  end

  def photo_dir
    Padrino.root('public', DISH_PHOTO_ROOT, user.user_name, photo_dirname)
  end
end
