// Generated by CoffeeScript 1.6.3
(function() {
  d3.csv('charts/simple/data/iraq-android-refs.json', function(data) {
    var parseDate;
    parseDate = d3.time.format("%m/%d/%Y").parse;
    data = data.map(function(d) {
      d.date = parseDate(d.date);
      d.visits = +d.visits;
      d.subs = +d.subs;
      d.conv = +d.conv;
      return d;
    });
    window.c = multiTimeSeriesChart().x(function(d) {
      return d.date;
    }).y(function(d) {
      return d.visits;
    });
    window.draw = function() {
      return window.chart = d3.select('#chart1').datum(data).call(c);
    };
    return draw();
  });

}).call(this);
