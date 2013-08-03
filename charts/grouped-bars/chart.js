// Generated by CoffeeScript 1.6.2
(function() {
  var chart, sum;

  sum = function(arr) {
    if (arr.length === 0) {
      return 0;
    }
    if (arr.length === 1) {
      return arr[0];
    }
    return arr.reduce(function(a, b) {
      return a + b;
    });
  };

  chart = new groupedBarsChart();

  d3.select('#chart').call(chart);

  d3.csv('charts/grouped-bars/data/ae.csv', function(raw) {
    var data, fresh, index, next, redraw;

    fresh = function() {
      return raw.map(function(d) {
        return {
          wurfl_device_id: d.wurfl_device_id,
          wurfl_fall_back: d.wurfl_fall_back,
          brand_name: d.brand_name,
          model_name: d.model_name,
          visits: +d.visits,
          subscribers: +d.subscribers,
          method: d.method,
          conv: (+d.conv) || 0,
          device_os: d.device_os,
          children: []
        };
      });
    };
    redraw = function(freshData, wurflid) {
      var data, hierarchy, mainGroupMap, parts, subGroupsMap;

      data = freshData.map(function(d) {
        return {
          method: d.method,
          device: (d.wurfl_device_id === wurflid ? wurflid : 'Everything Else'),
          visits: d.visits,
          subscribers: d.subscribers,
          conv: d.conv
        };
      });
      mainGroupMap = function(d) {
        return d.method;
      };
      subGroupsMap = function(d) {
        return d.device;
      };
      parts = _.chain(data).groupBy(mainGroupMap).value();
      hierarchy = _(parts).map(function(arr, key) {
        return {
          name: key,
          value: _.chain(arr).groupBy(subGroupsMap).map(function(sarr, skey) {
            var mu, subGroupVisits;

            subGroupVisits = sum(sarr.map(function(a) {
              return a.visits;
            }));
            mu = sarr.length === 0 ? 0 : sum(sarr.map(function(a) {
              return a.subscribers;
            })) / subGroupVisits;
            return {
              name: skey,
              value: mu,
              stdev: sarr.length < 2 ? 0 : sum(sarr.map(function(d) {
                return Math.sqrt(Math.pow(d.conv - mu, 2)) * d.visits / subGroupVisits;
              }))
            };
          }).value()
        };
      });
      return chart.draw(hierarchy);
    };
    data = _.chain(fresh()).groupBy(function(d) {
      return d.wurfl_device_id;
    }).map(function(arr, key) {
      return {
        wurfl_device_id: key,
        visits: sum(arr.map(function(a) {
          return a.visits;
        }))
      };
    }).sortBy(function(a) {
      return -a.visits;
    }).value();
    index = -1;
    next = function() {
      var key;

      key = data[++index].wurfl_device_id;
      return redraw(fresh(), key);
    };
    return next();
  });

}).call(this);
