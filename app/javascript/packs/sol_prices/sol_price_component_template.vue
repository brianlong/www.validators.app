<template>
  <div class="card col-6">
    <div class="card-content">
      <div class="col-12">
        sol price 
      </div>
    </div>
  </div>
</template>

<script>
  import Vue from 'vue/dist/vue.esm'
  import VueWebsocket from "vue-websocket";
  Vue.use(VueWebsocket, "wss://ftx.com/ws");

  export default {
    data() {
      return {
        connection: null,
        ftx_url: "wss://ftx.com/ws?op=subscribe&channel=trades&market=BTC-PERP"
      }
    },
    methods: {
      get() {
        this.$socket.emit("get", {'op': 'subscribe', 'channel': 'trades', 'market': 'BTC-PERP'}, (response) => {
          console.log(response)
        });
      }
    },
    mounted(){
      this.get()
    },
    socket: {
            // Prefix for event names
            // prefix: "/counter/",

            // If you set `namespace`, it will create a new socket connection to the namespace instead of `/`
            // namespace: "/counter",

            events: {

                // Similar as this.$socket.on("changed", (msg) => { ... });
                // If you set `prefix` to `/counter/`, the event name will be `/counter/changed`
                //
                changed(msg) {
                    console.log("Something changed: " + msg);
                }

                /* common socket.io events
                connect() {
                    console.log("Websocket connected to " + this.$socket.nsp);
                },

                disconnect() {
                    console.log("Websocket disconnected from " + this.$socket.nsp);
                },

                error(err) {
                    console.error("Websocket error!", err);
                }
                */

            }
        }
  }
</script>
