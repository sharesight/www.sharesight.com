(function() {
  /* Force icons to change their font weight when focused or hovered. */
  document.addEventListener('DOMContentLoaded', () => {
    const phIconSelector = 'i[data-ph-hover-weight]';
    const weights = ['bold', 'regular', 'light', 'thin', 'fill'];
    const weightClassRegex = new RegExp(`-(${weights.join('|')})$`);

    function stripWeightFromClass (className) {
      return className.replace(weightClassRegex, '');
    }

    const icons = document.querySelectorAll(phIconSelector);

    function setWeightHover (event) {
      const icon = event.currentTarget;
      changeToWeight(icon, icon.getAttribute('data-ph-hover-weight'));
    }

    function setContainerWeightHover (event) {
      const icon = event.currentTarget.querySelector(phIconSelector);
      changeToWeight(icon, icon.getAttribute('data-ph-hover-weight'));
    }

    function resetWeight (event) {
      const icon = event.currentTarget;
      changeToWeight(icon, icon.getAttribute('data-ph-weight'));
    }

    function resetContainerWeight (event) {
      const icon = event.currentTarget.querySelector(phIconSelector);
      changeToWeight(icon, icon.getAttribute('data-ph-weight'));
    }

    function changeToWeight (icon, weight) {
      icon.classList.forEach(className => {
        if (!/^ph-[A-z-]+$/.test(className)) return;
        icon.classList.remove(className);

        // Add the new weight, eg. "-fill".
        let newClassName = stripWeightFromClass(className);
        if (weight) newClassName += `-${weight}`;
        icon.classList.add(newClassName);
      })
    }


    icons.forEach((icon) => {
      // Find the "original weight" for the icon and set it as a data attribute.
      icon.classList.forEach(className => {
        if (!/^ph-[A-z-]+$/.test(className)) return;
        const weightMatch = className.match(weightClassRegex);
        if (weightMatch) {
          const weightFromClassName = weightMatch[1];

          if (weights.includes(weightFromClassName)) {
            icon.setAttribute('data-ph-weight', weightFromClassName)
            return true;
          }
        }
      });

      icon.addEventListener('focusin', setWeightHover);
      icon.addEventListener('mouseover', setWeightHover);
      icon.addEventListener('focusout', resetWeight);
      icon.addEventListener('mouseout', resetWeight);

      const container = icon.closest('a, button');
      if (container) {
        container.addEventListener('focusin', setContainerWeightHover);
        container.addEventListener('mouseover', setContainerWeightHover);
        container.addEventListener('focusout', resetContainerWeight);
        container.addEventListener('mouseout', resetContainerWeight);
      }
    });
  })
})();
