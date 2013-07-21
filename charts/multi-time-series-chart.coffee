exports = exports ? this

exports.multiTimeSeriesChart = () ->
  # configs
  margin =
    top: 20
    right: 20
    bottom: 20
    left: 50
  width = 720
  height = 300
  color = d3.scale.category10();

  groupBy = (d) -> d.ref

  xMap = (d) -> d[0]
  yMap = (d) -> d[1]

  X = (d) -> xScale xMap d
  Y = (d) -> yScale yMap d


  xScale = d3.time.scale().range([0,width - margin.left - margin.right])
  yScale = d3.scale.linear().range([height - margin.top - margin.bottom, 0])

  xAxis = d3.svg.axis().scale(xScale).orient('bottom')
  yAxis = d3.svg.axis().scale(yScale).orient('left')

  line = d3.svg.line().interpolate('basis').x(X).y(Y)

  $svg = d3.select('body').append('svg')
  .attr('width', width).attr('height', height)
  .append('g').attr('transform', "translate(" + margin.left + "," + margin.top + ")")

  $svg.append('g').attr('class', 'x axis')
  $svg.append('g').attr('class', 'y axis')


  chart = (selection) ->
    selection.each (raw) ->
      data = raw #todo clone to data

      xScale.domain d3.extent data, xMap
      yScale.domain d3.extent data, yMap

      groups = _.groupBy(data, groupBy)
      keys = d3.keys groups
      color.domain(keys)



      $svg.select('.x.axis').attr('transform', 'translate(0, ' + (height - margin.top - margin.bottom) + ')').call(xAxis)
      $svg.select('.y.axis').call(yAxis)
        .append('text').attr('transform', 'rotate(0)')
        .attr('y', 6).attr('dy', '.71em').style('text-anchor', 'end')
        .text('Y')

      $line = $svg.selectAll('.group').data(keys).enter().append('g').attr('class', 'group')
      $line.append('path').attr('class', 'line')
        .attr('d', (d) ->line groups[d])
        .style('stroke', (d) -> color(d))
        .on('mousedown', (d) -> console.log 'mdown ' + d)
      $line.append('text')
      .data(keys.map (d) ->
          name: d
          pos:
            x: X _.last groups[d]
            y: Y _.last groups[d]
      )
      .attr('x', (d) -> d.pos.x - 40)
      .attr('y', (d) -> d.pos.y).attr('dy', '.05em')
      .style('fill', (d) -> color(d.name))
      .text((d) -> d.name)





  chart.x = (map) -> xMap = map ? xMap; return chart
  chart.y = (map) -> yMap = map ? yMap; return chart;

  return chart