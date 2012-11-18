# -*- coding: utf-8 -*-
PADRINO_ENV  = 'test'
PADRINO_ROOT = File.expand_path('../..', __FILE__)
$: << File.join(PADRINO_ROOT, 'lib')

require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, PADRINO_ENV)

require 'rspec'

RSpec.configure do |conf|
  conf.mock_with :rr
  conf.include Rack::Test::Methods
end
