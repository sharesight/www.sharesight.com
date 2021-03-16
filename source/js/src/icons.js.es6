/* Have icons change to another icon (eg. another weight) when hovered. */
function registerPhIconHover () {
  const phIconSelector = 'i[data-ph-hover]';
  const icons = document.querySelectorAll(phIconSelector);

  function getIcon (event) {
    let icon = event.currentTarget;
    if (!icon.matches(phIconSelector)) {
      icon = event.currentTarget.querySelector(phIconSelector);
    }

    return icon;
  }

  function cacheOriginalIcon (node) {
    if (node.getAttribute('data-ph-original')) return;

    // Find the "original weight" for the icon and set it as a data attribute.
    node.classList.forEach(className => {
      if (!/^ph-[A-z-]+$/.test(className)) return;
      node.setAttribute('data-ph-original', className);
    });
  }

  function setIcon (event) {
    const icon = getIcon(event);
    if (!icon) return;

    cacheOriginalIcon(icon);
    changeIcon(icon, icon.getAttribute('data-ph-hover'));
  }

  function resetIcon (event) {
    const icon = getIcon(event);
    if (!icon) return;

    changeIcon(icon, icon.getAttribute('data-ph-original'));
  }

  function changeIcon (node, newIcon) {
    node.classList.forEach(className => {
      if (!/^ph-[A-z-]+$/.test(className)) return;
      node.classList.remove(className);
      node.classList.add(newIcon);
    });
  }

  icons.forEach((icon) => {
    icon.addEventListener('focusin', setIcon);
    icon.addEventListener('mouseover', setIcon);
    icon.addEventListener('focusout', resetIcon);
    icon.addEventListener('mouseout', resetIcon);

    const container = icon.closest('a, button');
    if (container) {
      container.addEventListener('focusin', setIcon);
      container.addEventListener('mouseover', setIcon);
      container.addEventListener('focusout', resetIcon);
      container.addEventListener('mouseout', resetIcon);
    }
  });
}

;(function() {
  (function() {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', registerPhIconHover);
    } else {
      registerPhIconHover();
    }
  })();
})();
