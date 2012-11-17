# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do
  before :all do
    described_class.delete_all
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
    let(:auth_user) { 'foo_user' }
    let(:auth_pass) { 'foo_user_password' }
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
end
