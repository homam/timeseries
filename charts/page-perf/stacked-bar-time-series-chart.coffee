exports = exports ? this

exports.stackedBarTimeSeriesChart = () ->
  # configs
  margin =
    top: 20
    right: 40
    bottom: 20
    left: 50
  width = 720
  height = 300

  xMap = (d) -> d[0]
  yMap = (d) -> d[1]

  xScale = d3.scale.ordinal()
  yScale = d3.scale.linear()


  X = (d) -> xScale d
  Y = (d) -> yScale d


  line = d3.svg.line().interpolate('basis').x(X).y(Y)


  chart = (selection) ->
    selection.each (raw) ->

      xScale.rangeRoundBands([0,width - margin.left - margin.right], .02)
      yScale.range([height - margin.top - margin.bottom, 0])

      xAxis = d3.svg.axis().scale(xScale).orient('bottom')
      .tickSize(-height+margin.top+margin.bottom,0,0)
      .tickFormat((d) -> d.getDate() + '/' + d.getMonth())

      yAxis = d3.svg.axis().scale(yScale).orient('left')
      .tickSize(-width+margin.left+margin.right,0,0)


      $svg = d3.select(this).append('svg')
      .attr('width', width).attr('height', height)
      .append('g').attr('transform', "translate(" + margin.left + "," + margin.top + ")")


      # horizontal axis
      $svg.append('g').attr('class', 'x axis')
      $svg.select('.x.axis').attr('transform', 'translate(0, ' + (height - margin.top - margin.bottom) + ')')
      #.call(xAxis)

      # line axis
      $svg.append('g').attr('class', 'y axis line')
      $svg.select('.y.axis.line')
      .append('text').attr('transform', 'translate(20,0) rotate(90)')
      .attr('y', 6).attr('dy', '.71em').style('text-anchor', 'start')
      .text('Y')



      chart.addStack = (data, scaleData) ->

        stack = d3.layout.stack()
        .x((d) -> d.day)
        .y((d) -> d.visits)
        .values((d) -> d.values) #todo get values() map in addStack param

        layers = stack(data)

        xScale.domain layers[0].values.map (v,i) ->v.day
        $svg.select('.x.axis').transition().duration(1500).ease("sin-in-out").call(xAxis)

        yScale.domain [0, d3.max(stack(scaleData), (l) -> d3.max(l.values, (d) -> d.y0+d.y))]
        $svg.select('.y.axis.line').transition().duration(1500).ease("sin-in-out").call(yAxis)
        $svg.select('.y.axis.line > text').text(label ? '')

        #color = d3.scale.category20()

        $layer = $svg.selectAll('.layer').data(layers)
        $layer.enter().append('g').attr('class', 'layer')
        #todo hide the elements that are not included in scaleData
        #$layer.exit().transition().delay(1000).remove() # nothing exits
        #$layer.exit().selectAll('rect').transition().duration(1000).ease("sin-in-out").attr('y', height-margin.top-margin.bottom).attr('height', 0)
        $layer.style('fill', (d, i) ->d.color)
        .transition().duration(500).ease("sin-in-out")
        .style('opacity', (d) -> if !(scaleData.some((s) -> s.key == d.key)) then 0 else 1)
        $layer.selectAll('rect').transition().duration(500).ease("sin-in-out").attr('y', height-margin.top-margin.bottom).attr('height', 0)

        $rect = $layer.selectAll('rect').data((d) -> d.values)
        $rect.enter().append('rect').attr('y', height-margin.bottom-margin.top).attr('height',0)
        $rect.transition().duration(1000).ease("sin-in-out")
        .attr('x', (d,i) -> X(d.day))
        .attr('y', (d) -> Y(d.y0 + d.y))
        .attr('width', xScale.rangeBand())
        .attr('height', (d) -> Y(d.y0)-Y(d.y0+d.y))







  chart.x = (map) -> xMap = map ? xMap; return chart
  chart.y = (map) -> yMap = map ? yMap; return chart;

  chart.height = (val) -> height = val ? height; return chart;

  return chart