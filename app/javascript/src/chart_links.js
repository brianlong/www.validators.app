document.addEventListener("turbolinks:load", function() {
  let links = document.getElementsByClassName("chart-link");
  Array.prototype.forEach.call(links, link => {
    link.addEventListener("click", event => {
      event.preventDefault();
      var i = link.dataset.iterator
      var target = link.dataset.bsTarget+'-'+i;
      var row = document.getElementById("row-"+i);

      // Show selected chart, hide the rest
      var charts = row.getElementsByClassName("column-chart");
      Array.prototype.forEach.call(charts, chart => {
        chart.classList.add("d-none");
      })
      document.getElementById(target).classList.remove("d-none");

      // Set active link
      var ls = row.getElementsByClassName("chart-link");
      Array.prototype.forEach.call(ls, l => {
        l.classList.remove("active")
      });
      link.classList.add("active");
    })
  })
});
