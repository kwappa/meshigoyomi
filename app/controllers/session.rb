# -*- coding: utf-8 -*-
Meshigoyomi.controllers :sessions do
  get :new do
    @page_title = '新規登録'
    render :'/sessions/new'
  end

  post :confirm do
    unless (@result = User.validate_post_params params).empty?
      @page_title = '新規登録'
      flash[:warning] = '入力項目に誤りがあります。'
      render :'/sessions/new'
    else
      @page_title = '登録情報の確認'
      render :'/sessions/confirm'
    end
  end

  post :new do
    user = User.create_by_params params
    halt 500 unless user
    flash[:info] = 'ユーザ登録が完了しました'
    redirect url(:index, :index)
  end

  post :login do
    if (user = User.authorize_by_params params)
      name = user.screen_name.empty? ? user.user_name : user.screen_name
      set_user_info user.attributes
      flash[:info] = "#{name}さん、こんにちは！"
    else
      flash[:warning] = 'ユーザ名かパスワードが違います。'
    end
    redirect url(:index, :index)
 end

  get :logout do
    clear_session
    redirect url(:index, :index)
  end
end
