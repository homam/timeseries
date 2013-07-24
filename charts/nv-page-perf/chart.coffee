d3.csv 'charts/page-perf/data/sc50time.csv', (data) ->
  # parse data
  parseDate = d3.time.format("%m/%d/%Y").parse;
  data = data.map (d) ->
    d.day = parseDate(d.day)
    d.visits = +d.visits
    d.subs = +d.subs
    d.conv = if d.subs > 0 then d.visits / d.subs else 0
    d

  groups = _(data).chain().filter((d) -> !!d.page && 'NULL' != d.page).groupBy((d) -> d.page).value()

  # add missing data points
  dateRange = d3.extent data.map (d) ->d.day
  msInaDay = 24*60*60*1000
  _.keys(groups).forEach (key) ->
    group = groups[key]
    index = -1
    for i in [+dateRange[0]..+dateRange[1]] by msInaDay
      ++index
      day = new Date(i)
      if !_(group).some( (d) -> Math.abs(+d.day - +day) < 1000)
        group.splice index, 0, {page: key, day: day, visits: 0, subs: 0, conv: 0}
        groups[key] = group

  graphData = _.keys(groups).map((page) ->
    key: page
    values: groups[page]
    sum: groups[page].map((d) -> d.visits).reduce (a,b) -> a+b
  )
  graphData= graphData.filter (d) -> d.sum>14000

  console.log graphData

  nv.addGraph ()->
    chart = nv.models.stackedAreaChart()
    .x((d)-> d.day)
    .y((d)-> d.visits)
    .clipEdge(true)
    .tooltipContent((key, day, e, graph) ->
        key + "<br/>Visits=" + e + "<br/>Subs=" + graph.point.subs)

    chart.xAxis.tickFormat((d) -> d3.time.format('%x')(new Date(d)))
    chart.yAxis.tickFormat(d3.format('0,.2f'))

    $svg = d3.select('#chart').append('svg').attr('height', 400)
    $svg.datum(graphData)
    .transition().duration(1500).call chart
    nv.utils.windowResize(chart.update);




