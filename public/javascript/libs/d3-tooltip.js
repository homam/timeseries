//based upon: http://www.d3noob.org/2013/01/adding-tooltips-to-d3js-graph.html

(function() {
    var ttCounter = 0

    function D3Tooltip (d3) {
      this.d3 = d3
      this.id = 'd3-tooltip-' + ttCounter
      this.class = 'd3-tooltip'
      this.$el =  d3.select('body').append('div')
                    .attr('class', this.class)
                    .attr('id', this.id)
                    .style('opacity', 0)
                    .style('position', 'absolute')
                    .style('pointer-events', 'none')

      ttCounter += 1
    }

    D3Tooltip.prototype.html = function(html) {
      this.$el.html(html)
    }

    D3Tooltip.prototype.show = function() {
      this.$el.transition().duration(200).style('opacity', .9)
      this.$el.style('left', this.d3.event.pageX + 'px')
              .style('top', (this.d3.event.pageY - 28) + 'px')

    }

    D3Tooltip.prototype.hide = function() {
      this.$el.transition().duration(500).style('opacity', 0)
    }

    this.d3tooltip = function(d3) {
        return new D3Tooltip(d3);
    }
})(this)