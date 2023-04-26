import Vue from 'vue'

var moment = require('moment');

Vue.mixin({
  methods: {
    date_time_with_timezone(date) {
      return moment(new Date(date)).utc().format('YYYY-MM-DD HH:mm:ss z')
    }
  }
})
