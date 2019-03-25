#!/usr/bin/env ruby

require 'rubygems'
require 'amqp'
require 'yajl'
require 'ruote'
require 'ruote/storage/fs_storage'
require 'ruote-amqp'
require 'ruote-kit'

require 'pp'

# TODO: move the classes to a different file/module?
module Ruote
  class BOSSStorage < Ruote::FsStorage

    attr_reader :number

    def initialize(dir, options={})

      @number = options.fetch("number", 0)
      $stderr.puts "Storage #{@number}" if @number==1
      super(dir, options)
    end

    def prepare_msg_doc(action, options)

      # merge! is way faster than merge (no object creation probably)

      @counter ||= 0
      begin
        priority = options["workitem"]["fields"]["priority"]
      rescue
        priority = "normal"

      end

      t = Time.now.utc
      ts = "#{t.strftime('%Y-%m-%d')}!#{t.to_i}.#{'%06d' % t.usec}"
      _id = "#{$$}!#{Thread.current.object_id}!#{priority}!#{ts}!#{'%03d' % @counter}"

      @counter = (@counter + 1) % 1000
        # some platforms (windows) have shallow usecs, so adding that counter...

      msg = options.merge!('type' => 'msgs', '_id' => _id, 'action' => action)

      msg.delete('_rev')
        # in case of message replay

      msg
    end

    def get_msgs (limit, priority)

      #msgs = get_many('msgs', priority, {:limit => limit, :noblock => true, :skip => limit * @number})
      #msgs = get_many('msgs', nil, {:limit => limit, :noblock => true, :skip => limit * @number}) if msgs.empty? 

      #if @number > 1
      #  skip = (@number - 2)*limit
      #else
      #  skip = 0
      #end
      skip = 0
      flip = @number % 2 == 0
      $stderr.puts "Getting #{limit} messages from #{skip} (#{priority}) descending #{flip}"
      msgs = get_many('msgs', nil, {:limit => limit, :noblock => true, :skip => skip, :descending => flip})
      r = msgs.sort_by { |d| d['put_at'] }
      $stderr.puts "Got #{r.length} messages"
      r
    end

  end

  class BOSSWorker < Ruote::Worker

    attr_reader :priority
    attr_reader :number

    def initialize(storage=nil, options={})

      @priority = options.fetch("priority", "high")
      @number = options.fetch("number", 0)
      @roles = options.fetch("roles", [])
      $stderr.puts "Initialise worker number #{@number} roles #{@roles} " if @number==1
      super(storage)

    end

    def handle_step_error(e, msg)
      puts 'ruote step error: ' + e.inspect
      pp msg

    end

    def process_msgs

      $stderr.puts "Get messages #{@number} for roles #{@roles}" if @number==1
      @msgs = @storage.get_msgs(20, @priority) if @msgs.empty?
      if @msgs.length == 0
         $stderr.puts "sleeping"
         sleep(1)
      end
     

      while @msg = @msgs.pop

          r = process(@msg)

          if r != false
            @processed_msgs += 1
          end

          break if Time.now.utc - @last_time >= 0.8

      end
    end

    def take_a_rest

      return if @sleep_time == nil

      if @processed_msgs < 1

        @sleep_time += 0.01
        @sleep_time = 1.0 if @sleep_time > 1.0

        # $stderr.puts "Sleeping for #{@sleep_time}"
        sleep(@sleep_time)

      else

        @sleep_time = nil
      end
    end

    def step

      begin_step

      @msg = nil
      @processed_msgs = 0

      determine_state

      if @state == 'stopped'
        $stderr.puts "stopped" if @number==1
        return
      elsif @state == 'running'
        process_schedules if @roles.include? 'scheduler'
        process_msgs if @roles.include? 'worker'
      end

#      $stderr.puts "Sleep #{@sleep_time}" if @number==2
      take_a_rest # 'running' or 'paused'

    rescue => err

      handle_step_error(err, @msg) # msg may be nil
    end

  end
end
