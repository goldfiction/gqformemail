express = require "express"
session = require "express-session"
http = require "http"
https = require "https"
path = require "path"
moment = require "moment"
basicAuth = require "express-basic-auth"
gqemail = require "gqemail"
methodOverride=require "method-override"
bodyParser=require "body-parser"
app = express()
gqconfig=require("gqconfig")()
require "node-grequire"

exports.echo= (req,res)->
  #console.log "method:"+req.method
  if req.method.toLowerCase()=="get"
    query=req.query
  else
    query=req.body
  queryStr=""
  queryStr+="Method: "+req.method
  queryStr+="\nUrl: \n"+req.url
  queryStr+="\nRequest Body: \n"+JSON.stringify query,null,2
  queryStr+="\nHeaders: \n"+JSON.stringify req.headers,null,2
  console.log queryStr
  if config.server.sendreport
    try
      gqemail.setServer config.gmail
    catch e
      
    gqemail.emailit
      to:config.server.sendreportemail
      text:queryStr
    ,(e)->
      if e
        console.log e
  res.send 200,queryStr

runServer = (o, cb) ->
  try
    o=o or {}
    cb = cb or ()->
      return
    console.log "Server Booting up..."
    app.set "port", config.server.port or 80
    app.set "sslport", config.server.sslport or 443

    if config.basicauth.authenticate
      app.use basicAuth(config.basicauth)
    # app.use express.urlencoded()
    # app.use express.json()
    # app.use bodyParser()
    app.use bodyParser.urlencoded 
      extended: true
    app.use bodyParser.json()
    app.use methodOverride()
    app.use express.cookieParser()

    app.all "/", exports.echo

    o.message = o.message or ""
    try
      o.message += "\n"+fs.readFileSync(config.server.motd).toString()+"\n"
    catch e
    # start http server
    http.createServer(app).listen app.get("port"), (e1) ->
      o.message+= "\n FormEmail HTTP server listening on port " + app.get("port")
      # check if https server port is given
      if config.server.sslport
        # start https server
        https.createServer(
          key: fs.readFileSync(config.server.key)
          cert: fs.readFileSync(config.server.cert)
        , app).listen app.get("sslport"), (e2) ->
          o.message+= "\n FormEmail HTTPS server listening on port " + app.get("sslport")
          o.message+= "\n Server Started @ " + moment().format('YYYY-MM-DD HH:mm:ss')
          cb null, o
          console.log o.message
      else
        o.message+= "\n Server Started @ " + moment().format('YYYY-MM-DD HH:mm:ss')
        cb null, o
        console.log o.message
  catch e
    console.log e
exports.runServer=runServer