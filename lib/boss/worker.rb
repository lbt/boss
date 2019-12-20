#!/usr/bin/env ruby

require 'ruote'
require 'pp'

# TODO: move the classes to a different file/module?
module BOSS
  class Worker < Ruote::Worker

    attr_reader :priority
    attr_reader :number

    def initialize(storage=nil, options={})

      @priority = options.fetch("priority", "high")
      @number = options.fetch("number", 0)
      @roles = options.fetch("roles", [])

      super(storage)

    end

    def handle_step_error(e, msg)
      puts 'ruote step error: ' + e.inspect
      pp msg

    end

    def process_msgs

      @msgs = @storage.get_msgs(1, @priority) if @msgs.empty?

      while @msg = @msgs.pop

          r = process(@msg)

          if r != false
            @processed_msgs += 1
          end

          break if Time.now.utc - @last_time >= 0.8

      end
    end

    def step

      begin_step

      @msg = nil
      @processed_msgs = 0

      determine_state

      if @state == 'stopped'
        return
      elsif @state == 'running'
        process_schedules if @roles.include? 'scheduler'
        process_msgs if @roles.include? 'worker'
      end

      take_a_rest # 'running' or 'paused'

    rescue => err

      handle_step_error(err, @msg) # msg may be nil
    end

  end
end
