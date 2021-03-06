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

  require(['chart.js', '../common/d3-tooltip.js'], function(chartMaker, tooltip) {
    var chart, testData;

    testData = [
      {
        name: 'A',
        values: [
          {
            name: 'Alpha',
            value: 345,
            dev: 31
          }, {
            name: 'Beta',
            value: 45,
            dev: 11
          }
        ]
      }, {
        name: 'B',
        values: [
          {
            name: 'Alpha',
            value: 441,
            dev: 42
          }, {
            name: 'Beta',
            value: 400,
            dev: 6
          }
        ]
      }, {
        name: 'C',
        values: [
          {
            name: 'Alpha',
            value: 273,
            dev: 12
          }, {
            name: 'Beta',
            value: 89,
            dev: 30
          }
        ]
      }
    ];
    chart = chartMaker().tooltip(tooltip().text(function(d) {
      return JSON.stringify(d);
    }));
    d3.select('#chart').datum(testData).call(chart);
    return;
    return setTimeout(function() {
      var newData;

      newData = testData.map(function(d) {
        return {
          name: d.name,
          value: [d.value[0]]
        };
      });
      chart.width(600);
      chart.height(200);
      chart.margin({
        top: 0,
        left: 30,
        bottom: 20,
        right: 0
      });
      d3.select('#chart').datum(newData).call(chart);
      return setTimeout(function() {
        return d3.select('#chart').datum(testData).call(chart);
      }, 10000);
    }, 2000);
  });

}).call(this);
