document.addEventListener("turbolinks:load", function() {
  document.querySelectorAll(".chart-link").forEach(link => {
    if (link.chartClickHandler) {
      link.removeEventListener("click", link.chartClickHandler);
    }
  });

  document.querySelectorAll(".chart-link").forEach(link => {
    link.chartClickHandler = function(event) {
      event.preventDefault();
      let i = link.dataset.iterator;
      let target_tag = document.getElementById(link.dataset.bsTarget+'-'+i);
      let row = document.getElementById("row-"+i);

      if(!target_tag || !row) {
        console.error("Elements not found for iterator:", i);
        return;
      }

      if(!target_tag.classList.contains("d-none")) {
        console.log("Hiding chart:", target_tag.id);
        target_tag.classList.add("d-none");
        link.classList.remove("active");
      } else {
        console.log("Showing chart:", target_tag.id);
        row.querySelectorAll(".column-chart").forEach(chart => {
          chart.classList.add("d-none");
        })
        target_tag.classList.remove("d-none");
        row.querySelectorAll(".chart-link").forEach(l => {
          l.classList.remove("active");
        });
        link.classList.add("active");
      }
    };
    
    link.addEventListener("click", link.chartClickHandler);
  });
});
