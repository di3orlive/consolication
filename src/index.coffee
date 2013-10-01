querystring = require "querystring"
React = require "React"
url = require "url"


{div, span, form, input, button} = React.DOM


# add INPUT_MARGIN_FIX to input width to fix webkit behaviour
INPUT_MARGIN_FIX = 10


Consolication = React.createClass
  history: []
  historyPos: 0

  getDefaultProps: ->
    debug: false
    autoFocus: false
    terminalEmulation: false
    wsServer: "localhost:4000"

  getInitialState: ->
    command: ""

  componentDidMount: ->
    if @props.autoFocus
      @refs.input.getDOMNode().focus()

    if global.WebSocket
      attempts = 0

      do connect = =>
        @log "connecting", @props.wsServer

        @websocket = new global.WebSocket "ws://#{@props.wsServer}"

        @websocket.onopen = =>
          @log "connected"

          if attempts > 0
            attempts = 0
            @write "Connected"

        @websocket.onclose = =>
          @log "disconnected"

          setTimeout =>
            @writeError "WebSocket connection closed, trying to reconnect"
            attempts += 1
            setTimeout connect, 1000
          , 100

        @websocket.onmessage = (message) =>
          @log "receive output", message.data
          @writeHTML message.data

        @websocket.onerror = =>
          @log "error"
          @writeError "WebSocket error"

    else
      @writeError "WebSocket not supported by your browser"

  writeHTML: (html) ->
    outputNode = @refs.output.getDOMNode()
    outputNode.innerHTML = outputNode.innerHTML + html

    scrollableNode = if @props.terminalEmulation
      @refs.content.getDOMNode()
    else
      outputNode

    scrollableNode.scrollTop = scrollableNode.scrollHeight

  write: (text, style) ->
    @writeHTML """<p style="#{style}">#{text}</p>"""

  writeError: (message) ->
    @write message, "color: red"

  log: ->
    console.log.apply console, arguments if @props.debug

  calculateWidth: (text) ->
    text = text.replace /&/g, "&amp;"
    text = text.replace /\ /g, "&nbsp;"
    text = text.replace /</g, "&lt;"

    hiddenInputDOMNode = @refs.hiddenInput.getDOMNode()
    hiddenInputDOMNode.innerHTML = text
    hiddenInputDOMNode.offsetWidth + INPUT_MARGIN_FIX

  setInputWidthFor: (text) ->
    maxWidth = @refs.content.getDOMNode().offsetWidth
    textWidth = @calculateWidth text
    width = if textWidth > maxWidth then maxWidth else textWidth

    @refs.input.getDOMNode().style.width = "#{width}px"

    @log "input width", width

  setCommand: (command) ->
    if @props.terminalEmulation
      @setInputWidthFor command
    @setState command: command

  handleClick: ->
    @refs.input.getDOMNode().focus()

  handleChange: (event) ->
    command = event.target.value
    @setCommand command
    @log "input value", command

  handleSubmit: (event) ->
    event.preventDefault()

    command = if @state.command.length > 0
      @state.command
    else
      "__EMPTY__"

    @history.push command
    @historyPos = @history.length

    @websocket.send command

    @setCommand ""

    @log "command send", command

  handleKeyDown: (event) ->
    switch event.keyCode
      when 38 # up
        event.preventDefault()
        @historyPos -= 1
        @historyPos = 0 if @historyPos < 0
        @setCommand @history[@historyPos] or ""
        @log "history up"

      when 40 # down
        event.preventDefault()
        @historyPos += 1
        @historyPos = @history.length if @historyPos > @history.length
        @setCommand @history[@historyPos] or ""
        @log "history down"

  render: ->
    classes = ["consolication"]
    classes.push ["consolication--behaviour-terminal"] if @props.terminalEmulation

    (div
      className: classes.join " "
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
            onChange: @handleChange
            onKeyDown: @handleKeyDown)
          (span
            className: "consolication-input-field consolication-input-field--state-hidden"
            ref: "hiddenInput"))))


document = global.document
document.addEventListener "DOMContentLoaded", ->
  element = document.getElementById "consolication"
  props = {}

  if element.attributes["data-autofocus"]
    props.autoFocus = true

  query = querystring.parse(url.parse(document.location.href).query)

  if element.attributes["data-ws-server"]
    props.wsServer = element.attributes["data-ws-server"].value
  else if query.ws
    props.wsServer = query.ws

  if element.attributes["data-terminal-emulation"]
    props.terminalEmulation = true

  if element.attributes["data-debug"] or query.debug
    props.debug = true

  React.renderComponent Consolication(props), element
