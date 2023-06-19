<template>
  <div class="row">
    <div class="col-12">
      <div class="card h-100">
        <div class="card-header text-center">
          <h3 class="card-title">Data Center Stats</h3>
        </div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <pie-chart 
                :data_center_stats="data_centers['dc_by_country']"
                :chart_title="'Data Centers by Country'"
                v-if="data_centers['dc_by_country']"
              ></pie-chart>
            </div>
            <div class="col-md-6">
              <pie-chart 
                :data_center_stats="data_centers['dc_by_organization']"
                :chart_title="'Data Centers by Organization'"
                v-if="data_centers['dc_by_organization']"
              ></pie-chart>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from 'axios';
  import { mapGetters } from 'vuex';
  import pieChart from './pie_chart.js'


  axios.defaults.headers.get["Authorization"] = window.api_authorization;

  export default {
    data() {
      return {
        data_centers: []
      }
    },

    created() {
      axios.get('/api/v1/data-center-stats/' + this.network)
        .then(response => {
          this.data_centers = response.data;
        })
        .catch(error => {
          console.log(error);
        })
    },

    computed: mapGetters([
      'network'
    ]),

    components: {
      pieChart
    }
  }
</script>
