// Generated by CoffeeScript 1.6.2
(function() {
  require.config({
    baseUrl: '',
    map: {
      '*': {
        'css': 'javascript/libs/require-css/css',
        'text': 'javascript/libs/require-text'
      }
    }
  });

  require(['chart-modules/bar/chart', 'chart-modules/bar-groups/chart', 'chart-modules/pie/chart', 'chart-modules/timeseries-bars/chart', 'chart-modules/common/d3-tooltip', 'chart-modules/utils/reduceLongTail', 'chart-modules/utils/sum'], function(barChart, barGroupsChart, pieChart, timeSeriesBars, tooltip, reduceLongTail, sum) {
    var chart, chartId, country, draw, drawSubMethodDeviceChart, fresh, fromDate, lastData, lastTimeSeriesData, lastTree, makeGroupByFunction, makeTreeByParentId, methodColor, methodVisitsSubsTimeSeriesChart, populateSubMethodsSelect, query, redraw, redrawSubMethodDeviceChart, subMethodDeviceConvChart, subMethodDeviceVisitsChart, toDate, totalVisitsSubsTimeSeriesChart, visitsBySubMethodsChart, visitsBySubMethodsPieChart;

    methodColor = (function() {
      var colors, i, map;

      colors = ['#e55dcd', '#aa55e1', '#514cde', '#4496db', '#3cd7c5', '#35d466', '#58d12d', '#b2ce26', '#ca841f', '#c71b18'].reverse();
      i = -1;
      map = {};
      return function(method) {
        if (!map[method]) {
          map[method] = colors[++i];
        }
        return map[method];
      };
    })();
    reduceLongTail = (function() {
      var sumVisitsWithChildren;

      sumVisitsWithChildren = function(d) {
        if (!!d.children && d.children.length > 0) {
          return (d.visits || 0) + d.children.map(function(c) {
            return sumVisitsWithChildren(c);
          }).reduce(function(a, b) {
            return a + b;
          });
        } else {
          return d.visits || 0;
        }
      };
      return _.partial(reduceLongTail, (function(v) {
        return sumVisitsWithChildren(v) <= 100;
      }), function(tail) {
        var subs, visits;

        visits = sum(tail.map(function(v) {
          return v.visits;
        }));
        subs = sum(tail.map(function(v) {
          return v.subscribers;
        }));
        return {
          children: [],
          wurfl_fall_back: tail[0].wurfl_fall_back,
          wurfl_device_id: 'more...',
          brand_name: tail[0].brand_name,
          model_name: '..',
          device_os: tail[0].device_os,
          visits: visits,
          subscribers: subs,
          conv: subs / visits,
          collected_children: tail
        };
      });
    })();
    subMethodDeviceConvChart = barGroupsChart().yAxisTickFormat(d3.format('.1%'));
    subMethodDeviceVisitsChart = barGroupsChart().yAxisTickFormat(d3.format('.1%'));
    totalVisitsSubsTimeSeriesChart = timeSeriesBars().width(800).margin({
      right: 70,
      left: 70,
      bottom: 50
    }).x(function(d) {
      return d.date;
    }).y(function(d) {
      return d.visits;
    }).yB(function(d) {
      return d.subscribers;
    });
    methodVisitsSubsTimeSeriesChart = (function() {
      var cache;

      cache = {};
      return function(method) {
        if (!cache[method]) {
          cache[method] = timeSeriesBars().width(800).height(120).margin({
            right: 70,
            left: 70,
            bottom: 0,
            top: 20
          }).x(function(d) {
            return d.date;
          }).y(function(d) {
            return d.visits;
          }).yB(function(d) {
            return d.subscribers;
          });
        }
        return cache[method];
      };
    })();
    visitsBySubMethodsChart = barChart().tooltip(tooltip().text(function(d) {
      return JSON.stringify(d);
    }));
    visitsBySubMethodsPieChart = pieChart().colors(methodColor);
    drawSubMethodDeviceChart = (function() {
      var createSubMethodDeviceHierarchy;

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
      return function(node, data, timeSeriesData, compareConvWithOnlyConvertingDevices) {
        var $chart, $charts, allSubMethods, allWids, allWurlfIds, convHierarchy, existingSubMethods, filteredMethodTimeSeries, filteredTimeSeries, ftsData, m, method, rootName, targetDevices, totalVisits, tsData, visitsData, visitsHierarchy, _i, _j, _len, _len1, _ref, _results;

        allWurlfIds = function(n, r) {
          var m, _i, _j, _len, _len1, _ref, _ref1;

          if (n.wurfl_device_id) {
            r.push(n.wurfl_device_id);
          }
          if (n.children && n.children.length > 0) {
            _ref = n.children;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              m = _ref[_i];
              allWurlfIds(m, r);
            }
          }
          if (n.collected_children && n.collected_children.length > 0) {
            _ref1 = n.collected_children;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              m = _ref1[_j];
              allWurlfIds(m, r);
            }
          }
          return r;
        };
        allWids = _.flatten(allWurlfIds(node, []));
        rootName = node.wurfl_device_id || allWids[0];
        convHierarchy = createSubMethodDeviceHierarchy(data, allWids, rootName, function(sarr, skey) {
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
        d3.select('#submethodDevice-conv-chart').datum(convHierarchy).call(subMethodDeviceConvChart);
        visitsHierarchy = createSubMethodDeviceHierarchy(data, allWids, rootName, function(sarr, skey, marr, raw) {
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
            visits: subGroupVisits + mainGroupVisits,
            name: skey,
            value: subGroupVisits / majorVisits,
            stdev: 0
          };
        });
        d3.select('#submethodDevice-visits-chart').datum(visitsHierarchy).call(subMethodDeviceVisitsChart);
        filteredTimeSeries = timeSeriesData.map(function(tuple) {
          return [
            tuple[0], tuple[1].filter(function(d) {
              return allWids.indexOf(d.wurfl_device_id) > -1;
            })
          ];
        });
        allSubMethods = _.chain(filteredTimeSeries.map(function(d) {
          return d[1];
        })).flatten().groupBy(function(d) {
          return d.method;
        }).map(function(arr, method) {
          return {
            method: method,
            visits: sum(arr.map(function(d) {
              return d.visits;
            }))
          };
        }).sortBy(function(d) {
          return -d.visits;
        }).map(function(d) {
          return d.method;
        }).value();
        targetDevices = data.filter(function(d) {
          return allWids.indexOf(d.wurfl_device_id) > -1;
        });
        visitsData = _.chain(targetDevices).groupBy(function(d) {
          return d.method;
        }).map(function(arr, key) {
          return {
            name: key,
            value: sum(arr.map(function(a) {
              return a.visits;
            }))
          };
        }).value();
        existingSubMethods = visitsData.map(function(c) {
          return c.name;
        });
        _ref = allSubMethods.filter(function(s) {
          return existingSubMethods.indexOf(s) < 0;
        });
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          m = _ref[_i];
          visitsData.push({
            name: m,
            value: 0
          });
        }
        totalVisits = sum(visitsData.map(function(v) {
          return v.value;
        }));
        d3.select('#device-visits-bysubmethods-pie').datum(visitsData).call(visitsBySubMethodsPieChart);
        visitsBySubMethodsChart.tooltip().text(function(d) {
          return d.name + ' : ' + d3.format('%')(d.value / totalVisits);
        });
        d3.select('#device-visits-bysubmethods-chart').datum(_(visitsData).sortBy(function(a) {
          return a.name;
        })).call(visitsBySubMethodsChart);
        tsData = filteredTimeSeries.map(function(tuple) {
          return {
            date: new Date(tuple[0].date),
            visits: sum(tuple[1].map(function(d) {
              return d.visits;
            })),
            subscribers: sum(tuple[1].map(function(d) {
              return d.subscribers;
            }))
          };
        });
        d3.select('#visitsAndSubsOvertime-chart').datum(tsData).call(totalVisitsSubsTimeSeriesChart);
        $charts = d3.select('#visitsAndSubsOvertime-charts').selectAll('div.chart').data(allSubMethods);
        $charts.enter().append("div").attr('class', function(d) {
          return d + ' chart';
        }).append("h3");
        $charts.style('display', 'none');
        _results = [];
        for (_j = 0, _len1 = allSubMethods.length; _j < _len1; _j++) {
          method = allSubMethods[_j];
          filteredMethodTimeSeries = timeSeriesData.map(function(tuple) {
            return [
              tuple[0], tuple[1].filter(function(d) {
                return method === d.method && allWids.indexOf(d.wurfl_device_id) > -1;
              })
            ];
          });
          ftsData = filteredMethodTimeSeries.map(function(tuple) {
            return {
              date: new Date(tuple[0].date),
              visits: sum(tuple[1].map(function(d) {
                return d.visits;
              })),
              subscribers: sum(tuple[1].map(function(d) {
                return d.subscribers;
              }))
            };
          });
          $chart = d3.select('#visitsAndSubsOvertime-charts').select('.' + method);
          $chart.style('display', 'block');
          $chart.select('h3').text(method);
          $chart.datum(ftsData).call(methodVisitsSubsTimeSeriesChart(method));
          $chart.selectAll('rect.bar').style('fill', methodColor(method));
          _results.push($chart.selectAll('path.line').style('stroke', methodColor(method)));
        }
        return _results;
      };
    })();
    chartId = 'chart';
    $("#chart-container").html('<section id="' + chartId + '"></section>');
    chart = treeMapZoomableChart();
    d3.select('#' + chartId).call(chart);
    draw = function(data, method, chartDataMap) {
      var chartData, groups, totalConv, totalStdevConv, totalSubs, totalVisits, tree;

      chartData = null;
      if (!method) {
        groups = _(data).groupBy(function(d) {
          return d.wurfl_device_id;
        });
        chartData = _(groups).map(function(arr, key) {
          var item, subscribers, visits;

          visits = sum(arr.map(function(d) {
            return d.visits;
          }));
          subscribers = sum(arr.map(function(d) {
            return d.subscribers;
          }));
          item = _.clone(arr[0]);
          item.visits = visits;
          item.subscribers = subscribers;
          item.conv = subscribers / visits;
          item.method = method;
          return item;
        });
        window.cdata = chartData;
      } else {
        chartData = data.filter((function(d) {
          return method === d.method;
        }));
      }
      totalVisits = sum(chartData.map(function(d) {
        return d.visits;
      }));
      totalSubs = sum(chartData.map(function(d) {
        return d.subscribers;
      }));
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
    makeTreeByParentId = (function() {
      return function(cutLongTail, data) {
        var addToParent, d, findParent, root, _i, _len;

        data = _.clone(data);
        root = {
          children: []
        };
        findParent = function(node, children) {
          var c, parent, _i, _len;

          parent = _.find(children, function(d) {
            return d.wurfl_device_id === node.wurfl_fall_back;
          });
          if (!!parent) {
            return parent;
          }
          for (_i = 0, _len = children.length; _i < _len; _i++) {
            c = children[_i];
            parent = findParent(node, c.children);
            if (!!parent) {
              parent;
            }
          }
          return null;
        };
        addToParent = function(node) {
          var parent;

          parent = findParent(node, data);
          if (!!parent) {
            return parent.children.push(node);
          } else {
            return root.children.push(node);
          }
        };
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          d = data[_i];
          addToParent(d);
        }
        data = root.children;
        if (cutLongTail) {
          return reduceLongTail(data);
        } else {
          return data;
        }
      };
    })();
    makeGroupByFunction = (function() {
      var groupBy;

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
      return function(order, treefy, cutLongTail) {
        var l, lastF, t;

        order = _(order).reverse();
        t = treefy ? _.partial(makeTreeByParentId, cutLongTail) : _.identity;
        l = cutLongTail && !treefy ? reduceLongTail : _.identity;
        lastF = _.compose(t, l);
        order.forEach(function(p) {
          return lastF = _.partial(groupBy, lastF, function(d) {
            return d[p];
          });
        });
        return lastF;
      };
    })();
    query = (function() {
      var cached, cachedKey, cachedTimeSeries, getCache, makeCacheKey, parseTimeSeriesDataItem, saveCache;

      parseTimeSeriesDataItem = function(d) {
        return {
          visits: +d.Visits,
          subscribers: +d.Subscribers,
          wurfl_device_id: d.wurfl_device_id,
          method: d.Method.length > 0 ? d.Method : 'Null',
          conv: +d.Subscribers / +d.Visits
        };
      };
      cached = null;
      cachedTimeSeries = null;
      cachedKey = null;
      makeCacheKey = function(f, t, c) {
        return c + f.valueOf() + t.valueOf();
      };
      getCache = function(fromDate, toDate, country) {
        if (makeCacheKey(fromDate, toDate, country) === cachedKey) {
          return cached;
        } else {
          return null;
        }
      };
      saveCache = function(fromDate, toDate, country, aggregatedByWurflId, timeseries) {
        cachedKey = makeCacheKey(fromDate, toDate, country);
        cached = aggregatedByWurflId;
        return cachedTimeSeries = timeseries;
      };
      return function(fromDate, toDate, country) {
        var dates, gets, p, timezone, _i, _ref, _results;

        p = $.Deferred();
        if (getCache(fromDate, toDate, country)) {
          p.resolve({
            reduced: cached,
            overtime: cachedTimeSeries
          });
        } else {
          timezone = new Date().getTimezoneOffset() * -60 * 1000;
          dates = (toDate.valueOf() - fromDate.valueOf()) / (1000 * 60 * 60 * 24);
          gets = (function() {
            _results = [];
            for (var _i = 0, _ref = dates - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
            return _results;
          }).apply(this).map(function(i) {
            return fromDate.valueOf() + (i * (1000 * 60 * 60 * 24)) + timezone;
          }).map(function(d) {
            return {
              date: d,
              dateName: new Date(d).toISOString().split('T')[0]
            };
          }).map(function(d) {
            return {
              date: d.date,
              dateName: d.dateName,
              def: $.ajax('charts/devicedet-controls/data/' + country + '-' + d.dateName + '.csv', {
                context: d
              })
            };
          });
          $.when.apply($, gets.map(function(d) {
            return d.def;
          })).done(function() {
            var csv, csvs, items, timeSeries;

            items = null;
            timeSeries = null;
            if (gets.length > 1) {
              csvs = Array.prototype.slice.call(arguments, 0).map(function(d) {
                return d3.csv.parse(d[0]);
              });
              timeSeries = _.zip(this, csvs.map(function(csv) {
                return csv.map(parseTimeSeriesDataItem);
              }));
              items = _.chain(csvs).flatten();
            } else {
              csv = d3.csv.parse(arguments[0]);
              items = _.chain(csv);
              timeSeries = _.zip([this], [csv.map(parseTimeSeriesDataItem)]);
            }
            items = items.groupBy('wurfl_device_id').map(function(deviceArr) {
              return _.chain(deviceArr).groupBy('Method').map(function(arr, method) {
                var subscribers, visits;

                visits = sum(arr.map(function(d) {
                  return +d.Visits;
                }));
                subscribers = sum(arr.map(function(d) {
                  return +d.Subscribers;
                }));
                return {
                  wurfl_device_id: arr[0].wurfl_device_id,
                  wurfl_fall_back: arr[0].wurfl_fall_back,
                  brand_name: arr[0].brand_name,
                  model_name: arr[0].model_name,
                  device_os: arr[0].device_os,
                  visits: visits,
                  subscribers: subscribers,
                  method: method.length > 0 ? method : 'Null',
                  conv: subscribers / visits
                };
              }).value();
            }).flatten().value();
            saveCache(fromDate, toDate, country, items, timeSeries);
            return p.resolve({
              reduced: items,
              overtime: timeSeries
            });
          });
        }
        return p;
      };
    })();
    fromDate = new Date(2013, 8, 30);
    toDate = new Date(2013, 9, 4);
    country = 'om';
    ['ae', 'sa', 'om', 'iq', 'jo', 'lk'].sort().forEach(function(c) {
      return $("select[name=country]").append($("<option />").text(c));
    });
    $('#fromDate').val(d3.time.format('%Y-%m-%d')(fromDate));
    $('#toDate').val(d3.time.format('%Y-%m-%d')(new Date(toDate.valueOf() - (1000 * 60 * 60 * 24))));
    $("select[name=country]").val(country);
    $("input[type=date]").on('change', function() {
      var $this;

      $this = $(this);
      if ('fromDate' === $this.attr("id")) {
        fromDate = new Date($this.val());
      }
      if ('toDate' === $this.attr("id")) {
        toDate = new Date($this.val());
        toDate = new Date(toDate.valueOf() + (1000 * 60 * 60 * 24));
      }
      return redraw(false);
    });
    $("select[name=country]").change(function() {
      country = $("select[name=country]").val();
      return redraw(true);
    });
    fresh = function() {
      return query(fromDate, toDate, country).done(function(obj) {
        var items;

        items = obj.reduced;
        return _.chain(items).map(function(i) {
          i.children = [];
          return i;
        }).clone().value();
      });
    };
    window.fresh = fresh;
    populateSubMethodsSelect = function(data) {
      var $options, subMethods;

      subMethods = _.chain(data).map(function(d) {
        return d.method;
      }).uniq().value();
      subMethods.push('');
      $('#submethods').html('');
      d3.select('#submethods').data([subMethods]).on('change', function() {
        return redraw();
      });
      $options = d3.select('#submethods').selectAll('option').data(function(d) {
        return d;
      });
      $options.enter().append('option').text(function(d) {
        return d;
      });
      return $options.exit().remove(function(d) {
        debugger;
      });
    };
    lastTree = null;
    lastData = null;
    lastTimeSeriesData = null;
    redrawSubMethodDeviceChart = function(tree, data, timeSeriesData) {
      if (tree == null) {
        tree = null;
      }
      if (data == null) {
        data = null;
      }
      if (timeSeriesData == null) {
        timeSeriesData = null;
      }
      lastTree = tree || lastTree;
      lastData = data || lastData;
      lastTimeSeriesData = timeSeriesData || lastTimeSeriesData;
      return drawSubMethodDeviceChart(lastTree, lastData, lastTimeSeriesData, $('#onlyConvertingDevices')[0].checked);
    };
    redraw = function(countryChanged) {
      return fresh().done(function(obj) {
        var data, groupBys, overtime, tree;

        data = obj.reduced;
        console.log(sum(data.filter(function(d) {
          return 'Desktop' === d.device_os;
        }).map(function(d) {
          return d.visits;
        })));
        overtime = obj.overtime;
        if (countryChanged) {
          populateSubMethodsSelect(data);
        }
        groupBys = ($('#groupbys-bin').find('li').map(function() {
          return $(this).attr('data-groupby');
        })).get();
        tree = draw(data, $("#submethods").val(), makeGroupByFunction(groupBys, $('#treefy')[0].checked, $('#collectLongTail')[0].checked));
        return redrawSubMethodDeviceChart(tree, data, overtime);
      });
    };
    redraw(true);
    window.redraw = redraw;
    return $(function() {
      $('#groupbys-bin, #groupbys').sortable({
        connectWith: '.connected'
      });
      $('#groupbys-bin, #groupbys').on('dragend', function() {
        return redraw();
      });
      $('#treefy, #collectLongTail').on('change', function() {
        return redraw();
      });
      $('#onlyConvertingDevices').on('change', function() {
        return redrawSubMethodDeviceChart();
      });
      return chart.zoomed(function(node) {
        return redrawSubMethodDeviceChart(node);
      });
    });
  });

}).call(this);
