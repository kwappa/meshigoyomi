Meshigoyomi.helpers do
  def user_info
    session[:user] || {}
  end

  def logged_in?
    !user_info.empty?
  end
end
