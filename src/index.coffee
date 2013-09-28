React = require "React"


{div, form, input, button} = React.DOM


Consolication = React.createClass
  getInitialState: ->
    command: ""

  appendOutput: (html) ->
    outputNode = @refs.output.getDOMNode()
    outputNode.innerHTML = outputNode.innerHTML + html
    contentNode = @refs.content.getDOMNode()
    contentNode.scrollTop = contentNode.scrollHeight

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

    @appendOutput "<p>&gt; #{command}</p>"
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
