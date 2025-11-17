document.addEventListener("turbolinks:load", function() {
  // Usuń istniejące listenery żeby uniknąć duplikatów
  document.querySelectorAll(".chart-link").forEach(link => {
    // Usuń poprzedni listener jeśli istnieje
    if (link.chartClickHandler) {
      link.removeEventListener("click", link.chartClickHandler);
    }
  });

  document.querySelectorAll(".chart-link").forEach(link => {
    // Definiuj handler jako właściwość elementu żeby można było go później usunąć
    link.chartClickHandler = function(event) {
      event.preventDefault();
      let i = link.dataset.iterator;
      let target_tag = document.getElementById(link.dataset.bsTarget+'-'+i);
      let row = document.getElementById("row-"+i);

      if(!target_tag || !row) {
        console.error("Elements not found for iterator:", i);
        return; // Early exit if elements not found
      }

      if(!target_tag.classList.contains("d-none")) {
        console.log("Hiding chart:", target_tag.id);
        // Hide the chart if selected chart is already shown
        target_tag.classList.add("d-none");
        link.classList.remove("active");
      } else {
        console.log("Showing chart:", target_tag.id);
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
    };
    
    // Dodaj nowy listener
    link.addEventListener("click", link.chartClickHandler);
  });
});
