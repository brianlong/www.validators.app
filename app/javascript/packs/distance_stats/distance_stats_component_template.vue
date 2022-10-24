<template>
  <div class="col-md-6 mb-4">
    <div class="card">
      <div class="card-content">
        <h2 class="h4 card-heading">Root Distance</h2>
        <div class="row px-3 px-xl-5 mb-md-2">
          <div class="stat col-5 my-auto">
            <small class="text-muted">Median:</small>
            <div class="h5 text-purple">
              <%= @stats[:root_distance][:median].to_i %>
            </div>
            <small class="text-muted">Average:</small>
            <div class="h5 text-purple">
              <%= number_to_human(@stats[:root_distance][:average].to_f.round(1), format:'%n%u', units: { thousand: 'K' ,
                million: 'M' , billion: 'B' }) %>
            </div>
          </div>
          <div class="stat col-7 my-auto px-0">
            <div class="text-muted">
              <i class="fas fa-long-arrow-alt-down text-purple"></i>Min &ndash;
              <i class="fas fa-long-arrow-alt-up text-purple"></i>Max:
            </div>
            <div class="stat-title-2 text-purple">
              <%= @stats[:root_distance][:min].to_i %> &ndash;
                <%= number_to_human(@stats[:root_distance][:max].to_i, format:'%n%u', units: { thousand: 'K' , million: 'M'
                  , billion: 'B' }) %>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="col-md-6 mb-4">
    <div class="card">
      <div class="card-content">
        <h2 class="h4 card-heading">Vote Distance</h2>
        <div class="row px-3 px-xl-5 mb-md-2">
          <div class="stat col-5 my-auto">
            <small class="text-muted">Median:</small>
            <div class="h5 text-purple">
              <%= @stats[:vote_distance][:median].to_i %>
            </div>
            <small class="text-muted">Average:</small>
            <div class="h5 text-purple">
              <%= number_to_human(@stats[:vote_distance][:average].to_f.round(1), format:'%n%u', units: { thousand: 'K' ,
                million: 'M' , billion: 'B' }) %>
            </div>
          </div>
          <div class="stat col-7 my-auto px-0">
            <div class="text-muted">
              <i class="fas fa-long-arrow-alt-down text-purple"></i>Min &ndash;
              <i class="fas fa-long-arrow-alt-up text-purple"></i>Max:
            </div>
            <div class="stat-title-2 text-purple">
              <%= @stats[:vote_distance][:min].to_i %> &ndash;
                <%= number_to_human(@stats[:vote_distance][:max].to_i, format:'%n%u', units: { thousand: 'K' , million: 'M'
                  , billion: 'B' }) %>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    data() {
      return {
      }
    },
    channels: {
      FrontStatsChannel: {
        connected() { },
        rejected() { },
        received(data) {
        },
        disconnected() { }
      }
    },
    mounted() {
      this.$cable.subscribe({
        channel: 'FrontStatsChannel',
        room: "public"
      });
    },
    methods: {
    },
  }
</script>
