Meshigoyomi.helpers do
  def fetch_user
    User.where(user_name: user_info.fetch('user_name', '')).first
  end

  def user_info
    session[:user] || {}
  end

  def set_user_info attributes
    session[:user] = attributes
  end

  def clear_session
    session[:user] = nil
  end

  def logged_in?
    !user_info.empty?
  end

  def prepare_tupper
    Tupper.new(session).configure { |t| t.temp_dir = Padrino.root('public', 'images', 'tupper') }
  end

  def get_repare_params
    result = JSON.parse(session[:repare_params] || '{}')
    session.delete(:repare_params)
    result
  end

  def set_repare_params params
    session[:repare_params] = params.to_json
  end
end
