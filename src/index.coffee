React = require "React"


{div, form, input, button} = React.DOM


Consolication = React.createClass
  getInitialState: ->
    command: ""

  componentDidMount: ->
    if global.WebSocket
      @websocket = new global.WebSocket "ws://localhost:4000"

      @websocket.onclose = =>
        @appendError "WebSocket connection closed"

      @websocket.onmessage = (message) =>
        @appendOutput message.data

      @websocket.onerror = =>
        @appendError "WebSocket error"

    else
      @appendError "WebSocket not supported by your browser"

  appendOutput: (html) ->
    outputNode = @refs.output.getDOMNode()
    outputNode.innerHTML = outputNode.innerHTML + html
    contentNode = @refs.content.getDOMNode()
    contentNode.scrollTop = contentNode.scrollHeight

  appendCommand: (command) ->
    @appendOutput "<p>&gt; #{command}</p>"

  appendError: (message) ->
    @appendOutput """<p style="color: red">#{message}</p>"""

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

    @appendCommand command
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

  React.renderComponent Consolication(props), element
