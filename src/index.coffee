querystring = require "querystring"
React = require "React"
url = require "url"


{div, form, input, button} = React.DOM


Consolication = React.createClass
  getDefaultProps: ->
    autoFocus: false
    wsServer: "localhost:4000"

  getInitialState: ->
    command: ""

  componentDidMount: ->
    if global.WebSocket
      attempts = 0

      do connect = =>
        @websocket = new global.WebSocket "ws://#{@props.wsServer}"

        @websocket.onopen = =>
          if attempts > 0
            attempts = 0
            @write "Connected"

        @websocket.onclose = =>
          @writeError "WebSocket connection closed, trying to reconnect"
          attempts += 1
          setTimeout connect, 1000

        @websocket.onmessage = (message) =>
          @writeHTML message.data

        @websocket.onerror = =>
          @writeError "WebSocket error"

    else
      @writeError "WebSocket not supported by your browser"

  writeHTML: (html) ->
    outputNode = @refs.output.getDOMNode()
    outputNode.innerHTML = outputNode.innerHTML + html
    contentNode = @refs.content.getDOMNode()
    contentNode.scrollTop = contentNode.scrollHeight

  write: (text, style) ->
    @writeHTML """<p style="#{style}">#{text}</p>"""

  writeError: (message) ->
    @write message, "color: red"

  handleClick: ->
    @refs.input.getDOMNode().focus()

  handleChange: (event) ->
    @setState command: event.target.value

  handleSubmit: (event) ->
    event.preventDefault()

    command = if @state.command.length > 0
      @state.command
    else
      "__EMPTY__"

    @write "> #{command}"
    @websocket.send command
    @setState command: ""

  render: ->
    (div
      className: "consolication"
      onClick: @handleClick
      (div
        className: "consolication-content"
        ref: "content"
        (div
          className: "consolication-output"
          ref: "output")
        (form
          className: "consolication-input"
          onSubmit: @handleSubmit
          (input
            className: "consolication-input-field"
            ref: "input"
            autoFocus: @props.autoFocus
            value: @state.command
            onChange: @handleChange))))


document = global.document
document.addEventListener "DOMContentLoaded", ->
  element = document.getElementById "consolication"
  props = {}

  if element.attributes["data-autofocus"]
    props.autoFocus = true

  if element.attributes["data-ws-server"]
    props.wsServer = element.attributes["data-ws-server"].value
  else
    ws = querystring.parse(url.parse(document.location.href).query).ws
    props.wsServer = ws if ws

  React.renderComponent Consolication(props), element
