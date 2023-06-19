<template>
  <div class="row">
    <div class="col-md-6 mb-4">
      <div class="card h-100">
        <div class="card-content">
          <h2 class="h4 card-heading mb-3">DC By Country</h2>
            <div class="px-lg-3 px-xl-4">
              <pie-chart
                  :data_center_stats="data_centers['dc_by_country']"
                  :chart_title="'Data Centers by Country'"
                  v-if="data_centers['dc_by_country']"></pie-chart>
          </div>
        </div>
      </div>
    </div>
    <div class="col-md-6 mb-4">
      <div class="card h-100">
        <div class="card-content">
          <h2 class="h4 card-heading mb-3">DC By Organization</h2>
          <div class="px-lg-3 px-xl-4">
            <pie-chart
                :data_center_stats="data_centers['dc_by_organization']"
                :chart_title="'Data Centers by Organization'"
                v-if="data_centers['dc_by_organization']"></pie-chart>
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
