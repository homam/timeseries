movingAverage = (map, size) ->
  arr = []
  return (d, i) ->
    if arr.length >= size
      arr = arr.slice 1
    arr.push map(d)
    val = (arr.reduce (a,b) -> a+b) / (arr.length)
    return val

d3.csv 'charts/page-perf/data/sc50time.csv', (data) ->
  # parse data
  parseDate = d3.time.format("%m/%d/%Y").parse;
  data = data.map (d) ->
    d.day = parseDate(d.day)
    d.visits = +d.visits
    d.subs = +d.subs
    d.conv = if d.visits > 0 then  d.subs/d.visits else 0
    d

  hahaha = data.map( (d, i) ->
    howMany = if i > 5 then 6 else i
    d.conv_cumlativeMovingAverage = [0..i].map((j) -> data[j].conv).reduce((a,b) ->a+b)/(i+1)
    d.movingAverage = [0..howMany].map((j) -> data[j].conv).reduce((a,b) ->a+b)/(howMany+1)
    d
  )
  d3.csv 'charts/page-perf/data/pages.csv', (pages) ->

    # group the data by page
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
        d = _(group).filter( (d) -> Math.abs(+d.day - +day) < 1000)[0]

        if !d
          d = {page: key, day: day, visits: 0, subs: 0, conv: 0}
          group.splice index, 0, d

        # add moving average values to each data point
        howMany = 6
        d.conv_cma = [-howMany..index].map((j) ->
          group[if j > -1 then j else 0].conv).reduce((a,b) ->a+b)/(index+howMany+1)
        d.conv_ma = [index-howMany..index].map((j) ->
          group[if j > -1 then j else 0].conv).reduce((a,b) ->a+b)/(howMany+1)
        groups[key] = group

    # add color and sum valeues to groups
    colors = d3.scale.category20()
    graphData = _.keys(groups).map((page, i) ->
      key: page,
      name: (pages.filter (p) -> p.page == page)[0].name
      values: groups[page]
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
    .values((g) -> g.values)
    .x((d) -> d.day)
    .y((d) -> d.visits)

    d3.select('#chart').call chart

    convChart = multiLineTimeSeriesChart()
    .key((g) -> g.key)
    .values((g) -> g.values)
    .x((d) -> d.day)
    .y((d) -> d.conv)
    .mouseover((d) -> highlightPage d)
    .mouseout((d) -> deHighlightPage d)

    d3.select('#convChart').call convChart

    pageFilter = (group) ->
      group.sumVisits >= _.chain(graphData).map((g) ->g.sumVisits).reduce((a,b)->a+b).value()/(graphData.length+1)

    selectedPages = graphData.filter(pageFilter).map (g) ->g.key
    chart.keyFilter (g) -> selectedPages.indexOf(g) > -1
    convChart.keyFilter (g) -> selectedPages.indexOf(g) > -1

    draw = () ->
      chart.addStack graphData
      convChart.addStack graphData

    highlightPage = (key) ->
      $g = d3.selectAll('#chart [data-key="' +key+ '"]')
      orig = d3.rgb $g.attr('data-orig-color') ?  $g.style('fill')
      $g.attr('data-orig-color', orig)
      $g.transition('fill').duration(200).style('fill', orig.darker(.7))
      $g.select('path').style('stroke', orig.brighter(.7)).style('stroke-width', 2)

      d3.selectAll('#convChart [data-key="' +key+ '"]')
      .transition('stroke-width').style('stroke-width', 5)
    deHighlightPage = (key) ->
      $g = d3.select('[data-key="' +key+ '"]')
      orig = $g.attr('data-orig-color')
      if(orig)
        $g.transition('fill').duration(200).style('fill', orig)
      $g.select('path').style('stroke', '')

      d3.selectAll('#convChart [data-key="' +key+ '"]')
      .transition('stroke-width').style('stroke-width', 2)


    $li = d3.select('#pages tbody').selectAll('tr').data(_.sortBy graphData, (a) -> -a.sumVisits)
    $li.enter().append('tr').style('color', (d) -> d.color)
    .on('mouseover', (g) -> highlightPage g.key)
    .on('mouseout', (g) -> deHighlightPage g.key)
    $td = $li.append("td")
    $td.append('input').attr('type', 'checkbox').attr('id', (d) -> 'page-' + d.key).attr('name', (d) -> d.key)
    .attr('checked', (d) -> if _(selectedPages).contains(d.key) then 'checked' else null)
    .on('change', () ->
      selecteds = [];
      d3.selectAll('#pages input:checked').each((d) -> selecteds.push d.key)
      selectedPages = selecteds
      draw()
    )
    $td.append('label').attr('for', (d) -> 'page-' + d.key).text((d) -> d.name)
    $li.append('td').text((d) -> d3.format(',') d.sumVisits)
    $li.append('td').text((d) -> d3.format(',') d.sumSubs)
    $li.append('td').text((d) -> d3.format('.2%') d.sumSubs/d.sumVisits)


    #controls for visits chart
    $offsets = d3.select("#chart-controls").selectAll('span.offset')
    .data([{n: 'Comulative', v:'zero'},{n: 'Normalized', v:'expand'}]).enter().append('span').attr('class', 'offset')
    $offsets.append('input').attr('type','radio').attr('name', 'offset').attr('id', (d) -> 'offset-' + d.v)
    .attr('checked', (d) -> if 'zero' == d.v then 'checked' else null)
    .on('change', (val) ->
        chart.stackOffset val.v
        draw()
    )
    $offsets.append('label').attr('for', (d) -> 'offset-' + d.v).text((d) -> d.n)


    #controls for visits conv chart
    $smoothers = d3.select("#convChart-controls").selectAll('span.smoother')
    .data([{n: 'Actual', v:'conv'},{n: 'Moving Average', v:'conv_ma'},{n: 'Comulative MA', v:'conv_cma'}]).enter().append('span').attr('class', 'smoother')
    $smoothers.append('input').attr('type','radio').attr('name', 'smoother').attr('id', (d) -> 'smoother-' + d.v)
    .attr('checked', (d) -> if 'conv' == d.v then 'checked' else null)
    .on('change', (val) ->
        convChart.y (d) -> d[val.v] # set y map to d.conv or d.conv_ma or d.conv_cma
        draw()
      )
    $smoothers.append('label').attr('for', (d) -> 'smoother-' + d.v).text((d) -> d.n)

    draw()



