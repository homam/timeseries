exports = exports ? this

exports.timeSeriesChart = () ->
  # configs
  margin =
    top: 20
    right: 20
    bottom: 20
    left: 20
  width = 720
  height = 300
  color = d3.scale.category10();

