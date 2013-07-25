// Generated by CoffeeScript 1.6.2
(function() {
  var exports;

  exports = exports != null ? exports : this;

  exports.stackedAreaimeSeriesChart = function() {
    var X, Y, chart, height, keyFilter, keyMap, line, margin, stackOffset, valuesMap, width, xMap, xScale, yMap, yScale;

    margin = {
      top: 20,
      right: 40,
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
    xScale = d3.time.scale();
    yScale = d3.scale.linear();
    keyMap = function(d) {
      return d['key'];
    };
    valuesMap = function(d) {
      return d['values'];
    };
    keyFilter = function(d) {
      return true;
    };
    stackOffset = 'zero';
    X = function(d) {
      return xScale(d);
    };
    Y = function(d) {
      return yScale(d);
    };
    line = d3.svg.line().interpolate('basis').x(X).y(Y);
    chart = function(selection) {
      return selection.each(function(raw) {
        var $svg, area, xAxis, yAxis;

        xScale.range([0, width - margin.left - margin.right]);
        yScale.range([height - margin.top - margin.bottom, 0]);
        xAxis = d3.svg.axis().scale(xScale).orient('bottom').tickSize(-height + margin.top + margin.bottom, 0, 0);
        yAxis = d3.svg.axis().scale(yScale).orient('left').tickSize(-width + margin.left + margin.right, 0, 0);
        $svg = d3.select(this).append('svg').attr('width', width).attr('height', height).append('g').attr('transform', "translate(" + margin.left + "," + margin.top + ")");
        $svg.append('g').attr('class', 'x axis');
        $svg.select('.x.axis').attr('transform', 'translate(0, ' + (height - margin.top - margin.bottom) + ')');
        $svg.append('g').attr('class', 'y axis line');
        $svg.select('.y.axis.line').append('text').attr('transform', 'translate(20,0) rotate(90)').attr('y', 6).attr('dy', '.71em').style('text-anchor', 'start').text('Y');
        area = d3.svg.area().x(function(d) {
          return X(d.day);
        }).y0(function(d) {
          return Y(d.y0);
        }).y1(function(d) {
          return Y(d.y0 + d.y);
        });
        return chart.addStack = function(data) {
          var $layer, $path, keys, layers, scaleLayers, stack;

          stack = d3.layout.stack().offset(stackOffset).x(xMap).y(yMap).values(valuesMap);
          layers = stack(data);
          keys = data.map(keyMap).filter(keyFilter);
          layers = layers.map(function(layer) {
            if (keys.indexOf(keyMap(layer)) < 0) {
              (valuesMap(layer)).map(function(d) {
                d.y = d.y0 = 0;
                return d;
              });
            }
            return layer;
          });
          xScale.domain(d3.extent(valuesMap(layers[0]), xMap));
          $svg.select('.x.axis').transition().duration(1500).ease("sin-in-out").call(xAxis);
          scaleLayers = stack(data.filter(function(d) {
            return keyFilter(keyMap(d));
          }));
          yScale.domain([
            0, d3.max(scaleLayers, function(l) {
              return d3.max(valuesMap(l), function(d) {
                return d.y0 + d.y;
              });
            })
          ]);
          $svg.select('.y.axis.line').transition().duration(1500).ease("sin-in-out").call(yAxis);
          $svg.select('.y.axis.line > text').text(typeof label !== "undefined" && label !== null ? label : '');
          $layer = $svg.selectAll('.layer').data(layers);
          $layer.enter().append('g').attr('class', 'layer');
          $layer.style('fill', function(d) {
            return d.color;
          }).transition().duration(500).ease("sin-in-out").delay(200).style('opacity', function(d) {
            if (keys.indexOf(keyMap(d)) < 0) {
              return 0;
            } else {
              return 1;
            }
          });
          $path = $layer.selectAll('path.area').data(function(d) {
            return [valuesMap(d)];
          });
          $path.enter().append('path').attr('class', 'area');
          $path.style('fill', function(d) {
            return d.color;
          });
          return $path.transition().duration(1000).ease("sin-in-out").attr('d', area);
        };
      });
    };
    chart.key = function(map) {
      keyMap = map != null ? map : keyMap;
      return chart;
    };
    chart.keyFilter = function(filter) {
      keyFilter = filter != null ? filter : keyFilter;
      return chart;
    };
    chart.values = function(map) {
      valuesMap = map != null ? map : valuesMap;
      return chart;
    };
    chart.stackOffset = function(val) {
      stackOffset = val != null ? val : stackOffset;
      return chart;
    };
    chart.x = function(map) {
      xMap = map != null ? map : xMap;
      return chart;
    };
    chart.y = function(map) {
      yMap = map != null ? map : yMap;
      return chart;
    };
    chart.height = function(val) {
      height = val != null ? val : height;
      return chart;
    };
    return chart;
  };

}).call(this);
