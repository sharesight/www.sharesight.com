//= require "../lib/require.2.3.6.min.js"

// NOTE: We use require.js to load Vimeo, then initialize Vimeo.
// NOTE: …/player.js is preloaded in the <head>!
require(['https://player.vimeo.com/api/player.js'], function(Player) {
  let initialized = false;

  function initialize () {
    if (initialized) return;

    const vimeoSrc = document.querySelector('[data-vimeo-url], [data-vimeo-id]');
    if (!vimeoSrc) return false;
    initialized = true;

    const vimeo = new Player(vimeoSrc, {
      color: 'F5A623',
      title: false,
      byline: false,
      portrait: false
    });

    // If we have an overlay (eg. a background + play button, we interact with that instead)
    const playOverlay = vimeoSrc.parentNode.querySelector('.video_overlay');
    if (playOverlay) {
      vimeo.on('play', function() {
        playOverlay.style.display = 'none';
      });

      playOverlay.addEventListener('click', function(e) {
        e.preventDefault();

        vimeo.play();
      });

      playOverlay.addEventListener('keypress', function(e) {
        if (e.which === 13 || e.keyCode === 13 || e.key === 'Enter') {
          e.preventDefault();
          vimeo.play();
        }
      });
    }
  }

  ;(function() {
    // Note: We do protect against double initialization.
    initialize();

    document.addEventListener('DOMContentLoaded', () => {
      initialize();
    });
  })();
});
