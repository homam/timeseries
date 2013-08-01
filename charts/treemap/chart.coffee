pack = (root, data) ->
  data.forEach (d,i) ->
    if(d != null && d.wurfl_fall_back == root.wurfl_device_id)
      data = pack d, data
      root.children.push d
      data[i] = null
  data

addBack = (root) ->
  if(root.children.length > 0)
    root.children.forEach addBack
    root.children.push
      children: []
      wurfl_device_id: root.wurfl_device_id
      brand_name: root.brand_name
      model_name: root.model_name
      conv: root.conv
      visits: root.visits


groupByBrandName = (data) ->
  groups = _(data).groupBy (d) -> d.brand_name

  _(groups).map (darr, key) ->

    [0..darr.length-1].forEach (i) ->
      d = darr[i]
      if(!!d)
        darr = pack darr[i], darr
    darr = darr.filter (d) -> d != null

    [0..darr.length-1].forEach (i) ->
      addBack(darr[i])

    return {
      children: darr
    }

groupByParentIdOnly = (data) ->
  [0..data.length-1].forEach (i) ->
    d = data[i]
    if(!!d)
      data = pack data[i], data
    data = data.filter (d) -> d != null

  [0..data.length-1].forEach (i) ->
    addBack(data[i])

  data



d3.csv 'charts/treemap/data/devices.csv', (data) ->

  data = data.map (d) ->
    d.wurfl_device_id = d.wurfl_device_id
    d.wurfl_fall_back = d.wurfl_fall_back
    d.brand_name = d.brand_name
    d.model_name = d.model_name
    d.visits = +d.visits
    d.subscribers = +d.subscribers
    d.conv = +d.conv
    d.children = []
    d


  more = data.filter((d) ->d.visits <= 100).map((d) -> d.visits).reduce((a,b)->a+b)
  data = data.filter (d) ->d.visits > 100
  data.push
    children: [],
    wurfl_fall_back: 'root'
    wurfl_device_id: 'more...'
    brand_name: 'more'
    model_name: '..'
    visits: more

  data = groupByBrandName data #groupByParentIdOnly data


  window.data = data

  tree =
    children: data
    wurfl_device_id: 'root'
    brand_name: 'root'
    model_name: 'root'
    visits: 0

  chart = treeMapZoomableChart() #treeMapChart()

  d3.select('#chart').call chart

  chart.draw tree





