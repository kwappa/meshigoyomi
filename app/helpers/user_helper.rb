# -*- coding: utf-8 -*-
Meshigoyomi.helpers do
  def validation_message name
    message = (@result || {}).fetch(name, '')
    unless message.empty?
      %Q|<span class="validation-message">#{message}</span>|
    end
  end
end
