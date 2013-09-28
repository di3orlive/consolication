express = require "express"
ws = require "ws"


module.exports = app = express()

wss = new ws.Server
  port: 4000

wss.on "connection", (ws) ->
  ws.on "message", (request) ->
    response = """
      <p style="color: lightblue"><b>#{request}</b></p>
    """

    console.log ">", request
    console.log "<", response

    ws.send response
