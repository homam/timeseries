// Generated by CoffeeScript 1.6.3
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

  require(['chart.js', '../common/d3-tooltip.js'], function(chartMaker, tooltip) {
    var chart, testData;
    testData = [
      {
        name: 'A',
        value: 345,
        dev: 31
      }, {
        name: 'B',
        value: 441,
        dev: 42
      }, {
        name: 'C',
        value: 273,
        dev: 12
      }
    ];
    chart = chartMaker().devs(function(d) {
      return d.dev;
    }).tooltip(tooltip().text(function(d) {
      return JSON.stringify(d);
    }));
    d3.select('#chart').datum(testData).call(chart);
    return setTimeout(function() {
      var newData;
      newData = testData.map(function(d) {
        return {
          name: d.name,
          value: d.value * Math.random(),
          dev: d.dev
        };
      }).map(function(d) {
        return [d.name, d.value, d.dev];
      });
      chart.width(300);
      chart.height(200);
      chart.margin({
        top: 0,
        left: 30,
        bottom: 20,
        right: 0
      });
      chart.names(function(d) {
        return d[0];
      });
      chart.values(function(d) {
        return d[1];
      });
      chart.devs(function(d) {
        return d[2] * 0;
      });
      chart.tooltip().text(function(d) {
        return d[0];
      });
      return d3.select('#chart').datum(newData).call(chart);
    }, 2000);
  });

}).call(this);
