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

  tree = {}

  console.log data.length

  pack = (root) ->
    data.forEach (d,i) ->
      if(d != null && d.wurfl_fall_back == root.wurfl_device_id)
        pack d
        root.children.push d
        data[i] = null


  [0..data.length].forEach (i) ->
    d = data[i]
    if(!!d)
      pack(data[i])
  data = data.filter (d) -> d != null


  window.data = data

  tree =
    children: data
    wurfl_device_id: 'root'
    brand_name: 'root'
    model_name: 'root'

  chart =  treeMapChart()

  d3.select('#chart').call chart

  chart.draw tree





