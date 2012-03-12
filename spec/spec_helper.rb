require 'rspec'
require 'active_record'
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require_relative '../database'
require_relative '../lib/user'
require_relative '../lib/application'
