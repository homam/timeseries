exports = exports ? this

exports.lineBarTimeSeriesChart = () ->
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
  yBMap = (d) -> d[1]

  xScale = d3.time.scale()
  yScale = d3.scale.linear()

  yBScale = d3.scale.linear()
  xBScale = d3.scale.ordinal()


  X = (d) -> xScale xMap d
  Y = (d) -> yScale yMap d

  Yb = (d) -> yBScale yBMap d


  line = d3.svg.line().interpolate('basis').x(X).y(Y)


  chart = (selection) ->
    selection.each (raw) ->

      xScale.range([0,width - margin.left - margin.right])
      yScale.range([height - margin.top - margin.bottom, 0])

      xBScale.rangeRoundBands([0,width-margin.left-margin.right],.2)
      yBScale.range([height - margin.top - margin.bottom, 0])

      xAxis = d3.svg.axis().scale(xScale).orient('bottom')
      yAxis = d3.svg.axis().scale(yScale).orient('left')
      yBAxis = d3.svg.axis().scale(yBScale).orient('right')


      $svg = d3.select(this).append('svg')
      .attr('width', width).attr('height', height)
      .append('g').attr('transform', "translate(" + margin.left + "," + margin.top + ")")


      # horizontal axis
      $svg.append('g').attr('class', 'x axis')
      $svg.select('.x.axis').attr('transform', 'translate(0, ' + (height - margin.top - margin.bottom) + ')').call(xAxis)

      # line axis
      $svg.append('g').attr('class', 'y axis line')
      $svg.select('.y.axis.line').call(yAxis)
      .append('text').attr('transform', 'translate(20,0) rotate(90)')
      .attr('y', 6).attr('dy', '.71em').style('text-anchor', 'start')
      .text('Y')

      # bar axis
      $svg.append('g').attr('class', 'y axis bar').attr('transform', 'translate(' + (width-margin.right-margin.left) + ',0)').attr('opacity', 0)
      $svg.select('.y.axis.bar').call(yBAxis)
      .append('text').attr('transform', 'translate(0,0) rotate(90)')
      .attr('y', 6).attr('dy', '.71em').style('text-anchor', 'start')
      .text('Y')

      #$svg.selectAll('path.line').data([data]).enter().append('path').attr('d', line).attr('class', 'line')

      # chart api
      chart.xScale = (extent) ->
        xScale.domain extent, xMap
        $svg.select('.x.axis').transition().duration(1500).ease("sin-in-out").call(xAxis)

      chart.yScale = (extent, label) ->
        yScale.domain extent, yMap
        $svg.select('.y.axis.line').transition().duration(1500).ease("sin-in-out").call(yAxis)
        $svg.select('.y.axis.line > text').text(label ? '')

      chart.yBScale = (extent, label) ->
        yBScale.domain extent, yBMap
        $svg.select('.y.axis.bar').transition().duration(1500).ease('sin-in-out').attr('opacity', 1).call(yBAxis)
        $svg.select('.y.axis.bar > text').text(label ? '')

      chart.addLine = (newData) ->
        $svg.selectAll('path.line').data([newData]).enter().append('path').attr('class', 'line')
        $svg.selectAll('path.line').transition().duration(1500).ease("sin-in-out").attr('d', line)

      chart.addBar = (newData) ->
        xBScale.domain newData.map (d) -> xMap(d)

        $svg.selectAll('rect.bar').data(newData).enter().append('rect').attr('class', 'bar')
        $svg.selectAll('rect.bar')
        .attr('width', xBScale.rangeBand())
        .transition().duration(1500).ease("sin-in-out")
        .attr('x', X)
        .attr('y', Yb)
        .attr('height', (d) -> height - margin.top - margin.bottom - Yb(d))







  chart.x = (map) -> xMap = map ? xMap; return chart
  chart.y = (map) -> yMap = map ? yMap; return chart;
  chart.yB = (map) -> yBMap = map ? yBMap; return chart;

  chart.height = (val) -> height = val ? height; return chart;

  return chart