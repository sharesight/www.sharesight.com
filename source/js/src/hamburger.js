(function(){
  var hamburger = document.getElementById("js-hamburger"),
      close = document.getElementById("js-close"),
      sliding_menu = document.getElementById("js-sliding-menu"),
      menu_mask = document.getElementById("menu_mask"),
      menu_wrapper = document.getElementById("menu_wrapper"),
      menu = document.getElementById("menu"),
      keys = {37: 1, 38: 1, 39: 1, 40: 1};

  if(sliding_menu) {
    sliding_menu.style.display = "none";
  }
  if(hamburger) {
    document.getElementById("extended-menu").onfocus = function(event){

      this.onkeypress = function(e){
        if(e.which === 13 || e.keyCode === 13){
          openMenu();
        }
      };
    };
    hamburger.onclick = function(e){
      openMenu();
    };
  }

  if(close) {
    close.onclick = function(e){
      closeMenu();
    };
    close.onfocus = function(event){
      this.onkeypress = function(e){
        if(e.which === 13 || e.keyCode === 13) {
          closeMenu();
        }
      };
    };

  }

  if(menu_mask) {
    menu_mask.onclick = function(e){
      sliding_menu.setAttribute("data-menu-visibility", 2);
      menu.style.display = "none";
      menu_mask.style.display = "none";
      enableScroll();
      return false;
    };
  }

  function openMenu(){
    sliding_menu.style.display = "block";
    sliding_menu.setAttribute("data-menu-visibility", 1);
    menu_mask.style.display = "block";
    menu.style.display = "block";
    disableScroll();
    return false;
  }

  function closeMenu(){
    sliding_menu.setAttribute("data-menu-visibility", 2);
    menu.style.display = "none";
    menu_mask.style.display = "none";
    enableScroll();
    return false;
  }

function preventDefault(e) {
  e = e || window.event;
  if (e.preventDefault)
      e.preventDefault();
  e.returnValue = false;
}

function preventDefaultForScrollKeys(e) {
    if (keys[e.keyCode]) {
        preventDefault(e);
        return false;
    }
}

function disableScroll() {
  if (window.addEventListener){
    window.addEventListener('DOMMouseScroll', preventDefault, false);
    window.onwheel = preventDefault;
    window.onmousewheel = document.onmousewheel = preventDefault; // older browsers, IE
    window.ontouchmove  = preventDefault; // mobile
    document.onkeydown  = preventDefaultForScrollKeys;
  }
}

function enableScroll() {
  if (window.removeEventListener)
    window.removeEventListener('DOMMouseScroll', preventDefault, false);
    window.onmousewheel = document.onmousewheel = null;
    window.onwheel = null;
    window.ontouchmove = null;
    document.onkeydown = null;
  }
})();
