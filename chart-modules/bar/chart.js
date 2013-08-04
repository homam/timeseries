// Generated by CoffeeScript 1.6.2
(function() {
  var Property;

  Property = (function() {
    function Property(_onSet) {
      this._onSet = _onSet;
    }

    Property.prototype._value = null;

    Property.prototype.set = function(value) {
      this._value = value;
      return this._onSet(value);
    };

    Property.prototype.get = function() {
      return this._value;
    };

    Property.prototype.reset = function() {
      return this.set(this._value);
    };

    return Property;

  })();

  define([], function() {
    return function() {
      var chart, devMap, height, margin, nameMap, properties, valueMap, width, x, xAxis, y, yAxis;

      margin = {
        top: 20,
        right: 0,
        bottom: 20,
        left: 70
      };
      width = 720;
      height = 300;
      x = d3.scale.ordinal();
      y = d3.scale.linear();
      xAxis = d3.svg.axis().scale(x).orient('bottom');
      yAxis = d3.svg.axis().scale(y).orient('left').tickFormat(d3.format(','));
      nameMap = function(d) {
        return d.name;
      };
      valueMap = function(d) {
        return d.value;
      };
      devMap = function(d) {
        return d.dev;
      };
      properties = {
        width: new Property(function(value) {
          width = value - margin.left - margin.right;
          x.rangeRoundBands([0, width], .1);
          return yAxis.tickSize(-width, 0, 0);
        }),
        height: new Property(function(value) {
          height = value - margin.top - margin.bottom;
          return y.range([height, 0]);
        }),
        margin: new Property(function(value) {
          margin = value;
          properties.width.reset();
          return properties.height.reset();
        }),
        names: new Property(function(value) {
          return nameMap = value;
        }),
        values: new Property(function(value) {
          return valueMap = value;
        }),
        devs: new Property(function(value) {
          return devMap = value;
        })
      };
      properties.width.set(width);
      properties.height.set(height);
      chart = function(selection) {
        selection.each(function(data) {
          var $devG, $devGEnter, $g, $gEnter, $main, $mainEnter, $rect, $selection, $svg, $xAxis, $yAxis, keys;

          $selection = d3.select(this);
          $svg = $selection.selectAll('svg').data([data]);
          $gEnter = $svg.enter().append('svg').append('g');
          $svg.attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom);
          $g = $svg.select('g').attr('transform', "translate(" + margin.left + "," + margin.top + ")");
          $gEnter.append('g').attr('class', 'x axis');
          $xAxis = $svg.select('.x.axis').attr("transform", "translate(0," + height + ")");
          $gEnter.append('g').attr('class', 'y axis');
          $yAxis = $svg.select('.y.axis');
          keys = _.flatten(data.map(nameMap));
          x.domain(keys);
          y.domain([0, d3.max(data.map(valueMap))]);
          $main = $g.selectAll('g.main').data(data);
          $mainEnter = $main.enter().append('g').attr('class', 'main');
          $main.transition().duration(200);
          $mainEnter.append('rect');
          $rect = $main.select('rect');
          $rect.transition().duration(200).attr('width', x.rangeBand()).attr('x', function(d) {
            return x(nameMap(d));
          }).attr('y', function(d) {
            return y(valueMap(d));
          }).attr('height', function(d) {
            return height - y(valueMap(d));
          }).style('fill', function(d, i) {
            return '#ff7f0e';
          });
          $devGEnter = $mainEnter.append('g').attr('class', 'dev');
          $devG = $main.select('g.dev').transition().duration(200).attr('transform', function(d) {
            return 'translate(0,' + (-height + y(valueMap(d)) - (-height + y(devMap(d))) / 2) + ')';
          });
          $devGEnter.append('line').attr('class', 'dev up');
          $devG.select('line.dev.up').transition().duration(200).attr('x1', _.compose(x, nameMap)).attr('x2', function(d) {
            return _.compose(x, nameMap)(d) + x.rangeBand();
          }).attr('y1', _.compose(y, devMap)).attr('y2', _.compose(y, devMap));
          $devGEnter.append('line').attr('class', 'dev low');
          $devG.select('line.dev.low').transition().duration(200).attr('x1', _.compose(x, nameMap)).attr('x2', function(d) {
            return _.compose(x, nameMap)(d) + x.rangeBand();
          }).attr('y1', y(0)).attr('y2', y(0));
          $devGEnter.append('rect').attr('class', 'dev');
          $devG.select('rect.dev').transition().duration(200).attr('width', x.rangeBand() * .25).attr('x', function(d) {
            return x(nameMap(d)) + x.rangeBand() * .375;
          }).attr('y', _.compose(y, devMap)).attr('height', function(d) {
            return height - (_.compose(y, devMap))(d);
          });
          $main.exit().select('rect').attr('y', 0).attr('height', 0);
          $xAxis.transition().duration(200).call(xAxis);
          return $yAxis.transition().duration(200).call(yAxis);
        });
        null;
        return d3.keys(properties).forEach(function(k) {
          var p;

          p = properties[k];
          return chart[k] = function(val) {
            if (!!arguments.length) {
              p.set(val);
              return chart;
            } else {
              return p.get();
            }
          };
        });
      };
      return chart;
    };
  });

}).call(this);
