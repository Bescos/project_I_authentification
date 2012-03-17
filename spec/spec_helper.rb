require 'rspec'
require 'active_record'
require 'rack/test'
require_relative '../s_auth'
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require_relative '../database'

