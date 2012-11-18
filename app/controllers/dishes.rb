# -*- coding: utf-8 -*-
Meshigoyomi.controllers :dishes do
  get :new do
    @page_title = 'あたらしいごはん'
    render :'/dishes/new'
  end

  post :confirm do
    @page_title = 'あたらしいごはん'
    tupper = prepare_tupper

    if params.fetch('photo', []).empty?
      flash[:warning] = '写真がアップロードされていません。'
      return render :'/dishes/new'
    end

    begin
      tupper.upload params['photo']
      if %r{jpe?g}i !~ File.extname(tupper.file_info['uploaded_file'])
        logger.debug tupper.file_info
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
      render :'/dishes/confirm', locals: { preview_url: preview_url }
    else
      flash[:warning] = '写真がアップロードされていません。'
      render :'/dishes/dishes'
    end
  end

  post :new do
    tupper = prepare_tupper
    logger.debug tupper.file_info
    flash[:info] = 'あたらしいごはんを登録しました。'
    redirect :'/dishes/new'
  end
end