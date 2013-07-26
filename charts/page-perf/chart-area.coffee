selectedPages = []

chartTable = () ->
  # table is also a chart kinda
  valuesMap = (d) -> d.values

  chart = (selection) ->
    selection.each () ->
      $table = d3.select(this).append('tbody')

      chart.draw = (raw) ->

        tableData = raw.map (g) ->
          sumVisits: valuesMap(g).map((d) -> d.visits).reduce((a,b)->a+b)
          color: g.color
          sumSubs: valuesMap(g).map((d) -> d.subs).reduce((a,b)->a+b)
          key: g.key
          name: g.name

        # enter
        $li = $table.selectAll('tr').data(_.sortBy tableData, (a) -> -a.sumVisits)
        $liEnter = $li.enter().append('tr')
        .on('mouseover', (g) -> highlightPage g.key)
        .on('mouseout', (g) -> deHighlightPage g.key)
        $liEnter.append('td').attr('class', 'id')
        $liEnter.append('td').attr('class', 'input')
        $liEnter.select('td.input').append('input').attr('type', 'checkbox')
        .on('change', () ->
            selecteds = [];
            d3.selectAll('#pages input:checked').each((d) -> selecteds.push d.key)
            selectedPages = selecteds
            reDraw raw
          )
        $liEnter.select('td.input').append('label')
        ['td.visits', 'td.subs', 'td.conv'].forEach (t) ->
          $liEnter.append(t.split('.')[0]).attr('class', t.split('.')[1])

        # update
        $li.attr('data-key',(d) -> d.key).style('color', (d) -> d.color)
        $li.select('td.id').text((d) -> d.key)

        $li.select('td.input input')
        .attr('id', (d) -> 'page-' + d.key).attr('name', (d) -> d.key)
        .attr('checked', (d) -> if _(selectedPages).contains(d.key) then 'checked' else null)
        $li.select('td.input label').text((d) -> d.name).attr('for', (d) -> 'page-' + d.key)

        $li.select('td.visits').text((d) -> d3.format(',') d.sumVisits)
        $li.select('td.subs').text((d) -> d3.format(',') d.sumSubs)
        $li.select('td.conv').text((d) -> d3.format('.2%') d.sumSubs/d.sumVisits)

  chart.values = (map) -> valuesMap = map ? valuesMap; return chart;

  return chart

# visits chart
chart = stackedAreaimeSeriesChart()
.key((g) -> g.key)
.values((g) -> g.values)
.x((d) -> d.day)
.y((d) -> d.visits)

d3.select('#visits-chart .chart').call chart

# conv chart
convChart = multiLineTimeSeriesChart()
.key((g) -> g.key)
.values((g) -> g.values)
.x((d) -> d.day)
.y((d) -> d.conv)
.mouseover((key) -> highlightPage key)
.mouseout((key) -> deHighlightPage key)

d3.select('#conv-chart .chart').call convChart

table = chartTable()

d3.select('#pages').call table


reDraw = (groupedData) ->
  chart.addStack groupedData
  convChart.addStack groupedData
  table.draw groupedData


highlightPage = (key) ->
  $g = d3.selectAll('#visits-chart [data-key="' +key+ '"]')
  orig = d3.rgb $g.attr('data-orig-color') ?  $g.style('fill')
  $g.attr('data-orig-color', orig)
  $g.transition('fill').duration(200).style('fill', orig.brighter(.7))
  $g.select('path').style('stroke', orig.brighter(.7)).style('stroke-width', 4)

  d3.selectAll('#conv-chart [data-key="' +key+ '"]')
  .transition('stroke-width').style('stroke-width', 5)

  d3.selectAll('#pages [data-key="' +key+ '"]')
  .style('outline', 'solid 2px')
  .transition().duration(200).style('color', orig.darker(.1))

deHighlightPage = (key) ->
  $g = d3.select('[data-key="' +key+ '"]')
  orig = $g.attr('data-orig-color')
  if(orig)
    $g.transition('fill').duration(200).style('fill', orig)
  $g.select('path').style('stroke', '')

  d3.selectAll('#conv-chart [data-key="' +key+ '"]')
  .transition('stroke-width').style('stroke-width', 2)

  d3.selectAll('#pages [data-key="' +key+ '"]')
  .style('outline', 'solid 0px')
  .transition().duration(200).style('color', orig)




