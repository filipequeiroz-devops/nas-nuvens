document.addEventListener("DOMContentLoaded", function() {
  const toggleButton = document.querySelector(".dropdown-menu-toggle");
  const dropdownMenu = document.querySelector(".dropdown-menu");

  if (toggleButton && dropdownMenu) {
    toggleButton.addEventListener("click", function() {
      const expanded = toggleButton.getAttribute("aria-expanded") === "true";
      toggleButton.setAttribute("aria-expanded", !expanded);
      dropdownMenu.style.display = expanded ? "none" : "block";
    });

    document.addEventListener("click", function(event) {
      if (!toggleButton.contains(event.target) && !dropdownMenu.contains(event.target)) {
        toggleButton.setAttribute("aria-expanded", false);
        dropdownMenu.style.display = "none";
      }
    });
  }
});