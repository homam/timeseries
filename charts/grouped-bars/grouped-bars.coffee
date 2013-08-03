exports = exports ? this


exports.groupedBarsChart = () ->
  # configs
  margin =
    top: 50
    right: 0
    bottom: 20
    left: 70
  width = 720 - margin.left-margin.right
  height = 300 - margin.top-margin.bottom

  x0 = d3.scale.ordinal().rangeRoundBands([0,width], .1)
  x1 = d3.scale.ordinal()

  y = d3.scale.linear().range([height,0])

  color = d3.scale.category10()

  xAxis = d3.svg.axis().scale(x0).orient('bottom')

  yAxis = d3.svg.axis().scale(y).orient('left').tickFormat(d3.format('.2%'))
  .tickSize(-width,0,0)


  mainNameMap = (d) ->d.name
  subNameMap = (d) ->d.name
  mainValueMap  = (d) ->d.value
  subValueMap = (d)->d.value

  chart = (selection) ->
    selection.each () ->

      $svg = d3.select(this).append('svg')
      .attr('width', width+margin.left+margin.right).attr('height', height+margin.top+margin.bottom)
      .append('g')
      .attr('transform', "translate(" + margin.left + "," + margin.top + ")")

      $xAxis = $svg.append('g').attr('class', 'x axis')
      .attr("transform", "translate(0," + (height)+ ")")

      $yAxis = $svg.append('g').attr('class', 'y axis')


      #hierarchy = [{name, value:[{name, value: #}]}]

      chart.draw = (hierarchy) ->

        allSubKeys = _.uniq _.flatten hierarchy.map((d) -> mainValueMap(d).map subNameMap)
        allMainKeys = _.flatten hierarchy.map mainNameMap


        x0.domain(allMainKeys)
        x1.domain(allSubKeys).rangeRoundBands([0, x0.rangeBand()])
        y.domain([0, d3.max _.flatten hierarchy.map (h) -> mainValueMap(h).map subValueMap])


        $main = $svg.selectAll('.main').data(hierarchy)
        $main.enter().append('g').attr('class','main')
        $main.attr('transform', (d) -> "translate(" + x0(mainNameMap(d)) + ",0)")

        $rect = $main.selectAll('rect').data(mainValueMap)
        $rect.enter().append('rect')
        $rect.transition().duration(200).attr('width', x1.rangeBand())
        .attr('x', (d) -> x1(subNameMap(d)))
        .attr('y', (d) -> y(subValueMap(d)))
        .attr('height', (d)-> height-y(subValueMap(d)))
        .style('fill', (d)-> color allSubKeys.indexOf(mainNameMap(d)))

        $rect.exit().transition().duration(200)
        .attr('y', height)
        .attr('height', 0)



        $xAxis.transition().duration(200).call(xAxis)
        $yAxis.transition().duration(200).call(yAxis)

        $legend = $svg.selectAll('.legend').data(allSubKeys)
        $legendEnter = $legend.enter().append('g').attr('class', 'legend')
        $legend.attr('transform', (d,i) -> "translate(0," + (i*20-margin.top) + ")")



        $legendEnter.append('rect')
        $legend.select('rect')
        .attr('x', width-18).attr('width', 18).attr('height', 18)
        .style('fill', (d) -> color allSubKeys.indexOf(d))
        $legendEnter.append('text')
        $legend.select('text')
        .attr('x', width-24).attr('y', 9).attr('dy', '.35em').style('text-anchor', 'end')
        .text((d) -> d)




      null






  chart.x = (map) -> xMap = map ? xMap; return chart
  chart.y = (map) -> yMap = map ? yMap; return chart;
  chart.yB = (map) -> yBMap = map ? yBMap; return chart;

  chart.height = (val) -> height = val ? height; return chart;

  return chart