// Generated by CoffeeScript 1.6.2
(function() {
  d3.csv('charts/page-perf/data/sc50time.csv', function(data) {
    var parseDate;

    parseDate = d3.time.format("%m/%d/%Y").parse;
    data = data.map(function(d) {
      d.day = parseDate(d.day);
      d.visits = +d.visits;
      d.subs = +d.subs;
      d.conv = d.subs > 0 ? d.visits / d.subs : 0;
      return d;
    });
    return d3.csv('charts/page-perf/data/pages.csv', function(pages) {
      var $li, $offsets, $td, chart, colors, convChart, dateRange, draw, graphData, groups, msInaDay;

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
        var day, group, i, index, _i, _ref, _ref1, _results;

        group = groups[key];
        index = -1;
        _results = [];
        for (i = _i = _ref = +dateRange[0], _ref1 = +dateRange[1]; msInaDay > 0 ? _i <= _ref1 : _i >= _ref1; i = _i += msInaDay) {
          ++index;
          day = new Date(i);
          if (!_(group).some(function(d) {
            return Math.abs(+d.day - +day) < 1000;
          })) {
            group.splice(index, 0, {
              page: key,
              day: day,
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
      colors = d3.scale.category20();
      graphData = _.keys(groups).map(function(page, i) {
        return {
          key: page,
          name: (pages.filter(function(p) {
            return p.page === page;
          }))[0].name,
          valuess: groups[page],
          sumVisits: groups[page].map(function(d) {
            return d.visits;
          }).reduce(function(a, b) {
            return a + b;
          }),
          sumSubs: groups[page].map(function(d) {
            return d.subs;
          }).reduce(function(a, b) {
            return a + b;
          }),
          color: colors(i)
        };
      });
      window.graphData = _.sortBy(graphData, function(a) {
        return -a.sumVisits;
      });
      chart = stackedAreaimeSeriesChart().key(function(g) {
        return g.key;
      }).values(function(g) {
        return g.valuess;
      }).x(function(d) {
        return d.day;
      }).y(function(d) {
        return d.visits;
      });
      d3.select('#chart').call(chart);
      convChart = multiLineTimeSeriesChart().key(function(g) {
        return g.key;
      }).values(function(g) {
        return g.valuess;
      }).x(function(d) {
        return d.day;
      }).y(function(d) {
        return d.visits;
      });
      d3.select('#convChart').call(convChart);
      draw = function() {
        chart.addStack(graphData);
        return convChart.addStack(graphData);
      };
      $li = d3.select('#pages tbody').selectAll('tr').data(graphData);
      $li.enter().append('tr').style('color', function(d) {
        return d.color;
      }).on('mouseover', function(g) {
        var $g, brighter, orig, _ref;

        $g = d3.select('[data-key="' + g.key + '"]');
        orig = d3.rgb((_ref = $g.attr('data-orig-color')) != null ? _ref : $g.style('fill'));
        $g.attr('data-orig-color', orig);
        brighter = orig.brighter(.8);
        $g.transition('fill').duration(200).style('fill', brighter);
        return $g.select('path').style('stroke', orig.darker(.7).toString()).style('stroke-width', 2);
      }).on('mouseout', function(g) {
        var $g, orig;

        $g = d3.select('[data-key="' + g.key + '"]');
        orig = $g.attr('data-orig-color');
        if (orig) {
          $g.transition('fill').duration(200).style('fill', orig);
        }
        return $g.select('path').style('stroke', '');
      });
      $td = $li.append("td");
      $td.append('input').attr('type', 'checkbox').attr('id', function(d) {
        return 'page-' + d.key;
      }).attr('name', function(d) {
        return d.key;
      }).on('change', function() {
        var selecteds;

        selecteds = [];
        d3.selectAll('#pages input:checked').each(function(d) {
          return selecteds.push(d.key);
        });
        chart.keyFilter(function(g) {
          return selecteds.indexOf(g) > -1;
        });
        return draw();
      });
      $td.append('label').attr('for', function(d) {
        return 'page-' + d.key;
      }).text(function(d) {
        return d.name;
      });
      $li.append('td').text(function(d) {
        return d3.format(',')(d.sumVisits);
      });
      $li.append('td').text(function(d) {
        return d3.format(',')(d.sumSubs);
      });
      $li.append('td').text(function(d) {
        return d3.format('%')(d.sumSubs / d.sumVisits);
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
      }).on('change', function(val) {
        chart.stackOffset(val.v);
        return draw();
      });
      $offsets.append('label').attr('for', function(d) {
        return 'offset-' + d.v;
      }).text(function(d) {
        return d.n;
      });
      return draw();
    });
  });

}).call(this);