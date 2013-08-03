exports = exports ? this


exports.barChart = () ->
  # configs
  margin =
    top: 20
    right: 0
    bottom: 20
    left: 70
  width = 720 - margin.left-margin.right
  height = 300 - margin.top-margin.bottom


  x0 = d3.scale.ordinal().rangeRoundBands([0,width], .1)
  y = d3.scale.linear().range([height,0])

  xAxis = d3.svg.axis().scale(x0).orient('bottom')

  yAxis = d3.svg.axis().scale(y).orient('left').tickFormat(d3.format(','))
  .tickSize(-width,0,0)


  nameMap = (d) ->d.name
  valueMap  = (d) ->d.value
  devMap = (d) ->d.stdev

  chart = (selection) ->
    selection.each () ->

      $svg = d3.select(this).append('svg')
      .attr('width', width+margin.left+margin.right).attr('height', height+margin.top+margin.bottom)
      .append('g')
      .attr('transform', "translate(" + margin.left + "," + margin.top + ")")

      $xAxis = $svg.append('g').attr('class', 'x axis')
      .attr("transform", "translate(0," + (height)+ ")")

      $yAxis = $svg.append('g').attr('class', 'y axis')

      chart.draw = (data) ->

        keys = _.flatten data.map nameMap


        x0.domain(keys)
        y.domain([0, d3.max data.map valueMap ])


        $main = $svg.selectAll('.main').data(data)
        $main.enter().append('g').attr('class','main').append('rect').attr('class', 'conv')
        $main.transition().duration(200)

        $rect = $main.select('rect.conv')
        $rect.transition().duration(200).attr('width', x0.rangeBand())
        .attr('x', (d) -> x0(nameMap(d)))
        .attr('y', (d) -> y(valueMap(d)))
        .attr('height', (d)-> height-y(valueMap(d)))
        .style('fill', (d,i)-> '#ff7f0e')

        $main.exit().select('rect').attr('y', 0).attr('height', 0)


        # start standard deviation lines

#        $devG = $main.selectAll('g.dev').data(mainValueMap)
#        $devG.enter().append('g').attr('class', 'dev')
#        $devG.transition().duration(200)
#        .attr('transform', (d) -> 'translate(0,'+(-height+y(mainValueMap(d))-(-height+y(subValueDevMap(d)))/2)+')')
#
#        $devUpperLine = $devG.selectAll('line.dev.up').data((d) -> [d])
#        $devUpperLine.enter().append('line').attr('class', 'dev up')
#        $devUpperLine.transition().duration(200)
#        .attr('x1', _.compose(x1, subNameMap)).attr('x2', (d) -> _.compose(x1, subNameMap)(d)+x1.rangeBand())
#        .attr('y1', _.compose y, subValueDevMap).attr('y2', _.compose y, subValueDevMap)
#
#        $devLowerLine = $devG.selectAll('line.dev.low').data((d) -> [d])
#        $devLowerLine.enter().append('line').attr('class', 'dev low')
#        $devLowerLine.transition().duration(200)
#        .attr('x1', _.compose(x1, subNameMap)).attr('x2', (d) -> _.compose(x1, subNameMap)(d)+x1.rangeBand())
#        .attr('y1', (d) -> y(0)).attr('y2', (d) -> y(0))
#
#        $devrect = $devG.selectAll('rect.dev').data((d) -> [d])
#        $devrect.enter().append('rect').attr('class', 'dev')
#        $devrect.transition().duration(200).attr('width', x1.rangeBand()*.25)
#        .attr('x', (d) -> x1(subNameMap(d))+x1.rangeBand()*.375)
#        .attr('y', _.compose y, subValueDevMap)
#        .attr('height', (d)-> height- (_.compose y, subValueDevMap)(d))
#
#        $devG.exit().select('rect').attr('height', 0).attr('y', () ->0).attr('width', 0)
#        $devG.exit().selectAll('line').attr('y1', 0).attr('y2', 0)

        # end standard deviation lines



        $xAxis.transition().duration(200).call(xAxis)
        $yAxis.transition().duration(200).call(yAxis)



      null








  chart.height = (val) -> height = val ? height; return chart;

  return chart