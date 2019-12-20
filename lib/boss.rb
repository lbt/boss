require 'rubygems'
require 'yajl'

require 'boss/store'
require 'boss/viewer'
require 'boss/receiver'
require 'boss/registrar'
require 'boss/participant'
require 'boss/worker'

class Boss
  @connection

  class << self
    attr_accessor :connection  # provide class methods for reading/writing
  end
end

