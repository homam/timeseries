d3.csv 'charts/page-perf/data/sc50time.csv', (data) ->
  # parse data
  parseDate = d3.time.format("%m/%d/%Y").parse;
  data = data.map (d) ->
    d.day = parseDate(d.day)
    d.visits = +d.visits
    d.subs = +d.subs
    d.conv = if d.subs > 0 then d.visits / d.subs else 0
    d

  d3.csv 'charts/page-perf/data/pages.csv', (pages) ->

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
      key: page,
      name: (pages.filter (p) -> p.page == page)[0].name
      valuess: groups[page]
      sum: groups[page].map((d) -> d.visits).reduce (a,b) -> a+b
      color: colors(i)
    )

    graphData =  _.sortBy graphData, (a) -> -a.sum



    chart = stackedAreaimeSeriesChart()
    .key((g) -> g.key)
    .values((g) -> g.valuess)
    .x((d) -> d.day)
    .y((d) -> d.visits)

    d3.select('#chart').call chart

    draw = () -> chart.addStack graphData

    $li = d3.select('#pages').selectAll('li').data(graphData)
    $li.enter().append('li').style('color', (d) -> d.color)
    .append('input').attr('type', 'checkbox').attr('id', (d) -> 'page-' + d.key).attr('name', (d) -> d.key)
    .on('change', () ->
      selecteds = [];
      d3.selectAll('#pages li input:checked').each((d) -> selecteds.push d.key)
      chart.keyFilter (g) -> selecteds.indexOf(g)>-1
      draw()
    )
    $li.append('label').attr('for', (d) -> 'page-' + d.key).text((d) -> d.name)


    $offsets = d3.select("#chart-controls").selectAll('span.offset')
    .data([{n: 'Comulative', v:'zero'},{n: 'Normalized', v:'expand'}]).enter().append('span').attr('class', 'offset')
    $offsets.append('input').attr('type','radio').attr('name', 'offset').attr('id', (d) -> 'offset-' + d.v)
    .on('change', (val) ->
        chart.stackOffset val.v
        draw()
    )
    $offsets.append('label').attr('for', (d) -> 'offset-' + d.v).text((d) -> d.n)


    draw()



