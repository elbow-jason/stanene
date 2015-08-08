# channelizer

class Agent
  getter inbox
  def initialize(channel : Channel, initial_state)
    @inbox = channel
    @state = initial_state
    @alive = true
    receive
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

struct Message
  property origin
  property command
  property procedure
  def initialize(@origin, @command, @procedure)
  end
end

puts "STARTING..."
agent_chan = Channel(Message).new
self_chan  = Channel(Int32 | Bool).new

increment_1   = Message.new(self_chan, :update, ->(x : Int32){ x + 1 }  )
increment_45  = Message.new(self_chan, :update, ->(x : Int32){ x + 45 } )
set_101       = Message.new(self_chan, :update, ->(x : Int32){ 101 }    )
stop          = Message.new(self_chan, :stop,   ->(x : Int32){ x }      )
living        = Message.new(self_chan, :alive?, ->(x : Int32){ x })


puts "SPAWNING AGENT..."
spawn { Agent.new(agent_chan, 0) }

agent_chan.send(increment_1)
puts self_chan.receive
# => 1

agent_chan.send(increment_1)
puts self_chan.receive
# => 2

agent_chan.send(increment_45)
puts self_chan.receive
# => 47

agent_chan.send(living)
puts self_chan.receive

agent_chan.send(set_101)
puts self_chan.receive
# => 101

agent_chan.send(stop)
puts self_chan.receive
# => 101
