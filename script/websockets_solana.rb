require_relative '../config/environment'

ws_method_wrapper = SolanaRpcRuby::WebsocketsMethodsWrapper.new

# Example of block that can be passed to the method to manipualte the data.
block = Proc.new do |message|
  json = JSON.parse(message)

  ActionCable.server.broadcast(
    "wall_channel",
    {
      message: json['params']
    }
  )
end

ws_method_wrapper.root_subscribe(&block)
