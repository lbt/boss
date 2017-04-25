class BOSSReceiver < Ruote::Amqp::Receiver

  #TODO: implement standard logger and error notifier instead of per process
  # specific code

  def decode_message(header, payload)

    item = super(header, payload)

    if item['error'] && item['fei']
        act = "that a participant has errored"
      elsif item['fields'] && item['fei']
        act = "to process workitem"
      elsif item['process_definition'] || item['definition']
        act = "to launch"
      else
        act = "something unknown - will now handle the error"
    end
    puts "Received amqp message: #{act}"

    item
  end
end

