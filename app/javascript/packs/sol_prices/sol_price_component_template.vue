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
  import axios from 'axios'

  export default {
    data() {
      return {
        connection: null,
        ftx_url: "https://ftx.com/markets/sol_usd"
      }
    },
    methods: {
      get_ftx_price() {
        axios.get(this.ftx_url, {
          headers: {
            'Access-Control-Allow-Origin': '*',
          }
        })
        .then(function (response){
          parsed_response = JSON.parse(response)
          console.log(parsed_response)
        })
      }
    },
    mounted(){
      this.get_ftx_price()
    }
  }
</script>
