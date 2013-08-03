// Generated by CoffeeScript 1.6.2
(function() {
  var exports;

  exports = exports != null ? exports : this;

  exports.groupedBarsChart = function() {
    var chart, color, height, mainNameMap, mainValueMap, margin, subNameMap, subValueMap, width, x0, x1, xAxis, y, yAxis;

    margin = {
      top: 50,
      right: 0,
      bottom: 20,
      left: 70
    };
    width = 720 - margin.left - margin.right;
    height = 300 - margin.top - margin.bottom;
    x0 = d3.scale.ordinal().rangeRoundBands([0, width], .1);
    x1 = d3.scale.ordinal();
    y = d3.scale.linear().range([height, 0]);
    color = d3.scale.category10();
    xAxis = d3.svg.axis().scale(x0).orient('bottom');
    yAxis = d3.svg.axis().scale(y).orient('left').tickFormat(d3.format('.2%')).tickSize(-width, 0, 0);
    mainNameMap = function(d) {
      return d.name;
    };
    subNameMap = function(d) {
      return d.name;
    };
    mainValueMap = function(d) {
      return d.value;
    };
    subValueMap = function(d) {
      return d.value;
    };
    chart = function(selection) {
      return selection.each(function() {
        var $svg, $xAxis, $yAxis;

        $svg = d3.select(this).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', "translate(" + margin.left + "," + margin.top + ")");
        $xAxis = $svg.append('g').attr('class', 'x axis').attr("transform", "translate(0," + height + ")");
        $yAxis = $svg.append('g').attr('class', 'y axis');
        chart.draw = function(hierarchy) {
          var $devG, $devLowLine, $devUpperLine, $devrect, $legend, $legendEnter, $main, $rect, allMainKeys, allSubKeys;

          allSubKeys = _.uniq(_.flatten(hierarchy.map(function(d) {
            return mainValueMap(d).map(subNameMap);
          })));
          allMainKeys = _.flatten(hierarchy.map(mainNameMap));
          x0.domain(allMainKeys);
          x1.domain(allSubKeys).rangeRoundBands([0, x0.rangeBand()]);
          y.domain([
            0, d3.max(_.flatten(hierarchy.map(function(h) {
              return mainValueMap(h).map(subValueMap);
            })))
          ]);
          $main = $svg.selectAll('.main').data(hierarchy);
          $main.enter().append('g').attr('class', 'main');
          $main.attr('transform', function(d) {
            return "translate(" + x0(mainNameMap(d)) + ",0)";
          });
          $rect = $main.selectAll('rect.conv').data(mainValueMap);
          $rect.enter().append('rect').attr('class', 'conv');
          $rect.transition().duration(200).attr('width', x1.rangeBand()).attr('x', function(d) {
            return x1(subNameMap(d));
          }).attr('y', function(d) {
            return y(subValueMap(d));
          }).attr('height', function(d) {
            return height - y(subValueMap(d));
          }).style('fill', function(d) {
            return color(allSubKeys.indexOf(mainNameMap(d)));
          });
          $rect.exit().transition().duration(200).attr('y', height).attr('height', 0);
          $devG = $main.selectAll('g.dev').data(mainValueMap);
          $devG.enter().append('g').attr('class', 'dev');
          $devG.transition().duration(200).attr('transform', function(d) {
            return 'translate(0,' + (-height + y(d.value) - (-height + y(d.stdev)) / 2) + ')';
          });
          $devUpperLine = $devG.selectAll('line.dev.up').data(function(d) {
            return [d];
          });
          $devUpperLine.enter().append('line').attr('class', 'dev up');
          $devUpperLine.transition().duration(200).attr('x1', _.compose(x1, subNameMap)).attr('x2', function(d) {
            return _.compose(x1, subNameMap)(d) + x1.rangeBand();
          }).attr('y1', function(d) {
            return y(d.stdev);
          }).attr('y2', function(d) {
            return y(d.stdev);
          });
          $devLowLine = $devG.selectAll('line.dev.low').data(function(d) {
            return [d];
          });
          $devLowLine.enter().append('line').attr('class', 'dev low');
          $devLowLine.transition().duration(200).attr('x1', _.compose(x1, subNameMap)).attr('x2', function(d) {
            return _.compose(x1, subNameMap)(d) + x1.rangeBand();
          }).attr('y1', function(d) {
            return y(0);
          }).attr('y2', function(d) {
            return y(0);
          });
          $devrect = $devG.selectAll('rect.dev').data(function(d) {
            return [d];
          });
          $devrect.enter().append('rect').attr('class', 'dev');
          $devrect.transition().duration(200).attr('width', x1.rangeBand() * .25).attr('x', function(d) {
            return x1(subNameMap(d)) + x1.rangeBand() * .375;
          }).attr('y', function(d) {
            return y(d.stdev);
          }).attr('height', function(d) {
            return height - y(d.stdev);
          });
          $xAxis.transition().duration(200).call(xAxis);
          $yAxis.transition().duration(200).call(yAxis);
          $legend = $svg.selectAll('.legend').data(allSubKeys);
          $legendEnter = $legend.enter().append('g').attr('class', 'legend');
          $legend.attr('transform', function(d, i) {
            return "translate(0," + (i * 20 - margin.top) + ")";
          });
          $legendEnter.append('rect');
          $legend.select('rect').attr('x', width - 18).attr('width', 18).attr('height', 18).style('fill', function(d) {
            return color(allSubKeys.indexOf(d));
          });
          $legendEnter.append('text');
          return $legend.select('text').attr('x', width - 24).attr('y', 9).attr('dy', '.35em').style('text-anchor', 'end').text(function(d) {
            return d;
          });
        };
        return null;
      });
    };
    chart.x = function(map) {
      var xMap;

      xMap = map != null ? map : xMap;
      return chart;
    };
    chart.y = function(map) {
      var yMap;

      yMap = map != null ? map : yMap;
      return chart;
    };
    chart.yB = function(map) {
      var yBMap;

      yBMap = map != null ? map : yBMap;
      return chart;
    };
    chart.height = function(val) {
      height = val != null ? val : height;
      return chart;
    };
    return chart;
  };

}).call(this);
