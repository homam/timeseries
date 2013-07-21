exports = exports ? this

exports.simpleUpdatableTimeSeriesChart = () ->
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

  X = (d) -> xScale xMap d
  Y = (d) -> yScale yMap d


  xScale = d3.time.scale().range([0,width - margin.left - margin.right])
  yScale = d3.scale.linear().range([height - margin.top - margin.bottom, 0])

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


      data = raw #todo clone to data

      xScale.domain d3.extent data, xMap
      yScale.domain d3.extent data, yMap



      $svg.select('.x.axis').attr('transform', 'translate(0, ' + (height - margin.top - margin.bottom) + ')').call(xAxis)
      $svg.select('.y.axis').call(yAxis)
      .append('text').attr('transform', 'rotate(0)')
      .attr('y', 6).attr('dy', '.71em').style('text-anchor', 'end')
      .text('Y')

      $svg.selectAll('path.line').data([data]).enter().append('path').attr('d', line).attr('class', 'line')

      chart.addLine = (newData, id) ->

        #code for adding a line
        #$svg.selectAll('path.line.' + id).data([newData]).enter().append('path').attr('d', line).attr('class', 'line ' + id)

        #code for changing the line
        yScale.domain d3.extent newData, yMap
        $svg.selectAll('path.line').data([newData]).enter().append('path')
        $svg.selectAll('path.line').transition().duration(1500).ease("sin-in-out").attr('d', line).attr('class', 'line')
        $svg.select('.y.axis').transition().duration(1500).ease("sin-in-out").call(yAxis)






  chart.x = (map) -> xMap = map ? xMap; return chart
  chart.y = (map) -> yMap = map ? yMap; return chart;

  return chart