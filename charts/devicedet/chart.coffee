require.config({
  baseUrl: ''
  map:
    '*':
      'css': 'javascript/libs/require-css/css'
      'text': 'javascript/libs/require-text'
})


# this too works: /modules-test/modules/hello/module.js
require ['chart-modules/bar/chart', 'chart-modules/utils/reduceLongTail', 'chart-modules/utils/sum']
, (barChart, reduceLongTail, sum) ->

  reduceLongTail = _.partial reduceLongTail, ((v) ->v.visits<=100), (tail) ->
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

  subMethodDeviceConvChart = new groupedBarsChart()
  d3.select('#submethodDevice-conv-chart').call subMethodDeviceConvChart

  subMethodDeviceVisitsChart = new groupedBarsChart()
  d3.select('#submethodDevice-visits-chart').call subMethodDeviceVisitsChart

  visitsBySubMethodsChart = barChart()

  drawSubMethodDeviceChart = (node, data, compareConvWithOnlyConvertingDevices) ->
    zip = (n) ->
      zipped = (n.children.map (c) -> zip(c))
      visits = if zipped.length == 0 then 0 else zipped.map((d)->d.visits).reduce (a,b)->a+b
      subscribers = if zipped.length == 0 then 0 else zipped.map((d)->d.subscribers).reduce (a,b)->a+b
      wurflIds = _.flatten zipped.map (c) ->c.wurflIds

      if !!n.wurfl_device_id
        wurflIds.push(n.wurfl_device_id)
      if !!n.collected_children
        for c in n.collected_children
          wurflIds.push c.wurfl_device_id

      visits: (n.visits||0) + visits
      subscribers: (n.subscribers||0) + subscribers
      wurflIds: wurflIds

    zipped= zip node

    rootName = node.wurfl_device_id or zipped.wurflIds[0]

    convHierarchy = createSubMethodDeviceHierarchy(data, zipped.wurflIds, rootName, (sarr, skey) ->
      if compareConvWithOnlyConvertingDevices
        sarr = sarr.filter (d) -> d.subscribers >0
      subGroupVisits = sum(sarr.map (a) -> a.visits)
      mu = if sarr.length ==0 then 0 else sum(sarr.map (a) -> a.subscribers)/subGroupVisits
      name: skey
      value: mu
      stdev: if sarr.length <2 then 0 else sum( sarr.map (d) -> Math.sqrt(Math.pow(d.conv-mu,2)) *d.visits/subGroupVisits)
    )
    subMethodDeviceConvChart.draw convHierarchy


    visitsHierarchy = createSubMethodDeviceHierarchy(data, zipped.wurflIds, rootName, (sarr, skey, marr, raw) ->
      majorVisits = sum raw.filter((d) ->d.device == skey).map((d) -> d.visits)
      mainGroupVisits = sum(marr.map (d) -> d.visits)
      subGroupVisits = sum(sarr.map (a) -> a.visits)
      #mu = if sarr.length ==0 then 0 else sum(sarr.map (a) -> a.subscribers)/subGroupVisits
      name: skey
      value: subGroupVisits/majorVisits
      stdev: 0 # if sarr.length <2 then 0 else sum( sarr.map (d) -> Math.sqrt(Math.pow(d.conv-mu,2)) *d.visits/subGroupVisits)
    )
    subMethodDeviceVisitsChart.draw visitsHierarchy


    allSubMethods = convHierarchy.map (c) ->c.name

    targetDevices = data.filter((d) -> zipped.wurflIds.indexOf(d.wurfl_device_id) >-1)
    visitsData = _.chain(targetDevices).groupBy((d) -> d.method).map( (arr, key) ->
      name: key
      value: sum arr.map((a) -> a.visits)
    ).value()

    existingSubMethods = visitsData.map (c) ->c.name
    for m in allSubMethods.filter((s) -> existingSubMethods.indexOf(s)<0)
      visitsData.push {name: m, value: 0}

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

  # visits by submethods chart

  #visitsBySubMethodsChart = new barChart()
  #d3.select('#device-visits-bysubmethods-chart').call visitsBySubMethodsChart

  #end visits by submethods chart

  # treemap chart

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

    # adds the root of tree back to the tree
    addBack = (root) ->
      if(root.children.length > 0)
        root.children.forEach addBack
        root.children.push
          children: []
          wurfl_device_id: root.wurfl_device_id
          wurfl_fall_back: root.wurfl_fall_back
          brand_name: root.brand_name
          model_name: root.model_name
          conv: root.conv
          device_os :root.device_os
          visits: root.visits
          subscribers: root.subscribers
        root.visits = 0
        root.subscribers = 0
        root.conv = 0

    # convers the data array to a tree starting from root
    pack = (root, data, cutLongTail) ->
      data.forEach (d,i) ->
        if(d != null && d.wurfl_fall_back == root.wurfl_device_id)
          data = pack d, data, cutLongTail
          root.children.push d
          if cutLongTail
            root.children = reduceLongTail root.children
          data[i] = null
      data



    return (cutLongTail, data) ->
      [0..data.length-1].forEach (i) ->
        d = data[i]
        if(!!d)
          data = pack data[i], data, cutLongTail
        data = data.filter (d) -> d != null

      [0..data.length-1].forEach (i) ->
        addBack(data[i])
      data



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


  chart = treeMapZoomableChart()
  d3.select('#chart').call chart


  d3.csv 'charts/devicedet/data/iq-pin-android.csv', (raw) ->

    fresh = () ->
      raw.map (d) ->
        wurfl_device_id : d.wurfl_device_id
        wurfl_fall_back : d.wurfl_fall_back
        brand_name : d.brand_name
        model_name : d.model_name
        visits : +d.visits
        subscribers : +d.subscribers
        method : d.method
        conv : (+d.conv) or 0
        device_os :d.device_os
        children : []

    window.fresh= fresh


    $ ()->
      subMethods = _.chain(fresh()).map((d) -> d.method).uniq().value()
      subMethods.push('')

      d3.select('#submethods').data([subMethods])
      .on('change', () -> redraw())
      .selectAll('option').data((d) -> d)
      .enter().append('option').text((d) -> d)

    makeGroupByFunction = (order, treefy, cutLongTail) ->
      order = _(order).reverse()
      t = if treefy then _.partial(makeTreeByParentId, cutLongTail) else _.identity
      l = if cutLongTail and not treefy then reduceLongTail else _.identity
      lastF = _.compose(t,l)
      order.forEach (p) ->
        lastF = _.partial groupBy, lastF, (d) -> d[p]
      lastF


    lastTree = null
    redrawSubMethodDeviceChart = (tree = null) ->
      tree = tree or lastTree
      lastTree = tree
      drawSubMethodDeviceChart tree, fresh(), $('#onlyConvertingDevices')[0].checked

    # how to call draw: draw subMethods[0],(makeGroupByFunction ['brand_name', 'device_os'], true, true)
    redraw = () ->
      groupBys = ($('#groupbys-bin').find('li').map () -> $(this).attr('data-groupby')).get()
      tree = draw fresh(), $("#submethods").val(),(makeGroupByFunction groupBys, $('#treefy')[0].checked, $('#collectLongTail')[0].checked)
      redrawSubMethodDeviceChart(tree)

    redraw()


    $ () ->

      $('#groupbys-bin, #groupbys').sortable({
        connectWith: '.connected'
      })
      $('#groupbys-bin, #groupbys').on('dragend', () -> redraw())

      $('#treefy, #collectLongTail').on('change', () -> redraw())

      $('#onlyConvertingDevices').on('change', () -> redrawSubMethodDeviceChart())


    chart.zoomed (node) -> redrawSubMethodDeviceChart(node)
