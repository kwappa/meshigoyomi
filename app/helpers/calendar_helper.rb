Meshigoyomi.helpers do
  def gravatar_url mail_address
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(mail_address)}"
  end
end
