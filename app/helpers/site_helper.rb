Meshigoyomi.helpers do
  def user_info
    session[:user] || {}
  end

  def logged_in?
    !user_info.empty?
  end

  def prepare_tupper
    Tupper.new(session).configure { |t| t.temp_dir = Padrino.root('public', 'images', 'tupper') }.tap{ |t| logger.debug t.temp_dir }
  end
end
