{$} = require "atom"

module.exports =

  parseColor: (color)->

    hex = (code) -> parseInt code, 16

    if shortColor = color.match /^#([0-9a-f]{3})$/i
      colorObject =
        red  : hex(shortColor[1].charAt(0)) * 0x11
        green: hex(shortColor[1].charAt(1)) * 0x11
        blue : hex(shortColor[1].charAt(2)) * 0x11
        alpha: 1
      return colorObject

    if fullColor = color.match /^#([0-9a-f]{6})$/i
      colorObject =
        red  : hex fullColor[1].substr(0,2)
        green: hex fullColor[1].substr(2,2)
        blue : hex fullColor[1].substr(4,2)
        alpha: 1
      return colorObject

    [red, green, blue, alpha] = color.split(",").map (val)-> parseInt val.trim()
    if red and green and blue
      alpha ?= 1
      return {red, green, blue, alpha}

    raw: color

  inverseColor: (color)->
    color = @parseColor color

    if color.raw
      return "#fff"

    {red, green, blue} = color
    brightness = Math.sqrt(
      red * red * .241 +
      green * green * .691 +
      blue * blue * .068)

    if brightness < 130 then "#fff" else "#000"

  activate: ->
    $(atom.workspaceView).on "keyup", _.debounce (=> @compile()), 100
    @compile()

  compile: (context)->
    $activeEditorView = $ atom.workspaceView.getActiveView()
    $(".source.css .color", $activeEditorView)
      .each (i, el)=>
        $el = $ el
        color = @parseColor $el.text()

        unless color.raw
          bgc = "rgba(#{color.red}, #{color.green}, #{color.blue}, #{color.alpha})"
        else
          bgc = color.raw

        $el.css
          backgroundColor: bgc
          borderRadius: 2
          color: @inverseColor $el.text()
