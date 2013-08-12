// Generated by CoffeeScript 1.6.2
(function() {
  var exports;

  exports = exports != null ? exports : this;

  exports.treeMapZoomableChart = function() {
    var aheight, awidth, chart, color, findParentWithProp, formatConv, formatNumber, height, margin, mouseEvents, rectHeight, rectWidth, width, x, y;

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
    width = screen.availWidth;
    height = d3.min([screen.availHeight - 200, screen.availHeight * .7]);
    awidth = width - margin.left - margin.right;
    aheight = height - margin.top - margin.bottom;
    formatConv = d3.format('.2%');
    formatNumber = d3.format(',');
    x = d3.scale.linear().range([0, awidth]);
    y = d3.scale.linear().range([0, aheight]);
    color = d3.scale.quantile().range(['#ffe866', '#fefd69', '#eafd6d', '#d5fc70', '#c2fa74', '#b1f977', '#a0f87a', '#91f77e', '#83f681', '#84f592', '#87f4a4', '#8af2b5', '#8df1c4', '#90f0d3', '#93efe0', '#96eeec', '#99e3ed', '#9cd7eb', '#9fccea', '#a2c3e9']);
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
    mouseEvents = d3.dispatch('zoomed');
    chart = function(selection) {
      return selection.each(function() {
        var $svg, currentNode, zoom;

        $svg = d3.select(this).append('svg').attr('class', 'chart').attr("width", width).attr("height", height).append("g").attr('transform', 'translate(' + margin.top + ',' + margin.left + ')');
        currentNode = null;
        zoom = function(r, single) {
          var kx, ky, t;

          if (single == null) {
            single = false;
          }
          mouseEvents.zoomed(r);
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
          t = $svg.selectAll('.node.visible').transition().duration(1500).attr('transform', function(d) {
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

          color.domain([0, root.averageConversion + 2 * root.stdevConversion]);
          treemap = d3.layout.treemap().size([width - margin.left - margin.right, height - margin.left - margin.right]).round(false).padding(1).sticky(false).value(function(d) {
            return d.visits;
          });
          nodes = treemap.nodes(root).filter(function(d) {
            return d.children.length === 0;
          });
          currentNode = root;
          $node = $svg.selectAll('.node').data(nodes);
          $enterNode = $node.enter().append('g').attr('class', 'node visible');
          $node.on('click', function(d) {
            var alt;

            alt = d3.event.altKey;
            if (alt) {
              return zoom(d, true);
            } else {
              if (!d.parent || currentNode.wurfl_device_id === d.parent.wurfl_device_id) {
                return zoom(root);
              } else {
                return zoom(d.parent);
              }
            }
          });
          $node.attr('class', 'node visible').attr('transform', function(d) {
            return "translate(" + d.x + "," + d.y + ")";
          }).call(d3.helper.tooltip().text(function(d) {
            var avgConv, html, stdevConv;

            avgConv = findParentWithProp(d, 'averageConversion');
            stdevConv = findParentWithProp(d, 'stdevConversion');
            d._badConverting = d.conv === 0 || d.conv < avgConv - stdevConv;
            html = d.brand_name + ' ' + d.model_name;
            html += '<br/>' + d.wurfl_device_id;
            html += '<br/>' + d.wurfl_fall_back;
            html += '<br/>' + d.device_os;
            html += '<br/><br/>Visits: ' + formatNumber(d.visits);
            html += '<br/>Subs: ' + formatNumber(d.subscribers);
            if (d._badConverting) {
              html += '<br/><span style="color:red">Conv: ' + (formatConv(d.conv)) + '</span>';
            } else {
              html += '<br/>Conv: ' + formatConv(d.conv);
            }
            html += '<br/><br/>Avg: ' + formatConv(avgConv);
            html += '<br/>SigmaAvg: ' + formatConv(stdevConv);
            return html;
          })).classed('bad', function(d) {
            var avgConv, stdevConv;

            avgConv = findParentWithProp(d, 'averageConversion');
            stdevConv = findParentWithProp(d, 'stdevConversion');
            d._badConverting = d.conv === 0 || d.conv < avgConv - stdevConv;
            return false && d._badConverting;
          });
          $enterNode.append('rect');
          $node.select('rect').style('fill', function(d) {
            return color(d.conv);
          }).attr('data-wid', function(d) {
            return d.wurfl_device_id;
          }).transition().duration(200).attr('width', rectWidth).attr('height', rectHeight);
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
          $node.exit().attr('class', 'node').select('rect').transition().duration(200).attr('width', 0).attr('height', 0);
          return $node.exit().selectAll('text').text(null);
        };
      });
    };
    chart.zoomed = function(delegate) {
      mouseEvents.on('zoomed', delegate);
      return chart;
    };
    return chart;
  };

}).call(this);