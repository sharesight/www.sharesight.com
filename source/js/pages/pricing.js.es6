(function() {
  const table = document.getElementById("pricing_table")
  if (!table) return

  const pricingTable = {
    table: table,
    controls_count: document.getElementsByClassName("controls").length,
    nextControls: document.getElementsByClassName("next"),
    backControls: document.getElementsByClassName("back"),
    rows: table.rows,
    current_index: parseInt(table.getAttribute("data-current-index") || 1),

    isCurrentHash: (name) => {
      return (name === window.location.hash.substring(1))
    },

    setIndex: function (newIndex) {
      // must be within bounds
      if (newIndex < 1) newIndex = 1
      if (newIndex > 3) newIndex = 3
      this.current_index = newIndex
      this.table.setAttribute("data-current-index", this.current_index)
    },

    onLoad: function () {
      if (this.isCurrentHash("expert")) {
        this.setIndex(3)
      } else if (this.isCurrentHash("investor")) {
        this.setIndex(2)
      } else {
        this.setIndex(1)
      }

      this.stripeRows()
      this.activateControls()
    },

    activateControls: function () {
      for (i = 0; i <= this.controls_count; i++) {
        if (this.nextControls[i]) {
          this.nextControls[i].onclick = () => {
            this.setIndex(this.current_index + 1)
            return false;
          }
        }

        if (this.backControls[i]) {
          this.backControls[i].onclick = () => {
            this.setIndex(this.current_index - 1)
            return false;
          }
        }
      }
    },

    stripeRows: function () {
      let k = 0
      for (let i = 0; i < this.rows.length; i++) {
        const target = this.rows[i]

        if (target.className.indexOf('hidden') === -1) {
          target.style.backgroundColor = (k % 2) ? "#f7f7f7" : "#fff"
          k++
        }

        if (target.className.indexOf('collapsible') > -1) {
          target.touchstart = this.clickHandler
          target.onclick = this.clickHandler
        }
      }
    },

    clickHandler: function () {
      const hidden_sibling = this.nextElementSibling
      if (!hidden_sibling || !hidden_sibling.className) return

      if (hidden_sibling.className.indexOf('hidden') > -1) {
        hidden_sibling.className = hidden_sibling.className.replace('hidden', 'visible')
      } else if (hidden_sibling.className.indexOf('visible') > -1) {
        hidden_sibling.className = hidden_sibling.className.replace('visible', 'hidden')
      }

      pricingTable.stripeRows() // recalculate with the hidden/visible
    }
  }

  pricingTable.onLoad()
})();
