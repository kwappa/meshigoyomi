require_relative './lib_spec_helper'
require 'dish_calendar'

describe DishCalendar do
  describe '.monthly_range' do
    context 'creates range at Feb 2012' do
      subject { described_class.monthly_range Time.new(2012, 2, 12, 11, 15) }
      its(:begin) { should == Time.new(2012, 2, 1) }
      its(:end)   { should == Time.new(2012, 3, 1) }
    end
  end
end
