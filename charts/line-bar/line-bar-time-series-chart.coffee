exports = exports ? this

exports.lineBarTimeSeriesChart = () ->
  # configs
  margin =
    top: 20
    right: 20
    bottom: 20
    left: 50
  width = 720
  height = 300

  xMap = (d) -> d[0]
  yMap = (d) -> d[1]
  yBMap = (d) -> d[1]

  X = (d) -> xScale xMap d
  Y = (d) -> yScale yMap d

  Xb = (d) -> xBScale xMap d # note we're using xMap not xBMap
  Yb = (d) -> yBScale yBMap d


  xScale = d3.time.scale().range([0,width - margin.left - margin.right])
  yScale = d3.scale.linear().range([height - margin.top - margin.bottom, 0])

  xBScale = d3.scale.ordinal().rangeRoundBands([0,width-margin.left-margin.right],.2)
  yBScale = d3.scale.linear().range([height - margin.top - margin.bottom, 0])

  xAxis = d3.svg.axis().scale(xScale).orient('bottom')
  yAxis = d3.svg.axis().scale(yScale).orient('left')

  line = d3.svg.line().interpolate('basis').x(X).y(Y)




  chart = (selection) ->
    selection.each (raw) ->
      $svg = d3.select(this).append('svg')
      .attr('width', width).attr('height', height)
      .append('g').attr('transform', "translate(" + margin.left + "," + margin.top + ")")

      $svg.append('g').attr('class', 'x axis')
      $svg.append('g').attr('class', 'y axis')


      #data = raw #todo clone to data


      $svg.select('.x.axis').attr('transform', 'translate(0, ' + (height - margin.top - margin.bottom) + ')').call(xAxis)
      $svg.select('.y.axis').call(yAxis)
      .append('text').attr('transform', 'rotate(0)')
      .attr('y', 6).attr('dy', '.71em').style('text-anchor', 'end')
      .text('Y')

      #$svg.selectAll('path.line').data([data]).enter().append('path').attr('d', line).attr('class', 'line')

      chart.xScale = (extent) ->
        xScale.domain extent, xMap
        $svg.select('.x.axis').transition().duration(1500).ease("sin-in-out").call(xAxis)

      chart.yScale = (extent) ->
        yScale.domain extent, yMap
        $svg.select('.y.axis').transition().duration(1500).ease("sin-in-out").call(yAxis)

      chart.yBScale = (extent) ->
        yBScale.domain extent, yBMap

      chart.addLine = (newData) ->

        #code for changing the line

        $svg.selectAll('path.line').data([newData]).enter().append('path').attr('class', 'line')
        $svg.selectAll('path.line').transition().duration(1500).ease("sin-in-out").attr('d', line)

      chart.addBar = (newData) ->
        xBScale.domain newData.map (d) -> xMap(d)

        console.log Xb(new Date(2013,3,1))

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

  return chart