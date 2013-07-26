// Generated by CoffeeScript 1.6.2
(function() {
  var chart, chartTable, convChart, deHighlightPage, highlightPage, reDraw, selectedPages, table;

  chartTable = function() {
    var chart, values;

    values = function(d) {
      return d.values;
    };
    chart = function(selection) {
      return selection.each(function() {
        var $table;

        $table = d3.select(this).append('tbody');
        return chart.draw = function(graphData) {
          var $li, $liEnter;

          $li = $table.selectAll('tr').data(_.sortBy(graphData, function(a) {
            return -a.sumVisits;
          }));
          $liEnter = $li.enter().append('tr').style('color', function(d) {
            return d.color;
          }).on('mouseover', function(g) {
            return highlightPage(g.key);
          }).on('mouseout', function(g) {
            return deHighlightPage(g.key);
          });
          $liEnter.append('td').attr('class', 'id');
          $liEnter.append('td').attr('class', 'input');
          $liEnter.select('td.input').append('input').attr('type', 'checkbox').on('change', function() {
            var selectedPages, selecteds;

            selecteds = [];
            d3.selectAll('#pages input:checked').each(function(d) {
              return selecteds.push(d.key);
            });
            selectedPages = selecteds;
            return reDraw(graphData);
          });
          $liEnter.select('td.input').append('label');
          ['td.visits', 'td.subs', 'td.conv'].forEach(function(t) {
            return $liEnter.append(t.split('.')[0]).attr('class', t.split('.')[1]);
          });
          $li.selectAll('td.id').text(function(d) {
            return d.key;
          });
          $li.selectAll('td.input input').attr('id', function(d) {
            return 'page-' + d.key;
          }).attr('name', function(d) {
            return d.key;
          }).attr('checked', function(d) {
            if (_(selectedPages).contains(d.key)) {
              return 'checked';
            } else {
              return null;
            }
          });
          $li.selectAll('td.input label').text(function(d) {
            return d.name;
          }).attr('for', function(d) {
            return 'page-' + d.key;
          });
          $li.selectAll('td.visits').text(function(d) {
            return d3.format(',')(d.sumVisits);
          });
          $li.selectAll('td.subs').text(function(d) {
            return d3.format(',')(d.sumSubs);
          });
          return $li.selectAll('td.conv').text(function(d) {
            return d3.format('.2%')(d.sumSubs / d.sumVisits);
          });
        };
      });
    };
    return chart;
  };

  chart = stackedAreaimeSeriesChart().key(function(g) {
    return g.key;
  }).values(function(g) {
    return g.values;
  }).x(function(d) {
    return d.day;
  }).y(function(d) {
    return d.visits;
  });

  d3.select('#chart').call(chart);

  convChart = multiLineTimeSeriesChart().key(function(g) {
    return g.key;
  }).values(function(g) {
    return g.values;
  }).x(function(d) {
    return d.day;
  }).y(function(d) {
    return d.conv;
  }).mouseover(function(key) {
    return highlightPage(key);
  }).mouseout(function(key) {
    return deHighlightPage(key);
  });

  d3.select('#convChart').call(convChart);

  table = chartTable();

  d3.select('#pages').call(table);

  selectedPages = [];

  reDraw = function(groupedData) {
    chart.addStack(groupedData);
    convChart.addStack(groupedData);
    return table.draw(groupedData);
  };

  highlightPage = function(key) {
    var $g, orig, _ref;

    $g = d3.selectAll('#chart [data-key="' + key + '"]');
    orig = d3.rgb((_ref = $g.attr('data-orig-color')) != null ? _ref : $g.style('fill'));
    $g.attr('data-orig-color', orig);
    $g.transition('fill').duration(200).style('fill', orig.darker(.7));
    $g.select('path').style('stroke', orig.brighter(.7)).style('stroke-width', 2);
    return d3.selectAll('#convChart [data-key="' + key + '"]').transition('stroke-width').style('stroke-width', 5);
  };

  deHighlightPage = function(key) {
    var $g, orig;

    $g = d3.select('[data-key="' + key + '"]');
    orig = $g.attr('data-orig-color');
    if (orig) {
      $g.transition('fill').duration(200).style('fill', orig);
    }
    $g.select('path').style('stroke', '');
    return d3.selectAll('#convChart [data-key="' + key + '"]').transition('stroke-width').style('stroke-width', 2);
  };

  d3.csv('charts/page-perf/data/sc50time.csv', function(data) {
    var parseDate;

    parseDate = d3.time.format("%m/%d/%Y").parse;
    data = data.map(function(d) {
      d.day = parseDate(d.day);
      d.visits = +d.visits;
      d.subs = +d.subs;
      d.conv = d.visits > 0 ? d.subs / d.visits : 0;
      return d;
    });
    return d3.csv('charts/page-perf/data/pages.csv', function(pages) {
      var $offsets, $smoothers, averageVisitsPerPage, colors, dateRange, draw, filterByTime, graphData, groups, msInaDay, stdVisitsPerPage;

      groups = _(data).chain().filter(function(d) {
        return !!d.page && 'NULL' !== d.page;
      }).groupBy(function(d) {
        return d.page;
      }).value();
      dateRange = d3.extent(data.map(function(d) {
        return d.day;
      }));
      msInaDay = 24 * 60 * 60 * 1000;
      _.keys(groups).forEach(function(key) {
        var d, day, group, howMany, i, index, _i, _j, _k, _ref, _ref1, _ref2, _results, _results1, _results2;

        group = groups[key];
        index = -1;
        _results = [];
        for (i = _i = _ref = +dateRange[0], _ref1 = +dateRange[1]; msInaDay > 0 ? _i <= _ref1 : _i >= _ref1; i = _i += msInaDay) {
          ++index;
          day = new Date(i);
          d = _(group).filter(function(d) {
            return Math.abs(+d.day - +day) < 1000;
          })[0];
          if (!d) {
            d = {
              page: key,
              day: day,
              visits: 0,
              subs: 0,
              conv: 0
            };
            group.splice(index, 0, d);
          }
          howMany = 6;
          d.conv_cma = (function() {
            _results1 = [];
            for (var _j = -howMany; -howMany <= index ? _j <= index : _j >= index; -howMany <= index ? _j++ : _j--){ _results1.push(_j); }
            return _results1;
          }).apply(this).map(function(j) {
            return group[j > -1 ? j : 0].conv;
          }).reduce(function(a, b) {
            return a + b;
          }) / (index + howMany + 1);
          d.conv_ma = (function() {
            _results2 = [];
            for (var _k = _ref2 = index - howMany; _ref2 <= index ? _k <= index : _k >= index; _ref2 <= index ? _k++ : _k--){ _results2.push(_k); }
            return _results2;
          }).apply(this).map(function(j) {
            return group[j > -1 ? j : 0].conv;
          }).reduce(function(a, b) {
            return a + b;
          }) / (howMany + 1);
          _results.push(groups[key] = group);
        }
        return _results;
      });
      colors = d3.scale.category20();
      graphData = _.keys(groups).map(function(page, i) {
        return {
          key: page,
          name: (pages.filter(function(p) {
            return p.page === page;
          }))[0].name,
          values: groups[page],
          sumVisits: groups[page].map(function(d) {
            return d.visits;
          }).reduce(function(a, b) {
            return a + b;
          }),
          sumSubs: groups[page].map(function(d) {
            return d.subs;
          }).reduce(function(a, b) {
            return a + b;
          })
        };
      });
      graphData = _(graphData).sortBy(function(a) {
        return -a.visits;
      }).map(function(g, i) {
        g.color = colors(i);
        return g;
      });
      draw = function() {
        return reDraw(graphData);
      };
      filterByTime = function() {
        chart.values(function(g) {
          return g.values.filter(function(d) {
            return d.day >= new Date(2013, 6, 15) && d.day <= new Date(2013, 7, 15);
          });
        });
        convChart.values(function(g) {
          return g.values.filter(function(d) {
            return d.day >= new Date(2013, 6, 15) && d.day <= new Date(2013, 7, 15);
          });
        });
        return draw();
      };
      setTimeout(filterByTime, 2000);
      averageVisitsPerPage = _.chain(graphData).map(function(g) {
        return g.sumVisits;
      }).reduce(function(a, b) {
        return a + b;
      }).value() / (graphData.length + 1);
      stdVisitsPerPage = graphData.map(function(g) {
        return g.sumVisits;
      }).map(function(v) {
        return Math.sqrt(Math.pow(v - averageVisitsPerPage, 2));
      }).reduce(function(a, b) {
        return a + b;
      }) / (graphData.length + 1 + 1);
      selectedPages = graphData.filter(function(group) {
        return group.sumVisits > averageVisitsPerPage - stdVisitsPerPage;
      }).map(function(g) {
        return g.key;
      });
      chart.keyFilter(function(g) {
        return selectedPages.indexOf(g) > -1;
      });
      convChart.keyFilter(function(g) {
        return selectedPages.indexOf(g) > -1;
      });
      $offsets = d3.select("#chart-controls").selectAll('span.offset').data([
        {
          n: 'Comulative',
          v: 'zero'
        }, {
          n: 'Normalized',
          v: 'expand'
        }
      ]).enter().append('span').attr('class', 'offset');
      $offsets.append('input').attr('type', 'radio').attr('name', 'offset').attr('id', function(d) {
        return 'offset-' + d.v;
      }).attr('checked', function(d) {
        if ('zero' === d.v) {
          return 'checked';
        } else {
          return null;
        }
      }).on('change', function(val) {
        chart.stackOffset(val.v);
        return draw();
      });
      $offsets.append('label').attr('for', function(d) {
        return 'offset-' + d.v;
      }).text(function(d) {
        return d.n;
      });
      $smoothers = d3.select("#convChart-controls").selectAll('span.smoother').data([
        {
          n: 'Actual',
          v: 'conv'
        }, {
          n: 'Moving Average',
          v: 'conv_ma'
        }, {
          n: 'Comulative MA',
          v: 'conv_cma'
        }
      ]).enter().append('span').attr('class', 'smoother');
      $smoothers.append('input').attr('type', 'radio').attr('name', 'smoother').attr('id', function(d) {
        return 'smoother-' + d.v;
      }).attr('checked', function(d) {
        if ('conv' === d.v) {
          return 'checked';
        } else {
          return null;
        }
      }).on('change', function(val) {
        convChart.y(function(d) {
          return d[val.v];
        });
        return draw();
      });
      $smoothers.append('label').attr('for', function(d) {
        return 'smoother-' + d.v;
      }).text(function(d) {
        return d.n;
      });
      return draw();
    });
  });

}).call(this);
