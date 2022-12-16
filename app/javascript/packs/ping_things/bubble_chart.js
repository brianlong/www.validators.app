export default {
  props: {
    vector: {
      type: Array,
      required: true
    },
    network: {
        type: String,
        required: true
    }
  },
  data() {
    return {
      dark_grey: "#979797",
      chart_line: "#322f3d",
      chart: null
    }
  },
  watch: {
      'vector': {
        handler: function(){
            this.update_chart()
        }
      }
  },
  methods: {
    update_chart: function() {
        if(this.chart) {
            this.chart.destroy()
        }

        var ctx = document.getElementById("ping-thing-bubble-chart").getContext('2d');
        this.chart = new Chart(ctx, {
            type: 'bubble',
            // The data
            data: {
                datasets: [
                    {
                        data: this.vector.map( (vector_element, index) => ({ x: index, y: vector_element['response_time'], z: 1 }) ),
                        backgroundColor: "rgba(221, 154, 229, 0.4)",
                        borderColor: "rgb(221, 154, 229)"
                    }
                ],
            },

            // Configuration options
            options: {
                animation: false,
                scales: {
                    x: {
                        display: true,
                        ticks: { display: false },
                        grid: { display: false },
                        title: {
                            display: true,
                            text: `Last ${this.vector.length} Observations`,
                            color: this.dark_grey
                        }
                    },
                    y: {
                        display: true,
                        ticks: {
                            min: 0,
                            padding: 10,
                            callback: function(value, index, values) {
                                return value.toLocaleString('en-US')
                            }
                        },
                        grid: { display: false, },
                        title: {
                            display: true,
                            text: 'Response Time (ms)',
                            color: this.dark_grey,
                            padding: 5
                        }
                    }
                },
                elements: {
                    point: {
                        radius: 3
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        displayColors: false,
                        callbacks: {
                            label: function(tooltipItem) {
                                return tooltipItem.raw["y"].toLocaleString('en-US').concat(' ms');
                            },
                        },
                    },
                },
            }
        });
    }
  },
  template: `
    <canvas :id="'ping-thing-bubble-chart'"></canvas>
`
}
