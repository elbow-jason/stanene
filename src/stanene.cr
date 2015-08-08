require "./stanene/agent"
require "./stanene/message"

WAIT = 0.4 # seconds

puts "STARTING..."

agent_chan = Channel(Message).new
self_chan  = Channel(Int32 | Bool).new

increment_1   = Message.new(self_chan, :update, ->(x : Int32){ x + 1 }  )
increment_45  = Message.new(self_chan, :update, ->(x : Int32){ x + 45 } )
set_101       = Message.new(self_chan, :update, ->(x : Int32){ 101 }    )
stop          = Message.new(self_chan, :stop,   ->(x : Int32){ x }      )
living        = Message.new(self_chan, :alive?, ->(x : Int32){ x })
get_state     = Message.new(self_chan, :get,    ->(x : Int32){ x })

sleep(WAIT)

spawn { Agent.new(agent_chan, 0) }


sleep(WAIT)
agent_chan.send(increment_1)
puts self_chan.receive
# => 1

sleep(WAIT)
agent_chan.send(increment_1)
puts self_chan.receive
# => 2

sleep(WAIT)
agent_chan.send(increment_45)
puts self_chan.receive
# => 47

sleep(WAIT)
agent_chan.send(living)
puts self_chan.receive
# => true

sleep(WAIT)
agent_chan.send(get_state)
puts self_chan.receive
# => 47

sleep(WAIT)
agent_chan.send(set_101)
puts self_chan.receive
# => 101

sleep(WAIT)
agent_chan.send(stop)
puts self_chan.receive
# => 101
