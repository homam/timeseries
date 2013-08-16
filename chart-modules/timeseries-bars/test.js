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
    return d3.csv('/charts/simple/data/iraq-android-refs.json', function(data) {
      var chart, dateRange, groups, msInaDay, parseDate;

      parseDate = d3.time.format("%m/%d/%Y").parse;
      data = data.map(function(d) {
        d.date = parseDate(d.date);
        d.visits = +d.visits;
        d.subs = +d.subs;
        d.conv = +d.conv;
        return d;
      });
      groups = _(data).groupBy(function(d) {
        return d.ref;
      });
      dateRange = d3.extent(data.map(function(d) {
        return d.date;
      }));
      msInaDay = 24 * 60 * 60 * 1000;
      _.keys(groups).forEach(function(key) {
        var date, group, i, index, _i, _ref, _ref1, _results;

        group = groups[key];
        index = -1;
        _results = [];
        for (i = _i = _ref = +dateRange[0], _ref1 = +dateRange[1]; msInaDay > 0 ? _i <= _ref1 : _i >= _ref1; i = _i += msInaDay) {
          ++index;
          date = new Date(i);
          if (!_(group).some(function(d) {
            return Math.abs(+d.date - +date) < 1000;
          })) {
            group.splice(index, 0, {
              date: date,
              visits: 0,
              subs: 0,
              conv: 0
            });
            _results.push(groups[key] = group);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      chart = chartMaker().width(800).margin({
        right: 40
      }).tooltip(tooltip().text(function(d) {
        return JSON.stringify(d);
      })).x(function(d) {
        return d.date;
      }).y(function(d) {
        return d.visits;
      }).yB(function(d) {
        return d.subs;
      });
      d3.select('#chart').datum(groups['wap p11']).call(chart);
      return setTimeout(function() {
        chart.yDomain(d3.extent);
        return d3.select('#chart').datum(groups['wap p155']).call(chart);
      }, 2000);
    });
  });

}).call(this);
