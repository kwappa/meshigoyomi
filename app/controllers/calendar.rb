Meshigoyomi.controllers :calendar do
  get :index, with: :user_name do
    user = User.where(user_name: params[:user_name]).first
    halt 404 unless user

    redirect url(:calendar, :index, params[:user_name], Date.today.year, Date.today.month)
  end

  get :index, with: [:user_name, :year, :month] do
    user = User.where(user_name: params[:user_name]).first
    halt 404 unless user

    begin
      current_time = Time.new(params[:year].to_i, params[:month].to_i)
    rescue
      halt 400
    end

    calendar = user.calendar_by_range(DishCalendar.monthly_range(current_time))

    # calendar.each do |cal|
    #   next unless cal
    #   logger.debug "#{cal.today} / #{cal.dishes}"
    # end
    @page_title = "#{user.display_name}"
    render :'/calendar/monthly', locals: { calendar: calendar }
  end
end
