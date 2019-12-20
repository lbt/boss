#!/usr/bin/env ruby

require 'ruote'

# TODO: move the classes to a different file/module?
module BOSS
  class Storage < Ruote::FsStorage

    attr_reader :number

    def initialize(dir, options={})

      @number = options.fetch("number", 0)
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

      msgs = get_many('msgs', priority, {:limit => limit, :noblock => true, :skip => limit * @number})
      msgs = get_many('msgs', nil, {:limit => limit, :noblock => true, :skip => limit * @number}) if msgs.empty? 
      msgs.sort_by { |d| d['put_at'] }
    end

  end
end
