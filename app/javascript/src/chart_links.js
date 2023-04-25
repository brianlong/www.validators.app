document.addEventListener("turbolinks:load", function() {
  document.querySelectorAll(".chart-link").forEach(link => {
    link.addEventListener("click", event => {
      event.preventDefault();
      let i = link.dataset.iterator;
      let target_tag = document.getElementById(link.dataset.bsTarget+'-'+i);
      let row = document.getElementById("row-"+i);

      if(!target_tag.classList.contains("d-none")) {
        // Hide the chart if selected chart is already shown
        target_tag.classList.add("d-none");
        link.classList.remove("active");
      } else {
        // Otherwise show the selected chart and hide the rest
        row.querySelectorAll(".column-chart").forEach(chart => {
          chart.classList.add("d-none");
        })
        target_tag.classList.remove("d-none");
        // Set active link
        row.querySelectorAll(".chart-link").forEach(l => {
          l.classList.remove("active");
        });
        link.classList.add("active");
      }
    })
  })
});
