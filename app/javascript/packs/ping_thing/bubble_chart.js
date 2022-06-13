export default {
  props: {
    vector: {
      type: Array,
      required: true
    },
  },
  data() {
    return {
      dark_grey: "#979797",
      chart_line: "#322f3d",
      chart: null
    }
  },
  mounted: function(){
    this.update_chart()
  },
  watch: {
      'vector': {
        handler: function(){
            this.update_chart()
        }
      }
  },
  methods: {
    update_chart: function(){
        if(this.chart){
            this.chart.destroy()
        }
        var ctx = document.getElementById("ping-thing-bubble-chart").getContext('2d');
        this.chart = new Chart(ctx, {
            type: 'bubble',
    
            // The data for our dataset
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
                legend: {
                    display: false,
                    labels: {
                        fontColor: this.dark_grey
                    },
                },
                scales: {
                    xAxes: [{
                        display: true,
                        ticks: { display: false },
                        gridLines: { display: false },
                        scaleLabel: {
                            display: true,
                            labelString: "Last " + this.vector.length + " Observations",
                            fontColor: this.dark_grey
                        }
                    }],
                    yAxes: [{
                        display: true,
                        ticks: {
                            min: 0,
                            padding: 10,
                            callback: function(value, index, values) {
                                return value.toLocaleString('en-US')
                            }
                        },
                        gridLines: {
                            display: true,
                            zeroLineColor: this.chart_line,
                            color: this.chart_line
                        },
                        scaleLabel: {
                            display: true,
                            labelString: 'Response Time (ms)',
                            fontColor: this.dark_grey,
                            padding: 5
                        }
                    }]
                },
                elements: {
                    point: {
                        radius: 3
                    }
                },
                tooltips: {
                    displayColors: false,
                    callbacks: {
                        label: function(tooltipItem, data) {
                            return tooltipItem.yLabel.toLocaleString('en-US').concat(' ms');
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
