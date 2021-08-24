import consumer from "./consumer"

consumer.subscriptions.create("WallChannel", {
  connected() {
    console.log("Connected to WallChannel");
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
   let wall = document.getElementById('wall');
   console.log(data)
    wall.innerHTML += "<p>Result: "+ data['message']['result'] + "</p>";
    // Called when there's incoming data on the websocket for this channel
  }
});
