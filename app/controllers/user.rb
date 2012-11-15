# -*- coding: utf-8 -*-
Meshigoyomi.controllers :user do
  get :new do
    @page_title = '新規登録'
    render :'/user/new'
  end

  post :confirm do
    @page_title = '登録情報の確認'
  end

  post :new do
  end
end
