// Generated by CoffeeScript 1.6.2
(function() {
  var addBack, groupByBrandName, groupByParentIdOnly, pack;

  pack = function(root, data) {
    data.forEach(function(d, i) {
      if (d !== null && d.wurfl_fall_back === root.wurfl_device_id) {
        data = pack(d, data);
        root.children.push(d);
        return data[i] = null;
      }
    });
    return data;
  };

  addBack = function(root) {
    if (root.children.length > 0) {
      root.children.forEach(addBack);
      return root.children.push({
        children: [],
        wurfl_device_id: root.wurfl_device_id,
        brand_name: root.brand_name,
        model_name: root.model_name,
        conv: root.conv,
        visits: root.visits
      });
    }
  };

  groupByBrandName = function(data) {
    var groups;

    groups = _(data).groupBy(function(d) {
      return d.brand_name;
    });
    return _(groups).map(function(darr, key) {
      var groupAverageConv, groupStdevConversion, groupSubs, groupVisits, _i, _j, _ref, _ref1, _results, _results1;

      groupVisits = darr.map(function(d) {
        return d.visits;
      }).reduce(function(a, b) {
        return a + b;
      });
      groupSubs = darr.map(function(d) {
        return d.subscribers;
      }).reduce(function(a, b) {
        return a + b;
      });
      groupAverageConv = groupSubs / groupVisits;
      groupStdevConversion = darr.map(function(g) {
        return Math.sqrt(Math.pow(g.conv - groupAverageConv, 2)) * g.visits / groupVisits;
      }).reduce(function(a, b) {
        return a + b;
      });
      (function() {
        _results = [];
        for (var _i = 0, _ref = darr.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this).forEach(function(i) {
        var d;

        d = darr[i];
        if (!!d) {
          return darr = pack(darr[i], darr);
        }
      });
      darr = darr.filter(function(d) {
        return d !== null;
      });
      (function() {
        _results1 = [];
        for (var _j = 0, _ref1 = darr.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; 0 <= _ref1 ? _j++ : _j--){ _results1.push(_j); }
        return _results1;
      }).apply(this).forEach(function(i) {
        return addBack(darr[i]);
      });
      return {
        averageConversion: groupAverageConv,
        stdevConversion: groupStdevConversion,
        children: darr
      };
    });
  };

  groupByParentIdOnly = function(data) {
    var _i, _j, _ref, _ref1, _results, _results1;

    (function() {
      _results = [];
      for (var _i = 0, _ref = data.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this).forEach(function(i) {
      var d;

      d = data[i];
      if (!!d) {
        data = pack(data[i], data);
      }
      return data = data.filter(function(d) {
        return d !== null;
      });
    });
    (function() {
      _results1 = [];
      for (var _j = 0, _ref1 = data.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; 0 <= _ref1 ? _j++ : _j--){ _results1.push(_j); }
      return _results1;
    }).apply(this).forEach(function(i) {
      return addBack(data[i]);
    });
    return data;
  };

  d3.csv('charts/treemap/data/devices-ae.csv', function(data) {
    var chart, more, moreSubs, moreVisits, totalConv, totalSubs, totalVisits, tree;

    data = data.map(function(d) {
      return {
        wurfl_device_id: d.wurfl_device_id,
        wurfl_fall_back: d.wurfl_fall_back,
        brand_name: d.brand_name,
        model_name: d.model_name,
        visits: +d.visits,
        subscribers: +d.subscribers,
        conv: +d.conv,
        children: []
      };
    });
    totalVisits = data.map(function(d) {
      return d.visits;
    }).reduce(function(a, b) {
      return a + b;
    });
    totalSubs = data.map(function(d) {
      return d.subscribers;
    }).reduce(function(a, b) {
      return a + b;
    });
    totalConv = totalSubs / totalVisits;
    more = data.filter(function(d) {
      return d.visits <= 100;
    });
    moreVisits = more.map(function(d) {
      return d.visits;
    }).reduce(function(a, b) {
      return a + b;
    });
    moreSubs = more.map(function(d) {
      return d.subscribers;
    }).reduce(function(a, b) {
      return a + b;
    });
    data = data.filter(function(d) {
      return d.visits > 100;
    });
    data.push({
      children: [],
      wurfl_fall_back: 'root',
      wurfl_device_id: 'more...',
      brand_name: 'more',
      model_name: '..',
      visits: moreVisits,
      subscribers: moreSubs,
      conv: moreSubs / moreVisits
    });
    data = groupByBrandName(data);
    window.data = data;
    tree = {
      children: data,
      wurfl_device_id: 'root',
      brand_name: 'root',
      model_name: 'root',
      visits: 0
    };
    chart = treeMapZoomableChart();
    d3.select('#chart').call(chart);
    return chart.draw(tree);
  });

}).call(this);
