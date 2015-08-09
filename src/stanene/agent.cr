require "./stanene/message"

class Agent
  getter inbox
  def initialize
    @alive = false
  end

  def start(initial_state : T)
    @channel_type = T
    @inbox        = Channel(Message).new
    @outbox       = Channel(T | Message).new
    @state        = initial_state
    @alive        = true
    spawn { receive }
  end

  def send(message : Message)
    @inbox.send(message)
    :ok
  end

  def get_response
    @outbox.receive
  end



  def receive
    puts "RECIEVING..."
    loop do
      message = @inbox.receive
      case message.command
      when :update
        puts "UPDATING."
        @state = message.procedure.call(@state)
        message.origin.send(@state)
      when :get
        puts "GETTING."
        message.origin.send(@state)
      when :alive?
        puts "AGENT ALIVE?"
        message.origin.send(@alive)
      when :stop
        puts "STOPPING AGENT."
        @alive = false
        message.origin.send(@state)
        break
      end
    end
  end
end
