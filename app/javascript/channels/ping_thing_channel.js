import consumer from "./consumer"

consumer.subscriptions.create("PingThingChannel", {
  connected() {
    console.log("Connected to the room!");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log(data)
  }
});
