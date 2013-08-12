// Generated by CoffeeScript 1.6.2
(function() {
  require.config({
    baseUrl: '',
    map: {
      '*': {
        'css': '/javascript/libs/require-css/css',
        'text': '/javascript/libs/require-text'
      }
    }
  });

  require(['chart.js'], function(chartMaker) {
    var chart, testData;

    testData = [
      {
        name: 'A long name',
        value: 645
      }, {
        name: 'Some name',
        value: 441
      }, {
        name: 'Short',
        value: 273
      }
    ];
    chart = chartMaker().margin({
      right: 120
    }).width(400);
    d3.select('#chart').datum(testData).call(chart);
    return setTimeout(function() {
      var newData;

      newData = testData.map(function(d) {
        return {
          name: d.name,
          value: d.value * Math.random()
        };
      }).map(function(d) {
        return [d.name, d.value];
      });
      chart.width(300);
      chart.height(200);
      chart.names(function(d) {
        return d[0];
      });
      chart.values(function(d) {
        return d[1];
      });
      return d3.select('#chart').datum(newData).call(chart);
    }, 2000);
  });

}).call(this);