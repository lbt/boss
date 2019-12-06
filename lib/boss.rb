require 'boss/boss_store'
require 'boss/boss_viewer'
require 'boss/boss_receiver'
require 'boss/boss_registrar'
require 'boss/boss_participant'

class Boss
  @connection

  class << self
    attr_accessor :connection  # provide class methods for reading/writing
  end
end

