# -*- coding: utf-8 -*-
require 'spec_helper'

describe Dish do
  before :all do
    Dish.delete_all
    User.delete_all
    User.create(
                'user_name'    => 'hogeuser',
                'screen_name'  =>  'ほげ',
                'mail_address' => 'foo@example.com',
                'password'     => 'hogepiyo',
                )
    @user = User.first
  end

  let(:dish_param) {
    {
      eaten_at:    "2012/11/08",
      title:       "たいとる",
      description: "ごは<b>ん</b>\r\n\r\nごはん"
    }
  }

  context 'adds new dish to user hogeuser' do
    before do
      @user.dishes.create dish_param
    end
    subject { @user.dishes.first }
    its(:title)    { should == dish_param[:title] }
    its(:eaten_at) { should == Time.parse(dish_param[:eaten_at]) }
  end

  context '#photo_url' do
    let(:dummy_time) { Time.new(2012, 11, 18) }
    let(:dir_name)   { dummy_time.to_i.to_s.slice(0 .. 3) }
    let(:file_name)  { Digest::SHA256.hexdigest(@user.user_name + dummy_time.to_s) + '.jpg' }

    before do
      @user.dishes.create
      @user.dishes.last.update_attributes(created_at: dummy_time)
    end
    subject { @user.dishes.last }
    its(:photo_url) { should == "/dishes/#{@user.user_name}/#{dir_name}/#{file_name}" }
  end
end
