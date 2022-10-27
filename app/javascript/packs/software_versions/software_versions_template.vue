<template>
  <div class="col-md-7 col-lg-8 mb-4 pb-2 mt-4">
    <div class="card">
      <div class="card-content pb-0">
        <h2 class="h4 card-heading">Software Versions</h2>
      </div>

      <table class="table" v-if="this.software_versions">
        <thead>
        <tr>
          <th>Software Version</th>
          <th>Stake %</th>
          <th>No. of validators</th>
        </tr>
        </thead>
        <tbody>
          <tr v-for="version in Object.keys(this.software_versions)" :key="version">
            <td :class="version == current_software_version ? 'h4 text-success' : '' " >
              <a href="" title = "Click to show validators with this version"> {{ version }}</a>
            </td>
            <td :class="version == current_software_version ? 'h4 text-success' : '' ">
              {{ software_versions[version].stake_percent }}
            </td>
            <td :class="version == current_software_version ? 'h4 text-success' : '' ">
              {{ software_versions[version].count }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

</template>

<script>
  import { mapGetters } from 'vuex'

  export default {
    data() {
      return {
        software_versions: {}
      }
    },
    methods: {

    },
    channels: {
      SoftwareVersionsChannel: {
        connected() {},
        rejected() {},
        received(data) {
          var sw_formatted = {}
          data[this.network].forEach(v => {
            sw_formatted[Object.keys(v)[0]] = v[Object.keys(v)[0]]
          })
          this.software_versions = sw_formatted
        },
        disconnected() {},
      },
    },
    mounted: function(){
      this.$cable.subscribe({
          channel: "SoftwareVersionsChannel",
          room: "public",
        });
    },
    computed: {
      software_versions_keys: function() {
        console.log(Object.keys(this.software_versions))
        return Object.keys(this.software_versions)
      },
      current_software_version: function() {
        var current = null
        Object.keys(this.software_versions).forEach(sv => {
          if(!current || this.software_versions[current].stake_percent < this.software_versions[sv].stake_percent){
            current = sv
          }
        })
        return current
      },
      ...mapGetters([
        'network'
      ])

    }
  }
</script>
