require.config({
  baseUrl: ''
  map:
    '*':
      'css': 'javascript/libs/require-css/css'
      'text': 'javascript/libs/require-text'
})


sum = (arr) ->
  arr.map((d) -> d.visits).reduce ((a,b) -> a+b), 0

isMobile = (a) ->
  /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a) or /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))

isTablet = (uac) ->
  ua = uac.toLowerCase()
  (ua.indexOf('android') > -1 && ua.indexOf('mobile') < 0) ||
  (/ipad|android 3|sch-i800|playbook|tablet|kindle|gt-p1000|gt-p5100|tablet|sgh-t849|shw-m180s|a510|a511|a100|dell streak|silk/i.test(ua));


require ['chart-modules/bar-groups-stacked/chart', 'chart-modules/pie/chart'], (barGroupsChart, pieChartMaker) ->

  d3.csv '/charts/wap-uas/data/wap-uas.csv', (data) ->
    data = data.map (d) ->
      iso: d['ISO_Code'],
      ua: d['UA'],
      visits: +d['Visits']

    data.map (d) ->
      d.mobile = isMobile(d.ua)
      d.tablet = isTablet(d.ua)
      d

    console.log sum data.filter((d) -> !d.mobile && (d.tablet))
    console.log sum data


    do () ->
      webs = sum data.filter((d) -> !d.mobile && !d.tablet)
      mobiles = sum data.filter((d) -> d.mobile && !d.tablet)
      tablets = sum data.filter((d) -> d.tablet)
      total = webs + mobiles + tablets
      format = d3.format(',')
      percent = d3.format('%')
      pieData = [
        {name: "Mobile: #{percent mobiles/total}" , value: mobiles},
        {name: "Tablet: #{percent tablets/total}", value: tablets},
        {name: "Web: #{percent webs/total}" , value: webs}
      ]

      pieChart = pieChartMaker().margin({right:120}).width(500)
      .colors(d3.scale.category10())
      d3.select('#pieChart').datum(pieData).call pieChart


    data = _.chain(data).groupBy((d) -> d.iso).map((arr,key) ->
      iso:key
      mobiles: sum arr.filter((d) -> d.mobile && !d.tablet)
      tablets: sum arr.filter((d) -> d.tablet)
      total: sum arr
    ).value()

    chartData = data.filter((d) -> d.total > 1000).map((d) ->
      name: d.iso.split('').filter((c,i) -> i<3).reduce ((a,b) -> a+b), ''
      values: [
        { name: 'Mobile', value: d.mobiles, dev:1},
        { name: 'Tablet', value: d.tablets, dev:1},
        { name: 'Web', value: d.total-d.mobiles-d.tablets, dev: 1}
      ]
    )


    chart = barGroupsChart()


    d3.select('#barChart').datum(chartData).call chart #.normalized(true).yAxisTickFormat(d3.format('.1%'))

    setTimeout ()->
      chart.normalized(true).yAxisTickFormat(d3.format('.1%'))
      d3.select('body').datum(chartData).call chart
    , 2000

    #console.log data.filter((d) -> d.mobile).length, data.length