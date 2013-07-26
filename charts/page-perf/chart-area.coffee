d3.csv 'charts/page-perf/data/sc50time.csv', (data) ->
  # parse data
  parseDate = d3.time.format("%m/%d/%Y").parse;
  data = data.map (d) ->
    d.day = parseDate(d.day)
    d.visits = +d.visits
    d.subs = +d.subs
    d.conv = if d.visits > 0 then  d.subs/d.visits else 0
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
      sumVisits: groups[page].map((d) -> d.visits).reduce (a,b) -> a+b
      sumSubs: groups[page].map((d) -> d.subs).reduce (a,b) -> a+b
      #color: colors(i)
    )
    graphData = _(graphData).sortBy( (a) -> -a.visits).map((g,i) ->
      g.color = colors(i)
      g
    )



    chart = stackedAreaimeSeriesChart()
    .key((g) -> g.key)
    .values((g) -> g.valuess)
    .x((d) -> d.day)
    .y((d) -> d.visits)

    d3.select('#chart').call chart

    convChart = multiLineTimeSeriesChart()
    .key((g) -> g.key)
    .values((g) -> g.valuess)
    .x((d) -> d.day)
    .y((d) -> d.conv)

    d3.select('#convChart').call convChart

    draw = () ->
      chart.addStack graphData
      convChart.addStack graphData

    $li = d3.select('#pages tbody').selectAll('tr').data(_.sortBy graphData, (a) -> -a.sumVisits)
    $li.enter().append('tr').style('color', (d) -> d.color)
    .on('mouseover', (g) ->
        $g = d3.selectAll('#chart [data-key="' +g.key+ '"]')
        orig = d3.rgb $g.attr('data-orig-color') ?  $g.style('fill')
        $g.attr('data-orig-color', orig)
        $g.transition('fill').duration(200).style('fill', orig.darker(.7))
        $g.select('path').style('stroke', orig.brighter(.7)).style('stroke-width', 2)

        d3.selectAll('#convChart [data-key="' +g.key+ '"]')
        .transition('stroke-width').style('stroke-width', 5)
    )
    .on('mouseout', (g) ->
        $g = d3.select('[data-key="' +g.key+ '"]')
        orig = $g.attr('data-orig-color')
        if(orig)
          $g.transition('fill').duration(200).style('fill', orig)
        $g.select('path').style('stroke', '')

        d3.selectAll('#convChart [data-key="' +g.key+ '"]')
        .transition('stroke-width').style('stroke-width', 2)

    )
    $td = $li.append("td")
    $td.append('input').attr('type', 'checkbox').attr('id', (d) -> 'page-' + d.key).attr('name', (d) -> d.key)
    .on('change', () ->
      selecteds = [];
      d3.selectAll('#pages input:checked').each((d) -> selecteds.push d.key)
      chart.keyFilter (g) -> selecteds.indexOf(g)>-1
      convChart.keyFilter (g) -> selecteds.indexOf(g)>-1
      draw()
    )
    $td.append('label').attr('for', (d) -> 'page-' + d.key).text((d) -> d.name)
    $li.append('td').text((d) -> d3.format(',') d.sumVisits)
    $li.append('td').text((d) -> d3.format(',') d.sumSubs)
    $li.append('td').text((d) -> d3.format('%') d.sumSubs/d.sumVisits)


    $offsets = d3.select("#chart-controls").selectAll('span.offset')
    .data([{n: 'Comulative', v:'zero'},{n: 'Normalized', v:'expand'}]).enter().append('span').attr('class', 'offset')
    $offsets.append('input').attr('type','radio').attr('name', 'offset').attr('id', (d) -> 'offset-' + d.v)
    .on('change', (val) ->
        chart.stackOffset val.v
        draw()
    )
    $offsets.append('label').attr('for', (d) -> 'offset-' + d.v).text((d) -> d.n)


    draw()



