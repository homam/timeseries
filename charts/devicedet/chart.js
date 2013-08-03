// Generated by CoffeeScript 1.6.2
(function() {
  var addBack, chart, collectLongTail, createSubMethodDeviceHierarchy, data, draw, drawSubMethodDeviceChart, even, f, fp, g, gp, groupBy, groupByBrandName, h, hp, isPrime, makeTreeByParentId, pack, subMethodDeviceConvChart, subMethodDeviceVisitsChart, sum;

  isPrime = function(x) {
    return [2, 3, 5, 7].indexOf(x) > -1;
  };

  even = function(x) {
    return x % 2 === 0;
  };

  h = function(map, xs) {
    return map(xs.filter(function(x) {
      return x <= 5;
    }));
  };

  g = function(map, xs) {
    return _.chain(xs).groupBy(isPrime).map(function(arr) {
      return map(arr);
    }).value();
  };

  f = function(map, xs) {
    return _.chain(xs).groupBy(even).map(function(arr) {
      return map(arr);
    }).value();
  };

  data = _.range(1, 11);

  hp = _.partial(h, _.identity);

  gp = _.partial(g, hp);

  fp = _.partial(f, gp);

  console.log(fp(data));

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

  subMethodDeviceConvChart = new groupedBarsChart();

  d3.select('#submethodDevice-conv-chart').call(subMethodDeviceConvChart);

  subMethodDeviceVisitsChart = new groupedBarsChart();

  d3.select('#submethodDevice-visits-chart').call(subMethodDeviceVisitsChart);

  drawSubMethodDeviceChart = function(node, data, compareConvWithOnlyConvertingDevices) {
    var convHierarchy, rootName, visitsHierarchy, zip, zipped;

    zip = function(n) {
      var c, subscribers, visits, wurflIds, zipped, _i, _len, _ref;

      zipped = n.children.map(function(c) {
        return zip(c);
      });
      visits = zipped.length === 0 ? 0 : zipped.map(function(d) {
        return d.visits;
      }).reduce(function(a, b) {
        return a + b;
      });
      subscribers = zipped.length === 0 ? 0 : zipped.map(function(d) {
        return d.subscribers;
      }).reduce(function(a, b) {
        return a + b;
      });
      wurflIds = _.flatten(zipped.map(function(c) {
        return c.wurflIds;
      }));
      if (!!n.wurfl_device_id) {
        wurflIds.push(n.wurfl_device_id);
      }
      if (!!n.collected_children) {
        _ref = n.collected_children;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          wurflIds.push(c.wurfl_device_id);
        }
      }
      return {
        visits: (n.visits || 0) + visits,
        subscribers: (n.subscribers || 0) + subscribers,
        wurflIds: wurflIds
      };
    };
    zipped = zip(node);
    rootName = node.wurfl_device_id || zipped.wurflIds[0];
    convHierarchy = createSubMethodDeviceHierarchy(data, zipped.wurflIds, rootName, function(sarr, skey) {
      var mu, subGroupVisits;

      if (compareConvWithOnlyConvertingDevices) {
        sarr = sarr.filter(function(d) {
          return d.subscribers > 0;
        });
      }
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
    });
    subMethodDeviceConvChart.draw(convHierarchy);
    visitsHierarchy = createSubMethodDeviceHierarchy(data, zipped.wurflIds, rootName, function(sarr, skey, marr, raw) {
      var mainGroupVisits, majorVisits, subGroupVisits;

      majorVisits = sum(raw.filter(function(d) {
        return d.device === skey;
      }).map(function(d) {
        return d.visits;
      }));
      mainGroupVisits = sum(marr.map(function(d) {
        return d.visits;
      }));
      subGroupVisits = sum(sarr.map(function(a) {
        return a.visits;
      }));
      return {
        name: skey,
        value: subGroupVisits / majorVisits,
        stdev: 0
      };
    });
    return subMethodDeviceVisitsChart.draw(visitsHierarchy);
  };

  createSubMethodDeviceHierarchy = function(data, wurflIds, name, barMaker) {
    var allSubKeys, byDevices, byMethods, hierarchy, mainValueMap, subNameMap;

    data = data.map(function(d) {
      return {
        method: d.method,
        device: (wurflIds.indexOf(d.wurfl_device_id) > -1 ? name : 'Everything Else'),
        visits: d.visits,
        subscribers: d.subscribers,
        conv: d.conv
      };
    });
    byMethods = _(data).groupBy(function(d) {
      return d.method;
    });
    byDevices = _(data).groupBy(function(d) {
      return d.device;
    });
    hierarchy = _(byMethods).map(function(arr, key) {
      return {
        name: key,
        value: _.chain(arr).groupBy(function(d) {
          return d.device;
        }).map(function(sarr, skey) {
          return barMaker(sarr, skey, arr, data);
        }).value()
      };
    });
    mainValueMap = function(v) {
      return v.value;
    };
    subNameMap = function(v) {
      return v.name;
    };
    allSubKeys = _.uniq(_.flatten(hierarchy.map(function(d) {
      return mainValueMap(d).map(subNameMap);
    })));
    hierarchy = hierarchy.map(function(h) {
      allSubKeys.forEach(function(k, i) {
        if (!h.value[i] || h.value[i].name !== k) {
          return h.value.splice(i, 0, {
            name: k,
            value: 0,
            stdev: 0
          });
        }
      });
      return h;
    });
    return _(hierarchy).sortBy(function(v) {
      return v.name;
    });
  };

  draw = function(data, method, chartDataMap) {
    var chartData, totalConv, totalStdevConv, totalSubs, totalVisits, tree;

    chartData = data.filter((function(d) {
      return method === d.method;
    }));
    totalVisits = chartData.map(function(d) {
      return d.visits;
    }).reduce(function(a, b) {
      return a + b;
    });
    totalSubs = chartData.map(function(d) {
      return d.subscribers;
    }).reduce(function(a, b) {
      return a + b;
    });
    totalConv = totalSubs / totalVisits;
    totalStdevConv = chartData.map(function(g) {
      return Math.sqrt(Math.pow(g.conv - totalConv, 2)) * g.visits / totalVisits;
    }).reduce(function(a, b) {
      return a + b;
    });
    chartData = chartDataMap(chartData);
    window.chartData = chartData;
    tree = {
      children: chartData,
      wurfl_device_id: 'root',
      brand_name: 'root',
      model_name: 'root',
      averageConversion: totalConv,
      stdevConversion: totalStdevConv,
      visits: 0
    };
    chart.draw(tree);
    return tree;
  };

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

  makeTreeByParentId = function(data) {
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

  addBack = function(root) {
    if (root.children.length > 0) {
      root.children.forEach(addBack);
      root.children.push({
        children: [],
        wurfl_device_id: root.wurfl_device_id,
        wurfl_fall_back: root.wurfl_fall_back,
        brand_name: root.brand_name,
        model_name: root.model_name,
        conv: root.conv,
        device_os: root.device_os,
        visits: root.visits,
        subscribers: root.subscribers
      });
      root.visits = 0;
      root.subscribers = 0;
      return root.conv = 0;
    }
  };

  groupBy = function(childrenMap, what, data) {
    var groups;

    groups = _(data).groupBy(what);
    return _(groups).map(function(darr) {
      var groupAverageConv, groupStdevConversion, groupSubs, groupVisits;

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
      return {
        averageConversion: groupAverageConv,
        stdevConversion: groupStdevConversion,
        children: childrenMap(darr)
      };
    });
  };

  collectLongTail = function(data) {
    var more, moreSubs, moreVisits;

    if (data.length < 2) {
      return data;
    }
    more = data.filter(function(d) {
      return d.visits <= 100;
    });
    if (more.length < 2) {
      return data;
    }
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
      device_os: 'any',
      visits: moreVisits,
      subscribers: moreSubs,
      conv: moreSubs / moreVisits,
      collected_children: more
    });
    return data;
  };

  groupByBrandName = function(data) {
    var brandF, osF;

    osF = _.partial(groupBy, _.compose(makeTreeByParentId, collectLongTail), function(d) {
      return d.device_os;
    });
    brandF = _.partial(groupBy, osF, function(d) {
      return d.brand_name;
    });
    return brandF(data);
  };

  chart = treeMapZoomableChart();

  d3.select('#chart').call(chart);

  d3.csv('charts/devicedet/data/ae.csv', function(raw) {
    var fresh, lastTree, makeGroupByFunction, redraw, redrawSubMethodDeviceChart, subMethods;

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
    subMethods = _.chain(fresh()).map(function(d) {
      return d.method;
    }).uniq().value();
    d3.select('#submethods').data([subMethods]).on('change', function() {
      return redraw();
    }).selectAll('option').data(function(d) {
      return d;
    }).enter().append('option').text(function(d) {
      return d;
    });
    makeGroupByFunction = function(order, treefy, cutLongTail) {
      var l, lastF, t;

      order = _(order).reverse();
      t = treefy ? makeTreeByParentId : _.identity;
      l = cutLongTail ? collectLongTail : _.identity;
      lastF = _.compose(t, l);
      order.forEach(function(p) {
        return lastF = _.partial(groupBy, lastF, function(d) {
          return d[p];
        });
      });
      return lastF;
    };
    lastTree = null;
    redrawSubMethodDeviceChart = function(tree) {
      if (tree == null) {
        tree = null;
      }
      tree = tree || lastTree;
      lastTree = tree;
      return drawSubMethodDeviceChart(tree, fresh(), $('#onlyConvertingDevices')[0].checked);
    };
    redraw = function() {
      var groupBys, tree;

      groupBys = ($('#groupbys-bin').find('li').map(function() {
        return $(this).attr('data-groupby');
      })).get();
      tree = draw(fresh(), $("#submethods").val(), makeGroupByFunction(groupBys, $('#treefy')[0].checked, $('#collectLongTail')[0].checked));
      return redrawSubMethodDeviceChart(tree);
    };
    redraw();
    $(function() {
      $('#groupbys-bin, #groupbys').sortable({
        connectWith: '.connected'
      });
      $('#groupbys-bin, #groupbys').on('dragend', function() {
        return redraw();
      });
      $('#treefy, #collectLongTail').on('change', function() {
        return redraw();
      });
      return $('#onlyConvertingDevices').on('change', function() {
        return redrawSubMethodDeviceChart();
      });
    });
    return chart.zoomed(function(node) {
      return redrawSubMethodDeviceChart(node);
    });
  });

}).call(this);
