(function() {
  const headings = document.querySelectorAll(".faq-heading");
  if (!headings || !headings.length) return;

  Array.from(headings).forEach(heading => {
    const answer = heading.nextElementSibling
    answer.style.display = 'none';

    heading.onkeypress = function(e) {
      if(e.which === 13 || e.keyCode === 13){
        toggle.call(this, e)
      }
    };

    heading.onclick = toggle;
  });

  function toggle(e) {
    const symbol = this.previousElementSibling.getElementsByTagName('span')[0]
    const answer = this.nextElementSibling;
    if (!symbol || !answer) return;

    if (answer.style.display !== 'none') {
      answer.style.display = 'none';
      answer.setAttribute("aria-hidden", true);

      symbol.setAttribute("data-state-toggle", "open")
      symbol.innerHTML = '–';
    } else {
      answer.style.display = 'block';
      answer.setAttribute("aria-hidden", false);

      symbol.setAttribute("data-state-toggle", "closed")
      symbol.innerHTML = '+';
    }
  }
})();
