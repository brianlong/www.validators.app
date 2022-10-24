<template>
  <div class="col-md-6 mb-4">
    <div class="card">
      <div class="card-content">
        <h2 class="h4 card-heading">Skipped Vote&nbsp;&percnt;</h2>
        <div class="row px-3 px-xl-5 mb-md-2">
          <div class="stat col-5">
            <small class="text-muted">Median:</small>
            <div class="h5 text-success">
              <%= number_to_percentage @stats[:skipped_votes_percent][:median].to_f*100, precision: 1 %>
            </div>
            <small class="text-muted">Average:</small>
            <div class="h5 text-success">
              <%= number_to_percentage @stats[:skipped_votes_percent][:average].to_f*100, precision: 1 %>
            </div>
          </div>
          <div class="stat col-7 my-auto px-0">
            <div class="text-muted"><i class="fas fa-trophy text-success"></i>Best:</div>
            <div class="stat-title-1 text-success">
              <%= number_to_percentage @stats[:skipped_votes_percent][:best].to_f*100, precision: 2 %>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="col-md-6 mb-4">
    <div class="card">
      <div class="card-content">
        <h2 class="h4 card-heading">Skipped Slot&nbsp;&percnt;</h2>
        <div class="row px-3 px-xl-5 mb-md-2">
          <div class="stat col-5 my-auto">
            <small class="text-muted">Median:</small>
            <div class="h5 text-success">
              <%= number_to_percentage @stats[:skipped_slots][:median].to_f * 100, precision: 1 %>
            </div>
            <small class="text-muted">Average:</small>
            <div class="h5 text-success">
              <%= number_to_percentage @stats[:skipped_slots][:average].to_f * 100, precision: 1 %>
            </div>
          </div>
          <div class="stat col-7 my-auto px-0">
            <div class="text-muted">
              <i class="fas fa-long-arrow-alt-down text-success"></i>Min &ndash;
              <i class="fas fa-long-arrow-alt-up text-success"></i>Max:
            </div>
            <h2 class="stat-title-2 text-success mt-2">
              <% skipped_slots_min=@stats[:skipped_slots][:min].to_f * 100%>
                <%= skipped_slots_min> 0 ? skipped_slots_min : 0 %>
                  &ndash;
                  <%= @stats[:skipped_slots][:max].to_f * 100 %>
            </h2>
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