d3.csv 'charts/page-perf/data/sc50time.csv', (data) ->
  # parse data
  parseDate = d3.time.format("%m/%d/%Y").parse;
  data = data.map (d) ->
    d.day = parseDate(d.day)
    d.visits = +d.visits
    d.subs = +d.subs
    d.conv = if d.visits > 0 then  d.subs/d.visits else 0
    d

  #data = data.filter (d) -> d.day >= new Date(2013,6,15) && d.day <= new Date(2013,7,15)


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

    draw = () -> reDraw graphData


    chartDateRane = [null,null]
    # just an example
    filterByTime= () ->
      map = (g) -> g.values.filter (d) ->
        if !!chartDateRane[0] then d.day >= chartDateRane[0] else true &&
        if !!chartDateRane[1] then d.day <= chartDateRane[1] else true
      chart.values map
      convChart.values map
      table.values map
      draw()


    averageVisitsPerPage = _.chain(graphData).map((g) ->g.sumVisits).reduce((a,b)->a+b).value()/(graphData.length+1)
    stdVisitsPerPage = graphData.map((g) ->g.sumVisits).map((v) -> Math.sqrt Math.pow (v-averageVisitsPerPage), 2).reduce((a,b) -> a+b)/(graphData.length+1+1)

    # default filter = page.visit > average-std
    selectedPages = graphData.filter((group) -> group.sumVisits > averageVisitsPerPage-stdVisitsPerPage).map (g) ->g.key

    chart.keyFilter (g) -> selectedPages.indexOf(g) > -1
    convChart.keyFilter (g) -> selectedPages.indexOf(g) > -1


    # date control
    parseHtml5Date = d3.time.format("%Y-%m-%d")
    dateRange = [(parseHtml5Date d3.min graphData[0].values.map (d) -> d.day), parseHtml5Date d3.max graphData[0].values.map (d) -> d.day]
    d3.select('#fromDate').datum(dateRange).attr('min', (d) -> d[0]).attr('value', (d) -> d[0]).attr('max', (d) -> d[1])
    .on('change', () ->
      chartDateRane[0] = parseHtml5Date.parse this.value
      filterByTime()
    )
    d3.select('#toDate').datum(dateRange).attr('min', (d) -> d[0]).attr('value', (d) -> d[1]).attr('max', (d) -> d[1])
    .on('change', () ->
        chartDateRane[1] = parseHtml5Date.parse this.value
        filterByTime()
    )

    #controls for visits chart
    $offsets = d3.select("#visits-chart .controls").selectAll('span.offset')
    .data([{n: 'Comulative', v:'zero'},{n: 'Normalized', v:'expand'}]).enter().append('span').attr('class', 'offset')
    $offsets.append('input').attr('type','radio').attr('name', 'offset').attr('id', (d) -> 'offset-' + d.v)
    .attr('checked', (d) -> if 'zero' == d.v then 'checked' else null)
    .on('change', (val) ->
        chart.stackOffset val.v
        draw()
    )
    $offsets.append('label').attr('for', (d) -> 'offset-' + d.v).text((d) -> d.n)


    #controls for visits conv chart
    $smoothers = d3.select("#conv-chart .controls").selectAll('span.smoother')
    .data([{n: 'Actual', v:'conv'},{n: 'Moving Average', v:'conv_ma'},{n: 'Comulative MA', v:'conv_cma'}]).enter().append('span').attr('class', 'smoother')
    $smoothers.append('input').attr('type','radio').attr('name', 'smoother').attr('id', (d) -> 'smoother-' + d.v)
    .attr('checked', (d) -> if 'conv' == d.v then 'checked' else null)
    .on('change', (val) ->
        convChart.y (d) -> d[val.v] # set y map to d.conv or d.conv_ma or d.conv_cma
        draw()
      )
    $smoothers.append('label').attr('for', (d) -> 'smoother-' + d.v).text((d) -> d.n)

    draw()



