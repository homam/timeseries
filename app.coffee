express = require 'express'
path = require 'path'
http = require 'http'

app = express()

app.use express.static '/.public'

app.set 'port', process.env.PORT or 2999
app.set 'views', __dirname + '/views'
app.set 'view engine', 'ejs'
app.use express.logger 'dev'
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router

app.use express.favicon()



app.use(require('less-middleware')({src: 'charts', dest: 'charts', prefix: '/charts'}))
app.use require('connect-coffee-script')
  src: __dirname + '/public'
  bare: true


app.use '/charts', express.static 'charts'
app.use '/chart-modules', express.static 'chart-modules'
app.use '/modules-test', express.static 'modules-test'
app.use '/javascript', express.static 'public/javascript'


#app.get '/', (require './routes').index
require('./routes').register(app)



http.createServer(app).listen app.get('port'), ()->
  console.log "express started at port " + app.get('port')