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

  colors = d3.scale.category20()
  graphData = _.keys(groups).map((page, i) ->
    key: page
    values: groups[page]
    sum: groups[page].map((d) -> d.visits).reduce (a,b) -> a+b
    color: colors(i)
  )



  chart = stackedBarTimeSeriesChart()
  .x((d) -> d.day)
  .y((d) -> d.visits)

  d3.select('#chart').call chart

  #chart.xScale d3.extent data.map (d) -> d.day
  #chart.yScale [0, (data.map((d) -> d.visits).reduce (a,b) -> a+b)], 'Y'

  chart.addStack graphData

  setTimeout ()->
    chart.addStack graphData.filter (d) -> d.sum>14000
  ,2000





