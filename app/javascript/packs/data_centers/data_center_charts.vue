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
                  :chart_by="chart_by_or_default()"
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
                :chart_by="chart_by_or_default()"
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
    props:{
      chart_by: {
        type: String,
        required: false,
        default: 'stake'
      }
    },

    data() {
      return {
        data_centers: [],
      }
    },

    created() {
      axios.get('/api/v1/data-center-stats/' + this.network + '?secondary_sort=' + this.chart_by)
           .then(response => {
             this.data_centers = response.data;
           })
    },

    computed: mapGetters([
      'network'
    ]),

    components: {
      pieChart
    },

    methods: {
      chart_by_or_default() {
        return this.chart_by === 'count' ? 'count' : 'stake';
      }
    }
  }
</script>
