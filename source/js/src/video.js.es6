//= require "../lib/require.2.3.6.min.js"

// Videos
const videos = {
  videos: [],
  elements: [],
  loaded: false,

  /**
   * Initialize embedly videos
   * @param {NodeList} elements List of static video containers
   */
  initialize: function (elements) {
    if (!elements || !elements.length) {
      this.loadEmbedly().then();
    } else {
      this.elements = elements;
      this.attachEvents();
    }
  },

  /**
   * Attach event handlers for play buttons
   */
  attachEvents: function () {
    for (let i = 0; i < this.elements.length; i++) {
      const container = this.elements[i];
      this.videos.push({
        id: container.querySelector('.embedly-embed').id,
        container: container,
        playButton: container.querySelector('.btn-play'),
        overlay: container.querySelector('.video_overlay'),
      });

      this.videos.forEach(function(video) {
        video.playButton.addEventListener('click', e => {
          e.preventDefault();

          if (!this.loaded) {
            this.loadEmbedly().then(function() {
              embedly('player', function (player) {
                const selected = this.videos.find(video => video.container.contains(player.frame.elem));
                selected.player = player;
              }.bind(this));

              this.playVideo(video);
            }.bind(this));
          } else {
            this.playVideo(video);
          }
        });
      }.bind(this));
    }
  },

  /**
   * Play the video
   * @param {Object} video The video to play
   */
  playVideo: function(video) {
    video.overlay.addEventListener('transitionend', () => {
      video.overlay.style.display = 'none';
      video.player.play();
    });

    video.overlay.classList.add('hidden');
  },

  /**
   * Load embedly JS and initialize default settings
   * @returns {Promise<unknown>}
   */
  loadEmbedly: function () {
    return new Promise((resolve, reject) => {
      require(['//cdn.embedly.com/widgets/platform.js'], function () {
        embedly('defaults', {
          cards: {
            key: '29eeda9e10194668b8297779af3ec8eb',
            override: true,
            recommend: 0,
            chrome: 0,
          }
        });

        this.loaded = true;
        resolve();
      }.bind(this), function (err) {
        reject(err);
      });
    });
  }
};

;(function() {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      videos.initialize(document.querySelectorAll('.o-video_wrapper'));
    });
  } else {
    videos.initialize(document.querySelectorAll('.o-video_wrapper'));
  }
})();
