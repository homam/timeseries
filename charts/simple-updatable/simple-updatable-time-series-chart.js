// Generated by CoffeeScript 1.6.2
(function() {
  var exports;

  exports = exports != null ? exports : this;

  exports.simpleUpdatableTimeSeriesChart = function() {
    var X, Y, chart, height, line, margin, width, xAxis, xMap, xScale, yAxis, yMap, yScale;

    margin = {
      top: 20,
      right: 20,
      bottom: 20,
      left: 50
    };
    width = 720;
    height = 300;
    xMap = function(d) {
      return d[0];
    };
    yMap = function(d) {
      return d[1];
    };
    X = function(d) {
      return xScale(xMap(d));
    };
    Y = function(d) {
      return yScale(yMap(d));
    };
    xScale = d3.time.scale().range([0, width - margin.left - margin.right]);
    yScale = d3.scale.linear().range([height - margin.top - margin.bottom, 0]);
    xAxis = d3.svg.axis().scale(xScale).orient('bottom');
    yAxis = d3.svg.axis().scale(yScale).orient('left');
    line = d3.svg.line().interpolate('basis').x(X).y(Y);
    chart = function(selection) {
      return selection.each(function(raw) {
        var $svg, data;

        $svg = d3.select(this).append('svg').attr('width', width).attr('height', height).append('g').attr('transform', "translate(" + margin.left + "," + margin.top + ")");
        $svg.append('g').attr('class', 'x axis');
        $svg.append('g').attr('class', 'y axis');
        data = raw;
        xScale.domain(d3.extent(data, xMap));
        yScale.domain(d3.extent(data, yMap));
        $svg.select('.x.axis').attr('transform', 'translate(0, ' + (height - margin.top - margin.bottom) + ')').call(xAxis);
        $svg.select('.y.axis').call(yAxis).append('text').attr('transform', 'rotate(0)').attr('y', 6).attr('dy', '.71em').style('text-anchor', 'end').text('Y');
        $svg.selectAll('path.line').data([data]).enter().append('path').attr('d', line).attr('class', 'line');
        return chart.addLine = function(newData, id) {
          xScale.domain(d3.extent(newData, xMap));
          yScale.domain(d3.extent(newData, yMap));
          $svg.selectAll('path.line').data([newData]).enter().append('path');
          $svg.selectAll('path.line').transition().duration(1500).ease("sin-in-out").attr('d', line).attr('class', 'line');
          $svg.select('.x.axis').transition().duration(1500).ease("sin-in-out").call(xAxis);
          return $svg.select('.y.axis').transition().duration(1500).ease("sin-in-out").call(yAxis);
        };
      });
    };
    chart.x = function(map) {
      xMap = map != null ? map : xMap;
      return chart;
    };
    chart.y = function(map) {
      yMap = map != null ? map : yMap;
      return chart;
    };
    return chart;
  };

}).call(this);
