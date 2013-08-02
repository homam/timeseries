// Generated by CoffeeScript 1.6.2
(function() {
  var exports;

  exports = exports != null ? exports : this;

  exports.treeMapZoomableChart = function() {
    var aheight, awidth, chart, color, findParentWithProp, formatConv, formatNumber, height, margin, rectHeight, rectWidth, width, x, y;

    findParentWithProp = function(d, prop) {
      if (!d) {
        return null;
      }
      if (d.hasOwnProperty(prop)) {
        return d[prop];
      }
      return findParentWithProp(d.parent, prop);
    };
    margin = {
      top: 0,
      right: 0,
      bottom: 0,
      left: 0
    };
    width = 1200;
    height = 900;
    awidth = width - margin.left - margin.right;
    aheight = height - margin.top - margin.bottom;
    formatConv = d3.format('.2%');
    formatNumber = d3.format(',');
    x = d3.scale.linear().range([0, awidth]);
    y = d3.scale.linear().range([0, aheight]);
    color = d3.scale.category20();
    rectWidth = function(d) {
      if (d.dx > 2) {
        return d.dx - 2;
      } else {
        return 0;
      }
    };
    rectHeight = function(d) {
      if (d.dy > 2) {
        return d.dy - 2;
      } else {
        return 0;
      }
    };
    chart = function(selection) {
      return selection.each(function() {
        var $svg, TopLeft, currentNode, topLeft, zoom;

        $svg = d3.select(this).append('svg').attr('class', 'chart').attr("width", width).attr("height", height).append("g").attr('transform', 'translate(' + margin.top + ',' + margin.left + ')');
        currentNode = null;
        TopLeft = function() {
          var _kx, _ky, _px, _py;

          _px = 0;
          _py = 0;
          _kx = 1;
          _ky = 1;
          return function(px, py, kx, ky) {
            if (arguments.length > 0) {
              _px = px;
              _py = py;
              if (arguments.length > 1) {
                _kx = kx;
                _ky = ky;
              }
            }
            return {
              x: _px,
              y: _py,
              kx: _kx,
              ky: _ky,
              xdomain: x.domain(),
              ydomain: y.domain()
            };
          };
        };
        topLeft = TopLeft();
        window.move = function(px, py) {
          var kx, ky, tl;

          if (arguments.length === 0) {
            return topLeft();
          } else {
            tl = topLeft();
            kx = tl.kx;
            return ky = tl.ky;
          }
        };
        zoom = function(r, single) {
          var kx, ky, t;

          if (single == null) {
            single = false;
          }
          kx = awidth / r.dx;
          ky = aheight / r.dy;
          x.domain([r.x, r.dx + r.x]);
          y.domain([r.y, r.dy + r.y]);
          if (single) {
            kx *= .5;
            ky *= .5;
            x.domain([r.x - r.dx * .5, 1.5 * r.dx + r.x]);
            y.domain([r.y - r.dy * .5, 1.5 * r.dy + r.y]);
          }
          t = $svg.selectAll('.node').transition().duration(1500).attr('transform', function(d) {
            return "translate(" + x(d.x) + "," + y(d.y) + ")";
          });
          t.select('rect').attr('width', function(d) {
            return kx * d.dx;
          }).attr('height', function(d) {
            return ky * d.dy;
          });
          t.selectAll('text').attr('x', function(d) {
            return kx * d.dx / 2;
          });
          t.select('text.name').attr('y', function(d) {
            return ky * d.dy / 2;
          }).style('opacity', function(d) {
            if (kx * d.dx > d._tnamew) {
              return 1;
            } else {
              return 0;
            }
          });
          t.select('text.conv').attr('y', function(d) {
            return .7 * ky * d.dy;
          }).style('opacity', function(d) {
            if (kx * d.dx > d._tconvw) {
              return 1;
            } else {
              return 0;
            }
          });
          currentNode = r;
          return d3.event.stopPropagation();
        };
        window.zoom = zoom;
        return chart.draw = function(root) {
          var $enterNode, $node, nodes, treemap;

          treemap = d3.layout.treemap().size([width - margin.left - margin.right, height - margin.left - margin.right]).round(false).sticky(true).value(function(d) {
            return d.visits;
          });
          nodes = treemap.nodes(root).filter(function(d) {
            return d.children.length === 0;
          });
          currentNode = root;
          $node = $svg.selectAll('.node').data(nodes);
          $enterNode = $node.enter().append('g').attr('class', 'node').on('click', function(d) {
            if (!d.parent || currentNode.wurfl_device_id === d.parent.wurfl_device_id) {
              return zoom(root);
            } else {
              return zoom(d.parent);
            }
          }).on('dblclick', function(d) {
            if (!d.parent || currentNode.wurfl_device_id === d.parent.wurfl_device_id) {
              return zoom(d, true);
            } else {
              return zoom(d, true);
            }
          });
          $node.attr('transform', function(d) {
            return "translate(" + d.x + "," + d.y + ")";
          }).call(d3.helper.tooltip().attr('class', function(d, i) {
            return d.wurfl_device_id;
          }).style('color', 'blue').text(function(d) {
            var avgConv, html, stdevConv;

            avgConv = findParentWithProp(d, 'averageConversion');
            stdevConv = findParentWithProp(d, 'stdevConversion');
            d._badConverting = d.conv === 0 || d.conv < avgConv - stdevConv;
            html = d.brand_name + ' ' + d.model_name;
            html += '<br/>' + d.wurfl_device_id;
            html += '<br/>' + d.device_os;
            html += '<br/>Visits: ' + formatNumber(d.visits);
            if (d._badConverting) {
              html += '<br/><span style="color:red">Conv: ' + (formatConv(d.conv)) + '</span>';
            } else {
              html += '<br/>Conv: ' + formatConv(d.conv);
            }
            html += '<br/>Avg: ' + formatConv(avgConv);
            html += '<br/>SigmaAvg: ' + formatConv(stdevConv);
            return html;
          }));
          $enterNode.append('rect');
          $node.select('rect').style('fill', function(d) {
            return color(d.wurfl_device_id);
          }).attr('stroke', function(d) {
            var avgConv, stdevConv;

            avgConv = findParentWithProp(d, 'averageConversion');
            stdevConv = findParentWithProp(d, 'stdevConversion');
            d._badConverting = d.conv === 0 || d.conv < avgConv - stdevConv;
            if (d._badConverting) {
              return 'red';
            } else {
              return 'white';
            }
          }).transition().duration(500).attr('width', rectWidth).attr('height', rectHeight);
          $enterNode.append('text').attr('class', 'name');
          $node.select('text.name').attr('x', function(d) {
            return d.dx / 2;
          }).attr('y', function(d) {
            return d.dy / 2;
          }).attr('dy', '.35em').attr('text-anchor', 'middle').text(function(d) {
            if (d.children.length > 0) {
              return null;
            }
            return d.brand_name + ' ' + d.model_name;
          }).style('opacity', function(d) {
            d._tnamew = this.getComputedTextLength();
            if (d.dx > d._tnamew) {
              return 1;
            } else {
              return 0;
            }
          });
          $enterNode.append('text').attr('class', 'conv');
          $node.select('text.conv').attr('x', function(d) {
            return d.dx / 2;
          }).attr('y', function(d) {
            return d.dy * .7;
          }).attr('dy', '.35em').attr('text-anchor', 'middle').text(function(d) {
            if (d.children.length > 0) {
              return null;
            }
            return formatConv(d.conv);
          }).style('opacity', function(d) {
            d._tconvw = this.getComputedTextLength();
            if (d.dx > d._tconvw) {
              return 1;
            } else {
              return 0;
            }
          });
          $node.exit().select('rect').transition().duration(500).attr('width', 0).attr('height', 0);
          return $node.exit().selectAll('text').text(null);
        };
      });
    };
    return chart;
  };

}).call(this);