# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do
  before :all do
    described_class.delete_all
    # dummies for range queries
    foouser = described_class.create_by_params(valid_user_params.clone.merge('user_name' => 'foouser'))
    [
     { eaten_at: Time.new(2012, 10, 31) },
     { eaten_at: Time.new(2012, 11,  1) },
     { eaten_at: Time.new(2012, 11, 30) },
     { eaten_at: Time.new(2012, 12,  1) },
    ].each { |d| foouser.dishes.create(d) }
  end

  let(:valid_user_params) {
    {
      'user_name'    => 'hogeuser',
      'screen_name'  =>  'ほげ',
      'mail_address' => 'foo@example.com',
      'password'     => 'hogepiyo',
    }
  }

  describe '.validate_post_params' do
    context 'validates valid user_name' do
      subject { described_class.validate_post_params 'user_name' => 'foobar' }
      it { should_not include :user_name }
    end

    context 'validates duplicated user_name' do
      let(:duplicated_user_name) { 'duplicated_user_name' }
      before do
        described_class.new(user_name: duplicated_user_name, mail_address: '').save
      end
      subject { described_class.validate_post_params 'user_name' => duplicated_user_name }
      it { should include :user_name }
    end

    context 'validates too short user_name' do
      subject { described_class.validate_post_params 'user_name' => '_' }
      it { should include :user_name }
    end

    context 'validates valid mail_address' do
      subject { described_class.validate_post_params 'mail_address' => 'hoge@example.com' }
      it { should_not include :mail_address }
    end

    context 'validates invvalid mail_address' do
      subject { described_class.validate_post_params 'mail_address' => 'invalid_mail_address' }
      it { should include :mail_address }
    end

    context 'validates valid password and confim_password' do
      let(:valid_password) { 'valid_password' }
      subject { described_class.validate_post_params 'password' => valid_password, 'confim_password' => valid_password }
      it { should_not include :password }
    end

    context 'validates valid password but different confim_password' do
      let(:valid_password) { 'valid_password' }
      subject { described_class.validate_post_params 'password' => valid_password, 'confim_password' => valid_password + '_different' }
      it { should include :confirm_password }
    end

    context 'validates valid password but different confim_password' do
      subject { described_class.validate_post_params 'password' => 'ほげぴよ' }
      it { should include :password }
    end
  end

  describe '.create_by_params' do
    context 'when invalid pasword was given' do
      subject { described_class.create_by_params(valid_user_params.clone.store('password', 'short')) }
      it { should be_nil }
    end

    context 'with valid params' do
      subject { described_class.create_by_params valid_user_params }
      it { should be_instance_of described_class}
    end
  end

  describe '.authorize_by_params' do
    let(:auth_user) { 'auth_user' }
    let(:auth_pass) { 'auth_user_password' }
    before :all do
      @user = described_class.create_by_params(valid_user_params.clone.merge('user_name' => auth_user, 'password' => auth_pass))
    end

    context 'when user_name was not exist' do
      subject { described_class.authorize_by_params('user_name' => 'unknown', 'password' => auth_pass ) }
      it { should be_nil }
    end

    context 'when user_name was exist but password was wrong' do
      subject { described_class.authorize_by_params('user_name' => auth_user, 'password' => 'wrong_password' ) }
      it { should be_nil }
    end

    context 'when user_name and password were match' do
      subject { described_class.authorize_by_params('user_name' => auth_user, 'password' => auth_pass) }
      its(:attributes) { should == described_class.where(user_name: auth_user).first.attributes }
    end
  end

  let(:foouser)   { User.where(user_name: 'foouser').first }
  let(:sep_range) { DishCalendar.monthly_range(Time.new(2012,  9,  1)) }
  let(:oct_range) { DishCalendar.monthly_range(Time.new(2012, 10,  1)) }
  let(:nov_range) { DishCalendar.monthly_range(Time.new(2012, 11, 18)) }
  let(:dec_range) { DishCalendar.monthly_range(Time.new(2012, 12,  1)) }

  describe '#dishes_by_range' do
    context 'queries for Nov 2012' do
      subject { foouser.dishes_by_range nov_range }
      its(:count) { should == 2 }
    end

    context 'queries for Oct 2012' do
      subject { foouser.dishes_by_range oct_range }
      its(:count) { should == 1 }
    end

    context 'queries for Dec 2012' do
      subject { foouser.dishes_by_range dec_range }
      its(:count) { should == 1 }
    end
  end

  describe '#calendar_by_range' do
    context 'when range has no data' do
      subject { foouser.calendar_by_range sep_range }
      it 'should create blank calendar' do
        first_day = Date.new(2012,  9,  1)
        subject[first_day.cwday % 7].today.should == first_day
        subject.last.today.should  == Date.new(2012,  9, 30)
        subject.count { |s| s }.should == 30

        30.times do |c|
          subject[c + 6].today.day.should == c + 1
        end
      end
    end

    context 'when range has some data' do
      before :all do
        [
         { eaten_at: Time.new(2012,  9,  1) },
         { eaten_at: Time.new(2012,  9,  2), title: '9/2_first' },
         { eaten_at: Time.new(2012,  9,  2), title: '9/2_second' },
         { eaten_at: Time.new(2012,  9,  5) },
        ].each { |d| foouser.dishes.create(d) }
      end
      subject { foouser.calendar_by_range sep_range }
      it 'should create collect calendar' do
        subject.count { |s| s }.should == 30
      end
      it 'should have collect dishes' do
        subject.find { |s| s && s.today.day == 2 }.dishes.count.should == 2
      end
    end
  end

  describe '.daily_dishes_klass' do
    let(:dummy_date) { Date.new(2012, 11, 19) }
    subject { described_class.daily_dishes_klass dummy_date }
    its(:today) { should == dummy_date }
    its(:cwday) { should == 1 }

    context 'add new dish' do
      before do
        @daily_dishes = described_class.daily_dishes_klass dummy_date
        @daily_dishes.add 1
        @daily_dishes.add 2
      end
      specify { @daily_dishes.dishes.should == [1,2] }
    end
  end

  describe '#display_name' do

    before :all do
      param = valid_user_params.clone.merge('user_name' => 'noname_user')
      param.delete('screen_name')
      User.create param
      param.merge!('user_name' => 'html_user', 'screen_name' => '<b>strong name</b>')
      User.create param
    end
    context 'if user has no screen_name' do
      subject { User.where(user_name: 'noname_user').first }
      its(:screen_name)  { should be_nil }
      its(:display_name) { should == 'noname_user' }
    end

    context 'if user has screen_name with HTML special character' do
      subject { User.where(user_name: 'html_user').first }
      its(:display_name) { should == "&lt;b&gt;strong name&lt;/b&gt;" }
    end
  end
end
