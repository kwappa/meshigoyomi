# -*- coding: utf-8 -*-
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :dishes

  field :user_name,         type: String
  field :screen_name,       type: String
  field :mail_address,      type: String
  field :password_digest,   type: String
  field :salt,              type: String

  # http://blog.livedoor.jp/dankogai/archives/51189905.html
  EMAIL_REGEXP = %r{(^(?:(?:(?:(?:[a-zA-Z0-9_!#\$\%&'*+/=?\^`{}~|\-]+)(?:\.(?:[a-zA-Z0-9_!#\$\%&'*+/=?\^`{}~|\-]+))*)|(?:"(?:\\[^\r\n]|[^\\"])*")))\@(?:(?:(?:(?:[a-zA-Z0-9_!#\$\%&'*+/=?\^`{}~|\-]+)(?:\.(?:[a-zA-Z0-9_!#\$\%&'*+/=?\^`{}~|\-]+))*)|(?:\[(?:\\\S|[\x21-\x5a\x5e-\x7e])*\])))$)|(^$)}
  PASSWORD_REGEXP = %r{[\x21-\x7e]{8,32}}
  USER_NAME_REGEXP = %r{[0-9a-zA-Z_]{3,}}

  validates_presence_of     :user_name
  validates_uniqueness_of   :user_name
  validates_format_of       :user_name,    with: USER_NAME_REGEXP
  validates_format_of       :mail_address, with: EMAIL_REGEXP

  # TODO : ActiveModel::SecurePassword / has_secure_password

  def self.validate_post_params params
    result = Hash.new
    if where(user_name: params['user_name']).count > 0
      result.store :user_name, 'その名前はすでに使われています。'
    elsif USER_NAME_REGEXP !~ params['user_name']
      result.store :user_name, 'ユーザ名には3文字以上の英数字とアンダースコアが使えます。'
    end
    if EMAIL_REGEXP !~ params['mail_address']
      result.store :mail_address, 'メールアドレスが正しくありません。'
    end
    if PASSWORD_REGEXP !~ params['password']
      result.store :password, 'パスワードは8〜32文字の英数字と記号が使えます。'
    elsif params['password'] != params['confirm_password']
      result.store :confirm_password, '確認用のパスワードが一致しません。'
    end
    result
  end

  def self.create_by_params params
    return nil if PASSWORD_REGEXP !~ params['password']
    user = new(
               user_name:     params['user_name'],
               screen_name:   params['screen_name'],
               mail_address:  params['mail_address']
               )
    user.salt = Digest::MD5.hexdigest(params.to_s + Time.now.to_s)
    user.password_digest = digest_password params['password'], user.salt
    begin
      user.save!
    rescue => e
      logger.debug e.message
      logger.debug e.backtrace
      return nil
    end
    user
  end

  def self.digest_password password, salt
    Digest::HMAC.hexdigest(password, salt, Digest::SHA256)
  end

  def self.authorize_by_params params
    user = where(user_name: params['user_name']).first
    return nil unless user
    digest = digest_password params['password'], user.salt
    return nil unless digest == user.password_digest
    user
  end

  def display_name
    CGI.escapeHTML(screen_name.to_s.empty? ? user_name : screen_name)
  end

  def gravatar_url 
   "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest mail_address.to_s}?s=32"
  end

  def dishes_by_range range
    logger.debug range
    dishes.where(
                 :eaten_at.gte => range.begin.utc,
                 :eaten_at.lt  => range.end.utc
                 ).all
  end

  def calendar_by_range range
    calendar  = []
    first_day = range.begin.localtime.to_date
    last_day  = range.end.localtime.to_date - 1.day

    # 月初と月末を設定
    calendar[0]  = self.class.daily_dishes_klass first_day
    calendar[29] = self.class.daily_dishes_klass last_day

    # 該当日にdishを突っ込む
    dishes_by_range(range).each do |dish|
      today = dish.eaten_at.localtime
      idx   = today.day - 1
      dd    = calendar[idx] ||= self.class.daily_dishes_klass(today)
      dd.add dish
    end

    # データがない日も日付を入れる
    calendar.each_with_index do |cal, idx|
      unless cal
        calendar[idx] = self.class.daily_dishes_klass first_day + idx.days
      end
    end

    # 日曜開始にあわせる
    (calendar.first.cwday % 7).times do
      calendar.unshift nil
    end

    calendar
  end

  def self.daily_dishes_klass today
    dd = OpenStruct.new
    dd.today = today
    dd.dishes = []
    def dd.cwday
      today.cwday
    end
    def dd.add dish
      dishes.push dish
    end
    def dd.display_date
      today.strftime('%m/%d').gsub(%r{(^|/)0}, "\\1")
    end
    def dd.cell_class
      'current-month'
    end
    def dd.cell_bgstyle
      if (dishes || []).count > 0
        %Q{ style="background-image: url('#{photo_url}');"}
      else
        %Q{ style="filter:alpha(opacity=50); opacity:0.5; -moz-opacity:0.5; background-size: 30% auto;" }
      end
    end
    def dd.photo_url
      dishes.first.photo_url
    end
    def dd.photo_title
      dishes.first.title
    end
    def dd.has_dish?
      dishes && dishes.count > 0
    end
    dd
  end
end
