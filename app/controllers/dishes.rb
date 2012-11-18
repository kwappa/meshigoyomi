# -*- coding: utf-8 -*-
Meshigoyomi.controllers :dishes do
  get :new do
    @page_title = 'あたらしいごはん'
    params.merge! get_repare_params
    render :'/dishes/new'
  end

  get :confirm do
    params.merge! get_repare_params
    render :'/dishes/confirm'
  end

  post :confirm do
    @page_title = 'あたらしいごはん'
    tupper = prepare_tupper
    set_repare_params(
                      eaten_at:    params['eaten_at'],
                      title:       params['title'],
                      description: params['description'],
                      )

    if params.fetch('photo', []).empty?
      flash[:warning] = '写真がアップロードされていません。'
      redirect url(:dishes, :new)
    end

    begin
      tupper.upload params['photo']
      if %r{jpe?g}i !~ File.extname(tupper.file_info['uploaded_file'])
        tupper.cleanup
        flash[:warning] = "写真はjpegだけですよ"
        redirect url(:dishes, :new)
      end
    rescue Tupper::FileSizeError
      tupper.cleanup
      flash[:warning] = "写真のファイルサイズは#{tupper.mas_size}MBまでです。"
      redirect url(:dishes, :new)
    rescue => e
      tupper.cleanup
      logger.debug e.message
      logger.debug e.backtrace
      halt 500
    end

    if tupper.has_uploaded_file?
      preview_url = File.join('/images', 'tupper', File.basename(tupper.file_info['uploaded_file']))
      session_params = get_repare_params.merge!(preview_url: preview_url)
      set_repare_params(session_params)
      redirect url(:dishes, :confirm)
    else
      flash[:warning] = '写真がアップロードされていません。'
      redirect url(:dishes, :new)
    end
  end

  post :new do
    tupper = prepare_tupper
    unless tupper.has_uploaded_file?
      flash[:warning] = '写真がアップロードされていません。'
      redirect url(:dishes, :new)
    end

    unless (user = fetch_user)
      tupper.clean_up
      clear_session
      flash[:error] = 'ログイン状態が確認できませんでした。'
      redirect url(:index, :index)
    end

    dish = user.dishes.create(
                              eaten_at:    Time.parse(params['eaten_at']),
                              title:       params['title'],
                              description: params['description'],
                              )
    photo_dir  = dish.photo_dir
    photo_file = File.join(photo_dir, dish.photo_filename)
    FileUtils.mkdir_p(photo_dir)
    FileUtils.mv(tupper.uploaded_file, photo_file)
    FileUtils.chmod(0664, photo_file)

    flash[:info] = 'あたらしいごはんを登録しました。'
    redirect :'/dishes/new'
  end
end
