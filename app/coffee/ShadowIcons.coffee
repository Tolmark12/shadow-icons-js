class ShadowIcons

  constructor : () -> window.shadowIconsInstance = @

  # API --------------------------------------------------------

  svgReplaceWithString : (svgString, $jqueryContext) ->
    @replacePlaceholdersWithSVGs svgString, $jqueryContext

  svgReplaceWithExternalFile : ( url, $jqueryContext)->
    $.ajax
      url: url
      type: "GET"
      dataType: "xml"
      success: (svgData, status, jqXHR)=>
        @replacePlaceholdersWithSVGs svgData, $jqueryContext

  # HELPERS ----------------------------------------------------

  replacePlaceholdersWithSVGs : (svg, $jqueryContext) ->
    $svg = $ @buildSvg(svg, "main")
    images = $("img.shadow-icon", $jqueryContext)
    for image in images
      # Pull the svg's id off the image "data-src" attr
      id           = $(image).attr "data-src"
      scalable     = $(image).attr("scalable")?.toUpperCase()           == 'TRUE'
      lockToMax    = $(image).attr("lock-to-max")?.toUpperCase()        == 'TRUE'
      lockToMax  ||= $(image).attr("data-lock-to-max")?.toUpperCase()   == 'TRUE'
      scalable   ||= $(image).attr("data-scalable")?.toUpperCase()      == 'TRUE'

      # grab the svg libraries raw 'g' element matching that id
      $targetSvg = $( "##{id}", $svg)[0]

      usesSymbols = $("use", $targetSvg).length != 0

      # Return if this id doesn't exist in the library svg
      if !$targetSvg?
        console.error "Shadow Icons : Tried to add an SVG with the id '#{id}', but a SVG with id doesn't exist in the library SVG.";
      else
        # Grab the raw svg string
        serializer = new XMLSerializer()
        rawHtml = serializer.serializeToString $targetSvg

        # If it uses symbolds, add the symbols lib to the svg
        # Wrap the 'g' in svg tags and initialize w/ jquery
        if usesSymbols
          newNode = $ @buildSvg( rawHtml, id, pxSymbolString )
        else
          newNode = $ @buildSvg( rawHtml, id )

        # replace the image tage with the newly minted svg
        $('body').append newNode
        box = (newNode)[0].getBBox()
        modBox = {width: Math.round( box.width ), height: Math.round( box.height )}
        # box.width = Math.round( box.width )
        # box.height = Math.round( box.height )

        if scalable
          newNode.get(0).setAttribute "viewBox", "0 0 #{modBox.width +  8} #{modBox.height +  8}"
          # $holder = $ "<div class='holder' style='max-width:#{modBox.width +  8}px; max-height:#{modBox.height +  8}px;'><div>"
          $holder = $ "<div class='holder'><div>"

          $holder.css
            "width"          : "100%"
            "display"        : "inline-block"

          if lockToMax
            $holder.css
              "max-width"      : "#{modBox.width +  8}px"
              "max-height"     : "#{modBox.height + 8}px"

          $holder.append newNode
          $(image).replaceWith $holder
        else
          newNode.attr width: "#{modBox.width +  8}px", height:"#{modBox.height +  8}px"
          $(image).replaceWith newNode


  buildSvg : (svgSubElement, id, symbols="") ->
    """
      <svg id="#{id}" preserveAspectRatio= "xMinYMin meet" class="pagoda-icon" version="1.1" xmlns="http://www.w3.org/2000/svg">
        #{symbols}
        #{svgSubElement}
      </svg>
    """

pxicons = {}
pxicons.ShadowIcons = ShadowIcons
