class Agent
  getter inbox
  def initialize(channel : Channel, initial_state : T)
    puts "SPAWNING AGENT..."
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
