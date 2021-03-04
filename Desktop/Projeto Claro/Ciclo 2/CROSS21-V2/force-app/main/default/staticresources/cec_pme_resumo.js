var acc = document.getElementsByClassName("accordion");
var i;

for (i = 0; i < acc.length; i++) {
  acc[i].addEventListener("click", function() {
    this.classList.toggle("active");
    var bloco = this.nextElementSibling;
    if (bloco.style.display === "none") {
      bloco.style.display = "inline-table";
    } else {
      bloco.style.display = "none";
    }
  });
}
var acc = document.getElementsByClassName("accordion2");
var i;

for (i = 0; i < acc.length; i++) {
  acc[i].addEventListener("click", function() {
    this.classList.toggle("active");
    var bloco = this.nextElementSibling;
    if (bloco.style.display === "none") {
      bloco.style.display = "inline-table";
    } else {
      bloco.style.display = "none";
    }
  });
}

var acc = document.getElementsByClassName("accordion3");
var i;

for (i = 0; i < acc.length; i++) {
  acc[i].addEventListener("click", function() {
    this.classList.toggle("active");
    var bloco = this.nextElementSibling;
    if (bloco.style.display === "none") {
      bloco.style.display = "inline-table";
    } else {
      bloco.style.display = "none";
    }
  });
}