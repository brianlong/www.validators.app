document.addEventListener("turbolinks:load", function() {
  document.querySelectorAll(".chart-link").forEach(link => {
    link.addEventListener("click", event => {
      event.preventDefault();
      let i = link.dataset.iterator;
      let target = link.dataset.bsTarget+'-'+i;
      let row = document.getElementById("row-"+i);

      // Show selected chart, hide the rest
      row.querySelectorAll(".column-chart").forEach(chart => {
        chart.classList.add("d-none");
      })
      document.getElementById(target).classList.remove("d-none");

      // Set active link
      row.querySelectorAll(".chart-link").forEach(l => {
        l.classList.remove("active");
      });
      link.classList.add("active");
    })
  })
});
