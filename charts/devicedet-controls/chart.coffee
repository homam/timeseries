require.config({
  baseUrl: ''
  map:
    '*':
      'css': 'javascript/libs/require-css/css'
      'text': 'javascript/libs/require-text'
})




# this too works: /modules-test/modules/hello/module.js
require ['chart-modules/bar/chart', 'chart-modules/bar-groups/chart' , 'chart-modules/pie/chart',
         'chart-modules/common/d3-tooltip', 'chart-modules/utils/reduceLongTail', 'chart-modules/utils/sum']
, (barChart, barGroupsChart, pieChart, tooltip, reduceLongTail, sum) ->


  reduceLongTail = do () ->

    sumVisitsWithChildren = (d) ->
      #return d.visits
      if !!d.children and d.children.length > 0
        return (d.visits||0) + d.children.map((c) -> sumVisitsWithChildren(c)).reduce (a,b)->a+b
      else
        return (d.visits||0)

    _.partial reduceLongTail, ((v) -> sumVisitsWithChildren(v)<=100), (tail) ->
      visits = sum(tail.map (v)->v.visits)
      subs = sum(tail.map (v) -> v.subscribers)
      children: []
      wurfl_fall_back: tail[0].wurfl_fall_back # todo: fall_back, brand_name and device_os have to be the common thing in the tail, need to know the last group by
      wurfl_device_id: 'more...'
      brand_name: tail[0].brand_name
      model_name: '..'
      device_os :tail[0].device_os
      visits: visits
      subscribers: subs
      conv : subs/visits
      collected_children: tail




  # bar charts

  subMethodDeviceConvChart = barGroupsChart().yAxisTickFormat(d3.format('.1%'))

  subMethodDeviceVisitsChart = barGroupsChart().yAxisTickFormat(d3.format('.1%'))

  visitsBySubMethodsChart = barChart().tooltip(tooltip().text (d) -> JSON.stringify(d))
  visitsBySubMethodsPieChart = pieChart()

  drawSubMethodDeviceChart = (node, data, compareConvWithOnlyConvertingDevices) ->
    # node: the root node (and it's children) for which we're making this chart for
    # data: all the data

    allWurlfIds = (n, r) ->
      if n.wurfl_device_id
        r.push n.wurfl_device_id
      if n.children and n.children.length >0
        for m in n.children
          allWurlfIds(m , r)
      if n.collected_children and n.collected_children.length >0
        for m in n.collected_children
          allWurlfIds(m, r)

      r

    allWids = _.flatten allWurlfIds(node, [])

    rootName = node.wurfl_device_id or allWids[0]



    convHierarchy = createSubMethodDeviceHierarchy(data, allWids, rootName, (sarr, skey) ->
      if compareConvWithOnlyConvertingDevices
        sarr = sarr.filter (d) -> d.subscribers >0
      subGroupVisits = sum(sarr.map (a) -> a.visits)
      mu = if sarr.length ==0 then 0 else sum(sarr.map (a) -> a.subscribers)/subGroupVisits
      name: skey
      value: mu
      stdev: if sarr.length <2 then 0 else sum( sarr.map (d) -> Math.sqrt(Math.pow(d.conv-mu,2)) *d.visits/subGroupVisits)
    )
    d3.select('#submethodDevice-conv-chart').datum(convHierarchy).call subMethodDeviceConvChart


    visitsHierarchy = createSubMethodDeviceHierarchy(data, allWids, rootName, (sarr, skey, marr, raw) ->
      majorVisits = sum raw.filter((d) ->d.device == skey).map((d) -> d.visits)
      mainGroupVisits = sum(marr.map (d) -> d.visits)
      subGroupVisits = sum(sarr.map (a) -> a.visits)
      #mu = if sarr.length ==0 then 0 else sum(sarr.map (a) -> a.subscribers)/subGroupVisits
      name: skey
      value: subGroupVisits/majorVisits
      stdev: 0 # if sarr.length <2 then 0 else sum( sarr.map (d) -> Math.sqrt(Math.pow(d.conv-mu,2)) *d.visits/subGroupVisits)
    )
    d3.select('#submethodDevice-visits-chart').datum(visitsHierarchy).call subMethodDeviceVisitsChart


    allSubMethods = convHierarchy.map (c) ->c.name

    targetDevices = data.filter((d) -> allWids.indexOf(d.wurfl_device_id) >-1)
    visitsData = _.chain(targetDevices).groupBy((d) -> d.method).map( (arr, key) ->
      name: key
      value: sum arr.map((a) -> a.visits)
    ).value()

    existingSubMethods = visitsData.map (c) ->c.name
    for m in allSubMethods.filter((s) -> existingSubMethods.indexOf(s)<0)
      visitsData.push {name: m, value: 0}

    totalVisits = sum visitsData.map (v) ->v.value

    d3.select('#device-visits-bysubmethods-pie').datum(visitsData).call visitsBySubMethodsPieChart

    visitsBySubMethodsChart.tooltip().text (d) ->d.name + ' : ' + d3.format('%') d.value/totalVisits
    d3.select('#device-visits-bysubmethods-chart').datum(_(visitsData).sortBy((a)->a.name)).call visitsBySubMethodsChart


  # barMaker = (arr, key) -> {name:key, value: #avg(arr), stdev: #stdev(arr)}
  createSubMethodDeviceHierarchy = (data, wurflIds, name, barMaker) ->
    data = data.map (d) ->
      method: d.method,
      device: (if wurflIds.indexOf(d.wurfl_device_id)>-1  then name else 'Everything Else'),
      visits: d.visits
      subscribers: d.subscribers
      conv: d.conv


    byMethods = _(data).groupBy((d)->d.method)
    byDevices = _(data).groupBy((d)->d.device)

    hierarchy = _(byMethods).map (arr, key) ->
      name: key
      value: _.chain(arr).groupBy((d)->d.device)
      .map((sarr, skey) ->barMaker(sarr, skey, arr, data)).value()


    # add missing values

    mainValueMap = (v) ->v.value
    subNameMap = (v)->v.name
    allSubKeys = _.uniq _.flatten hierarchy.map((d) -> mainValueMap(d).map subNameMap)


    hierarchy = hierarchy.map (h)->
      allSubKeys.forEach (k,i) ->
        if !h.value[i] or h.value[i].name != k
          h.value.splice i,0,{name:k,value:0,stdev:0}

      h

    return _(hierarchy).sortBy (v) ->v.name

  #end bar charts

  # treemap chart

  chartId = 'chart'
  $("#chart-container").html('<section id="' + chartId+  '"></section>')

  chart = treeMapZoomableChart()
  d3.select('#'+chartId).call chart


  draw = (data, method, chartDataMap) ->
    chartData = null
    if !method
      groups = _(data).groupBy (d) ->d.wurfl_device_id
      chartData = _(groups).map (arr, key) ->
        visits = sum(arr.map (d) -> d.visits)
        subscribers = sum(arr.map (d) -> d.subscribers)
        item = _.clone(arr[0])
        item.visits = visits
        item.subscribers = subscribers
        item.conv = subscribers/visits
        item.method = method
        item
    else
      chartData = data.filter ((d) -> method == d.method)


    totalVisits= chartData.map((d) -> d.visits).reduce((a,b)->a+b)
    totalSubs = chartData.map((d) -> d.subscribers).reduce((a,b)->a+b)
    totalConv= totalSubs/totalVisits
    totalStdevConv = chartData.map((g) ->
      Math.sqrt(Math.pow((g.conv-totalConv), 2)) * g.visits / totalVisits
    )
    .reduce((a,b) -> a+b)


    chartData = chartDataMap(chartData)


    window.chartData = chartData

    tree =
      children: chartData
      wurfl_device_id: 'root'
      brand_name: 'root'
      model_name: 'root'
      averageConversion: totalConv
      stdevConversion: totalStdevConv
      visits: 0

    chart.draw tree

    tree

  #end treemap

  makeTreeByParentId = do () ->

    return (cutLongTail, data) ->
      data = _.clone(data)
      root = {children: []}

      findParent = (node, children) ->
        parent = _.find(children, (d) -> d.wurfl_device_id == node.wurfl_fall_back)
        if(!!parent)
          return parent

        for c in children
          parent = findParent(node, c.children)
          if(!!parent)
            parent

        null


      addToParent = (node) ->
        parent = findParent(node, data)
        if(!!parent)
          parent.children.push node
        else
          root.children.push node

      for d in data
        addToParent d

      data = root.children


      return if cutLongTail then reduceLongTail data else data



  groupBy = (childrenMap, what, data) ->
    groups = _(data).groupBy what

    _(groups).map (darr) ->

      groupVisits = darr.map((d) -> d.visits).reduce((a,b)->a+b)
      groupSubs = darr.map((d) -> d.subscribers).reduce((a,b)->a+b)
      groupAverageConv = groupSubs / groupVisits
      groupStdevConversion = darr.map((g) ->
        Math.sqrt(Math.pow((g.conv-groupAverageConv), 2)) * g.visits / groupVisits
      )
      .reduce((a,b) -> a+b)

      return {
        averageConversion: groupAverageConv
        stdevConversion: groupStdevConversion
        children: childrenMap darr
      }


  makeGroupByFunction = (order, treefy, cutLongTail) ->
    order = _(order).reverse()
    t = if treefy then _.partial(makeTreeByParentId, cutLongTail) else _.identity
    l = if cutLongTail and not treefy then reduceLongTail else _.identity
    lastF = _.compose(t,l)
    order.forEach (p) ->
      lastF = _.partial groupBy, lastF, (d) -> d[p]
    lastF



  query = do () ->

    cached = null
    cachedKey = null
    makeCacheKey = (f,t,c) -> c + f.valueOf() + t.valueOf()
    getCache = (fromDate, toDate, country) -> if makeCacheKey(fromDate,toDate,country) == cachedKey then cached else null
    saveCache = (fromDate, toDate, country,value) ->
      cachedKey = makeCacheKey(fromDate,toDate,country)
      cached = value


    return (fromDate, toDate, country) ->
      p = $.Deferred()
      if getCache(fromDate,toDate,country)
        p.resolve cached
      else
        timezone = new Date().getTimezoneOffset() * -60*1000;
        dates = (toDate.valueOf()-fromDate.valueOf())/ (1000*60*60*24)
        gets = [0..dates-1].map((i) -> fromDate.valueOf() + (i*(1000*60*60*24)) + timezone).map((d) -> {date:d, dateName: new Date(d).toISOString().split('T')[0]}).map (d) -> {date:d.date,dateName:d.dateName,def:$.get('charts/devicedet-controls/data/'+country+'-'+d.dateName+'.csv')}

        $.when.apply($,gets.map (d) -> d.def).done () ->
          items =null
          if (gets.length > 1)
            items = _.chain(Array.prototype.slice.call(arguments, 0).map (d) -> d3.csv.parse d[0]).flatten()
          else
            items = _.chain d3.csv.parse arguments[0]

          items = items.groupBy('wurfl_device_id').map((deviceArr) ->
            _.chain(deviceArr).groupBy('Method').map((arr, method) ->
              visits = sum arr.map (d) -> +d.Visits
              subscribers = sum arr.map (d) ->  +d.Subscribers
              wurfl_device_id : arr[0].wurfl_device_id
              wurfl_fall_back : arr[0].wurfl_fall_back
              brand_name : arr[0].brand_name
              model_name : arr[0].model_name
              device_os :arr[0].device_os
              visits : visits
              subscribers : subscribers
              method : method
              conv : subscribers/visits
            ).value()
          ).flatten().value()
          p.resolve items
          saveCache(fromDate,toDate,country, items)
      return p

  fromDate = new Date(2013,6,1) # July 1
  toDate = new Date(2013,6,15)
  country = 'om'

  ['ae','sa','om', 'iq','jo', 'lk'].sort().forEach (c) -> $("select[name=country]").append $("<option />").text(c)

  $('#fromDate').val d3.time.format('%Y-%m-%d') fromDate
  $('#toDate').val d3.time.format('%Y-%m-%d') new Date(toDate.valueOf() - (1000*60*60*24)) # UI shows including toDate
  $("select[name=country]").val(country)

  $("input[type=date]").on 'change', () ->
    $this = $(this)
    if 'fromDate' == $this.attr("id")
      fromDate = new Date($this.val())
    if 'toDate' == $this.attr("id")
      toDate = new Date($this.val())
      toDate = new Date(toDate.valueOf() + (1000*60*60*24)) # UI shows including toDate


    redraw(false)

  $("select[name=country]").change () ->
    country = $("select[name=country]").val()
    redraw(true)





  fresh = () ->
    query(fromDate,toDate,country).done (items) ->
      _.chain(items).map((i) ->
        i.children = []
        return i
      ).clone().value()

  window.fresh = fresh


  populateSubMethodsSelect = (data) ->
    subMethods = _.chain(data).map((d) -> d.method).uniq().value()
    subMethods.push('')

    $('#submethods').html('')

    d3.select('#submethods').data([subMethods])
    .on('change', () -> redraw())
    $options = d3.select('#submethods').selectAll('option').data((d) -> d)
    $options.enter().append('option').text((d) -> d)
    $options.exit().remove((d) ->
      debugger
    )



  lastTree = null
  lastData = null
  redrawSubMethodDeviceChart = (tree = null, data = null) ->
    lastTree = tree or lastTree
    lastData = data or lastData
    drawSubMethodDeviceChart lastTree, lastData, $('#onlyConvertingDevices')[0].checked

  # how to call draw: draw subMethods[0],(makeGroupByFunction ['brand_name', 'device_os'], true, true)
  redraw = (countryChanged) ->
    fresh().done (data) ->
      if(countryChanged)
        populateSubMethodsSelect data
      groupBys = ($('#groupbys-bin').find('li').map () -> $(this).attr('data-groupby')).get()
      #setTimeout () ->
      tree = draw data, $("#submethods").val(),(makeGroupByFunction groupBys, $('#treefy')[0].checked, $('#collectLongTail')[0].checked)
      redrawSubMethodDeviceChart(tree, data)
      #,10 # first update the select then render the graph

  redraw(true)

  window.redraw = redraw


  $ () ->

    $('#groupbys-bin, #groupbys').sortable({
      connectWith: '.connected'
    })
    $('#groupbys-bin, #groupbys').on('dragend', () -> redraw())

    $('#treefy, #collectLongTail').on('change', () -> redraw())

    $('#onlyConvertingDevices').on('change', () -> redrawSubMethodDeviceChart())

    chart.zoomed (node) -> redrawSubMethodDeviceChart(node)









