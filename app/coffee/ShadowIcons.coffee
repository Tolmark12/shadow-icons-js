class ShadowIcons

  constructor : () -> window.shadowIconsInstance = @

  # API --------------------------------------------------------

  svgReplaceWithString : ($jqueryContext, svgString=pxSvgIconString) =>
    @replacePlaceholdersWithSVGs svgString, $jqueryContext

  svgReplaceWithExternalFile : ( url, $jqueryContext)->
    $.ajax
      url: url
      type: "GET"
      dataType: "xml"
      success: (svgData, status, jqXHR)=>
        @replacePlaceholdersWithSVGs svgData, $jqueryContext

  # HELPERS ----------------------------------------------------

  replacePlaceholdersWithSVGs : (svg, $context) ->
    $context = @validateContext $context
    $svg     = @buildSvg(svg, "main")
    $images  = $context.querySelectorAll("img.shadow-icon")

    for image in $images
      @createSvg image, $svg

  createHtmlElement : (str) ->
    template = document.createElement('template')
    template.innerHTML = str
    return template.content.firstChild

  createSvg : (image, svgStr)->
    $svg = @createHtmlElement(svgStr)

    # Pull the svg's id off the image "data-src" attr
    id           = image.getAttribute "data-src"
    scalable     = image.getAttribute("scalable")?.toUpperCase()           == 'TRUE'
    lockToMax    = image.getAttribute("lock-to-max")?.toUpperCase()        == 'TRUE'
    lockToMax  ||= image.getAttribute("data-lock-to-max")?.toUpperCase()   == 'TRUE'
    scalable   ||= image.getAttribute("data-scalable")?.toUpperCase()      == 'TRUE'

    # grab the svg libraries raw 'g' element matching that id
    $g =  $svg.querySelectorAll("##{id}")[0]
    # Return if this id doesn't exist in the library svg
    if !$g?
      console.log "Shadow Icons : Tried to add an SVG with the id '#{id}', but an SVG with id doesn't exist in the library SVG.";
      return
    else if !$g.getAttribute("data-size")?
      console.log "Unable to find the size attribute on '#{id}'"
      return


    size = $g.getAttribute("data-size").split('x')
    modBox = {width: size[0], height: size[1]}
    $targetSvg = $g

    # usesSymbols = $("use", $targetSvg).length != 0
    usesSymbols = false # Force to not use symbols

    # Grab the raw svg string
    serializer = new XMLSerializer()
    rawHtml = serializer.serializeToString $targetSvg

    # If it uses symbolds, add the symbols lib to the svg
    # Wrap the 'g' in svg tags and initialize w/ jquery
    if usesSymbols
      newNode = @createHtmlElement( @buildSvg( rawHtml, id, pxSymbolString ) )
    else
      newNode = @createHtmlElement( @buildSvg( rawHtml, id ) )

    # replace the image tage with the newly minted svg
    document.body.appendChild newNode

    if scalable
      newNode.setAttribute "viewBox", "0 0 #{modBox.width} #{modBox.height}"
      # $holder = @createHtmlElement("<div class='holder' style='max-width:#{modBox.width}px; max-height:#{modBox.height}px;'><div>")
      $holder = @createHtmlElement "<div class='holder'><div>"

      $holder.style.width   = "100%"
      $holder.style.display = "inline-block"

      if lockToMax
        $holder.style['max-width']  = "#{modBox.width}px"
        $holder.style['max-height'] = "#{modBox.height}px"

      $holder.appendChild newNode
      image.parentNode.replaceChild $holder, image
    else
      newNode.setAttribute "width",  "#{modBox.width}px"
      newNode.setAttribute "height", "#{modBox.height}px"
      # newNode.attr width: "#{modBox.width}px", height:"#{modBox.height}px"
      image.parentNode.replaceChild newNode, image

  validateContext : ($context) ->
    # If context isn't defined
    if !$context?
      return document.body
    # If it's a jquery selector
    if jQuery?
      if $context instanceof jQuery
        return $context[0]
    # If it's an object
    if typeof $context == 'object'
      # If it's empty
      if Object.keys($context).length == 0
        return document.body
      # not empty
      else
        return $context[Object.keys($context)[0]]
    return $context

  buildSvg : (svgSubElement, id, symbols="") ->
    """
      <svg id="#{id}" preserveAspectRatio= "xMinYMin meet" class="pagoda-icon" version="1.1" xmlns="http://www.w3.org/2000/svg">
        #{symbols}
        #{svgSubElement}
      </svg>
    """

pxicons = {}
pxicons.ShadowIcons = ShadowIcons
shadowIcons = new pxicons.ShadowIcons()
castShadows = shadowIcons.svgReplaceWithString
