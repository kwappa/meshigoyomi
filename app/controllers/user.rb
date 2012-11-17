# -*- coding: utf-8 -*-
Meshigoyomi.controllers :user do
  get :new do
    @page_title = '新規登録'
    render :'/user/new'
  end

  post :confirm do
    unless (@result = User.validate_post_params params).empty?
      @page_title = '新規登録'
      logger.debug @result
      flash[:warning] = '入力項目に誤りがあります。'
      render :'/user/new'
    else
      @page_title = '登録情報の確認'
      render :'/user/confirm'
    end
  end

  post :new do
    user = User.create_by_params params
    halt 500 unless user
    flash[:info] = 'ユーザ登録が完了しました'
    redirect url(:index, :index)
  end

  post :login do
    logger.debug params
    if (user = User.authorize_by_params params)
      name = user.screen_name.empty? ? user.user_name : user.screen_name
      session[:user] = user.attributes
      flash[:info] = "#{name}さん、こんにちは！"
    else
      flash[:warning] = 'ユーザ名かパスワードが違います。'
    end
    redirect url(:index, :index)
 end

  get :logout do
    session[:user] = nil
    redirect url(:index, :index)
  end
end
