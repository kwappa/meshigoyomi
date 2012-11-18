# -*- coding: utf-8 -*-
class DishCalendar
  def self.monthly_range current_time = Time.now
    start_date = current_time.beginning_of_month
    end_date = (start_date + 1.month).beginning_of_month
    (start_date .. end_date)
  end
end
