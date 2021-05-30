//= require "../lib/require.2.3.6.min.js"

// Videos
;(function() {
  let loaded = false;
  let initialized = false;
  const videos = [];

  /**
   * Load embedly JS and initialize default settings
   * @returns {Promise<unknown>}
   */
  const loadEmbedly = function(staticVideoElements) {
    return new Promise((resolve, reject) => {
      if (loaded) resolve(videos);

      if (staticVideoElements && staticVideoElements.length) {
        for (let i = 0; i < staticVideoElements.length; i++) {
          const container = staticVideoElements[i];
          videos.push({
            container: container,
            playButton: container.querySelector('.btn-play'),
            button: container.querySelector('.vid__play'),
            overlay: container.querySelector('.video_overlay'),
          })
        }
      }

      require(['//cdn.embedly.com/widgets/platform.js'], function () {
        embedly('defaults', {
          cards: {
            key: '29eeda9e10194668b8297779af3ec8eb',
            override: true,
            recommend: 0,
            chrome: 0,
          }
        });

        embedly('player', function (player) {
          for (let i = 0; i < staticVideoElements.length; i++) {
            if (videos[i]) {
              videos[i].player = player;
            } else {
              videos.push({
                player: player
              });
            }
          }
        });

        loaded = true;

        resolve(videos);
      }, function (err) {
        reject(err);
      });
    });
  };

  /**
   * Initialize video players
   */
  function initialize () {
    if (initialized) return;

    const staticVideoElements = document.querySelectorAll('.o-video_wrapper')

    if (staticVideoElements.length) {
      loadEmbedly(staticVideoElements).then(function (videos) {
        videos.forEach(function(video) {
          video.playButton.addEventListener('click', e => {
            e.preventDefault();

            if (video.container.classList.contains('error')) {
              video.container.classList.remove('error');
            }

            video.overlay.addEventListener('transitionend', () => {
              video.overlay.style.display = 'none';
              video.player.play();
            });

            video.overlay.classList.add('hidden');
          });
        });
      });
    } else {
      loadEmbedly().then();
    }

    initialized = true;
  }

  // Note: We do protect against double initialization.
  initialize();

  document.addEventListener('DOMContentLoaded', () => {
    initialize();
  });
})();
