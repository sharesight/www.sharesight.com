//testimonials
(function() {

  var testimonials = document.getElementById("js-testimonials"),
      indicators = document.getElementById("js-indicators"),
      slideshow = document.getElementById("js-slideshow"),
      testimonial_container = document.getElementById("js-testimonials-container");

  if (indicators) {
    var indicator_length = indicators.children.length - 1;
  }
  if (slideshow) {
    var speed = 4000,
      i = 0;

    var play = setInterval(function() {
      event_play()
    }, speed);

    function clear_play() {
      clearInterval(play);
    }

    function replay(new_counter) {
      if (new_counter) {
        i = new_counter;
        play = setInterval(function() {
          event_play(new_counter)
        }, speed);
      } else {
        i = 0;
        play = setInterval(function() {
          event_play()
        }, speed);
      }
    }

    function event_play(new_counter) {
      if (new_counter) {
        i++;
        slideshow.setAttribute("data-testimonial-index", i);
        if (i > indicator_length) {
          clear_play();
          replay();
        }
      } else {
        i++;
        slideshow.setAttribute("data-testimonial-index", i);
        if (i > indicator_length) {
          clear_play();
          replay();
        }
      }
    }

    for (var j = 0; j <= indicator_length; j++) {
      indicators.children[j].onclick = function() {
        indicator = parseInt(this.getAttribute("data-indicator"));
        slideshow.setAttribute("data-testimonial-index", indicator);
        clear_play();
        replay(indicator - 1);
      }
    }
  }
})();
