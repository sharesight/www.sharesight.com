(function() {
  document.addEventListener('DOMContentLoaded', () => {
    const nav = document.getElementById('site_navigation');
    const menuTargets = nav.querySelectorAll('[role="menubar"] [aria-haspopup="true"]');

    function setExpanded (target, expanded) {
      target.setAttribute('aria-expanded', expanded);
    }

    function closeAll () {
      menuTargets.forEach(target => {
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

    function handleKeyboardMenu (event) {
      switch (String(event.key).toLowerCase()) {
        case 'space':
        case 'enter':
          setExpanded(event.currentTarget, true);
          break;

        default:
          // Default, we exit.  Do nothing, do not preventDefault!
          return;
      }

      e.preventDefault(); // if we did something here, prevent the default action
    }

    document.addEventListener('keypress', function handleKeyboardGlobal (event) {
      console.log('@@body', event.key)
      switch (String(event.key).toLowerCase()) {
        case 'esc':
        case 'escape':
          closeAll();
          break;

        default:
          // Default, we exit.  Do nothing, do not preventDefault!
          return;
      }

      e.preventDefault(); // if we did something here, prevent the default action
    });

    menuTargets.forEach((node) => {
      node.addEventListener('keypress', handleKeyboardMenu);

      node.addEventListener('click', handleShowMenu);
      node.addEventListener('focusin', handleShowMenu);
      node.addEventListener('mouseover', handleShowMenu);

      const container = node.closest('li');
      container.addEventListener('focusout', handleContainerHideMenu);
      container.addEventListener('mouseout', handleContainerHideMenu);
    });
  })
})();
