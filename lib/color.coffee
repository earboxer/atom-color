{$} = require "atom"
_ = require "underscore-plus"

module.exports =

  configDefaults:
    fillColorAsBackground: yes

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

    [red, green, blue, alpha] = color.split(",").map (val)-> parseFloat val.trim()
    if red >= 0 and green >= 0 and blue >= 0
      alpha = 1 if alpha is NaN
      alpha = 1 if alpha is undefined
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
    setInterval =>
      @compile()
    , 1000
    @compile()

  compile: (context)->

    fill = atom.config.get "color.fillColorAsBackground"
    size = atom.config.get "editor.fontSize"
    line = atom.config.get "editor.lineHeight"

    $activeEditorView = $ atom.workspaceView.getActiveView()
    $(".source.css .color, .source.stylus .color, .source.less .color, .source.sass .color", $activeEditorView)
      .each (i, el)=>
        $el = $ el
        color = @parseColor $el.text()

        unless color.raw
          bgc = "rgba(#{color.red}, #{color.green}, #{color.blue}, #{color.alpha})"
        else
          bgc = color.raw

        if $el.data("color") isnt bgc
          $el.data "color", bgc

          if fill
            $el.addClass "color-box on-background"
            $el.css
              backgroundColor: bgc
              color: @inverseColor $el.text()
          else
            curLine = $el.closest ".line"

            colorBox = $ '<span/>'
            colorBox.addClass "color-box on-line-end"
            colorBox.css
              backgroundColor: bgc
              width: (size * line) - 4
              height: (size * line) - 4
            curLine.append colorBox
