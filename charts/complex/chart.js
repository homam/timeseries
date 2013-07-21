// Generated by CoffeeScript 1.6.2
(function() {
  var cumalativeMovingAverage, movingAverage;

  cumalativeMovingAverage = function(map) {
    var sum;

    sum = 0;
    return function(d, i) {
      sum += map(d);
      return sum / (i + 1);
    };
  };

  movingAverage = function(map, size) {
    var arr;

    arr = [];
    return function(d, i) {
      var val;

      if (arr.length >= size) {
        arr = arr.slice(1);
      }
      arr.push(map(d));
      val = (arr.reduce(function(a, b) {
        return a + b;
      })) / arr.length;
      return val;
    };
  };

  d3.csv('charts/simple/data/iraq-android-refs.json', function(data) {
    var cumulativeSmoother, parseDate, smoother;

    parseDate = d3.time.format("%m/%d/%Y").parse;
    data = data.map(function(d) {
      d.date = parseDate(d.date);
      d.visits = +d.visits;
      d.subs = +d.subs;
      d.conv = +d.conv;
      return d;
    });
    window.data = data = data.filter(function(d) {
      return 'wap p155' === d.ref;
    });
    cumulativeSmoother = cumalativeMovingAverage(function(d) {
      return d.visits;
    });
    smoother = movingAverage((function(d) {
      return d.visits;
    }), 7);
    window.draw = function() {
      return window.chart = d3.select('#chart1').datum(data).call(complexTimeSeriesChart().x(function(d) {
        return d.date;
      }).ys([
        (function(d) {
          return d.visits;
        }), smoother, cumulativeSmoother
      ]));
    };
    return draw();
  });

}).call(this);
