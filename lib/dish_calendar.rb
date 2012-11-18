# -*- coding: utf-8 -*-
class DishCalendar
  def self.monthly_range current_time = Time.now
    start_date = current_time.beginning_of_month
    end_date = (start_date + 1.month).beginning_of_month
    (start_date.utc .. end_date.utc) # query via Time must be utc
  end
end
