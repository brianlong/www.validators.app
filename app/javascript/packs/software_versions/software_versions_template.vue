<template>
  <section class="col-lg-6 mb-4">
    <div class="card h-100">
      <div class="card-content pb-0">
        <h2 class="h4 card-heading">Software Versions</h2>
        <div v-if="this.is_loading" class="text-center text-muted pb-4">
          loading...
        </div>
      </div>

      <table class="table" v-if="!this.is_loading">
        <thead>
        <tr>
          <th>Software Version</th>
          <th>Stake %</th>
          <th>No. of validators</th>
        </tr>
        </thead>
        <tbody>
          <tr v-for="version in Object.keys(software_versions).slice(0, 6)" :key="version">
            <td :class="software_version_class(version)">
              <a :href="software_version_link(version)" title="Click to show validators with this version">
                {{ version }}
              </a>
            </td>
            <td :class="software_version_class(version)">
              {{ software_versions[version].stake_percent }}%
            </td>
            <td :class="software_version_class(version)">
              {{ software_versions[version].count }}
            </td>
          </tr>
        </tbody>
      </table>

      <div class="px-3 pb-3 text-center" v-if="Object.keys(software_versions).length > 6">
        <a data-bs-toggle="modal" data-bs-target="#versionsModal" class="text-muted" href="">
          Show older versions
        </a>
      </div>

      <div class="modal modal-large modal-top fade" id="versionsModal" tabindex="-1" role="dialog"
           aria-labelledby="versionsModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <h6 class="modal-title">All active validators</h6>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>

            <div class="modal-body p-0">
              <table class="table table-condensed mb-0">
                <thead>
                <tr>
                  <th>Software Version</th>
                  <th>Stake %</th>
                  <th>No. of validators</th>
                </tr>
                </thead>
                <tbody>
                <tr v-for="version in Object.keys(software_versions)" :key="version">
                  <td :class="software_version_class(version)">
                    <a :href="software_version_link(version)" title="Click to show validators with this version">
                      {{ version }}
                    </a>
                  </td>
                  <td :class="software_version_class(version)">
                    {{ software_versions[version].stake_percent }}%
                  </td>
                  <td :class="software_version_class(version)">
                    {{ software_versions[version].count }}
                  </td>
                </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
  import { mapGetters } from 'vuex'

  export default {
    data() {
      return {
        software_versions: {},
        is_loading: true
      }
    },
    methods: {
      software_version_class(version){
        if(version == this.current_software_version) {
          return "h4 text-success"
        } else {
          return ""
        }
      },
      software_version_link(version){
        return '/validators?q=' + version + '&network=' + this.network
      }
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
          this.is_loading = false
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
