function handleKeyboardAction ({ event, onOpen, onEscape }) {
  switch (String(event.key).toLowerCase()) {
    case ' ':
    case 'spacebar':
    case 'space':
    case 'enter':
    case 'return':
      if (typeof onOpen === 'function') {
        onOpen();
        event.preventDefault(); // if we did something here, prevent the default action
      }

      break;

    case 'esc':
    case 'escape':
      if (typeof onEscape === 'function') {
        onEscape();
        event.preventDefault(); // if we did something here, prevent the default action
      }
      break;

    default:
      // Default, we exit.  Do nothing, do not preventDefault!
      return;
  }
}

function registerNavigation () {
  const nav = document.getElementById('site_navigation');
  const menuTargets = nav.querySelectorAll('[role="menubar"] [aria-haspopup="true"]');

  function setExpanded (target, expanded) {
    target.setAttribute('aria-expanded', expanded);
  }

  function closeAll () {
    Array.from(menuTargets).forEach(target => {
      setExpanded(target, false);
    });
  }

  function handleShowMenu (event) {
    const button = event.currentTarget;
    setExpanded(button, true);
  }

  function handleContainerHideMenu (event) {
    const container = event.currentTarget; // This is an `li`
    const relatedTarget = event.relatedTarget;

    if (container.contains(relatedTarget)) return;

    const button = container.querySelector('[aria-expanded]');
    if (!button) return;

    setExpanded(button, false);
  }

  function handleKeyboardOpen (event) {
    return handleKeyboardAction({
      event,
      onOpen: () => setExpanded(event.currentTarget, true),
    });
  }

  function handleKeyboardEscape (event) {
    return handleKeyboardAction({ event, onEscape: closeAll });
  }

  document.addEventListener('keydown', handleKeyboardEscape);

  Array.from(menuTargets).forEach((node) => {
    node.addEventListener('keydown', handleKeyboardOpen);

    node.addEventListener('click', handleShowMenu);
    node.addEventListener('focusin', handleShowMenu);
    node.addEventListener('mouseover', handleShowMenu);

    const container = node.closest('li');
    container.addEventListener('focusout', handleContainerHideMenu);
    container.addEventListener('mouseout', handleContainerHideMenu);
  });
}

function registerMobileNavigation () {
  const menu = document.getElementById('mobile-nav');

  function closeMenu () {
    menu.setAttribute('aria-hidden', true);
  }

  function openMenu () {
    menu.setAttribute('aria-hidden', false);
  }

  function handleKeyboardEscape (event) {
    return handleKeyboardAction({ event, onEscape: closeMenu });
  }

  function handleKeyboardOpen (event) {
    return handleKeyboardAction({ event, onOpen: openMenu });
  }

  function handleKeyboardCloseIcon (event) {
    return handleKeyboardAction({ event, onOpen: closeMenu });
  }

  function handleClickOverlayBlur (event) {
    if (event.target !== event.currentTarget) return;
    closeMenu();
  }

  document.addEventListener('keydown', handleKeyboardEscape);


  const hamburger = document.getElementById('nav__hamburger');
  hamburger.addEventListener('keydown', handleKeyboardOpen);
  hamburger.addEventListener('click', openMenu);

  // Clicking on the menu overlay (just the "grey blur area") will close as well.
  menu.addEventListener('click', handleClickOverlayBlur);

  const closeIcon = menu.querySelector('.mobile-nav__close');
  closeIcon.addEventListener('click', closeMenu);
  closeIcon.addEventListener('keydown', handleKeyboardCloseIcon);
}

;(function() {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      registerNavigation();
      registerMobileNavigation();
    });
  } else {
    registerNavigation();
    registerMobileNavigation();
  }
})();
