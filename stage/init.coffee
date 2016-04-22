### -----------------------
+++    EXAMPLE USAGE    +++
----------------------- ###

# shadowIcons = new pxicons.ShadowIcons()
# shadowIcons.svgReplaceWithString pxSvgIconString, $("body")
# OPTION 1 :
# Use the javascript formatted string found in pagoda-svg-icons.js
castShadows $("body")

# OPTION 2 :
# Alternatively, use an external file as the svg library
# shadowIcons.svgReplaceWithExternalFile 'assets/icons-sprite.svg', $("body")
#
#
# ### ---------------------------
# +++    LOCAL DEV TESTING    +++
# --------------------------- ###
#
# isHidden = null
#
# mainShowHideEvent = () =>
#   $(".show-controls").on "click", toggleControls
#   toggleControls()
#
# toggleControls = () =>
#   if isHidden
#     isHidden = false
#     showControls()
#   else
#     isHidden = true
#     hideControls()
#
#
#
# initShadowIconParent = ->
#   # Radio Events
#   $('.shadow-icon-parent-cons input:radio').change (e)=>
#     newClasses = "shadow-icon-parent "
#     if $(e.currentTarget).attr("value") == "custom"
#       newClasses += $(".shadow-icon-parent-cons #custom-class-field").val()
#     else
#       newClasses += $(e.currentTarget).attr("value")
#
#     $(".shadow-icon-parent").attr("class", newClasses)
#
#   # Key listener
#   $(".shadow-icon-parent-cons #custom-class-field").on 'input', (e)=>
#     if $(".shadow-icon-parent-cons #custom-radio").is(":checked")
#       $(".shadow-icon-parent").attr "class", "shadow-icon-parent #{$('.shadow-icon-parent-cons #custom-class-field').val()}"
#
# initShadowBody = ->
#   # Radio Events
#   $('.body-controls input:radio').change (e)=>
#     newClasses = "shadow-icon-body "
#     if $(e.currentTarget).attr("value") == "custom"
#       newClasses += $(".body-controls #custom-class-field").val()
#     else
#       newClasses += $(e.currentTarget).attr("value")
#
#     $(".shadow-icon-body").attr("class", newClasses)
#
#   # Key listener
#   $(".body-controls #custom-class-field").on 'input', (e)=>
#     if $(".body-controls #custom-radio").is(":checked")
#       $(".shadow-icon-body").attr "class", "shadow-icon-body #{$('.body-controls #custom-class-field').val()}"
#
# svgHovers = ->
#   $('svg').on "mouseover", (e)=>
#     $(e.currentTarget).css opacity:0.6
#     $('.title').text( $(e.currentTarget).attr "id" )
#
#     selection = window.getSelection()
#     selection.setBaseAndExtent($(e.currentTarget)[0], 0, $(e.currentTarget)[0], 1);
#
#     $('.title').select()
#
#   $('svg').on "mouseout", (e)=>
#     $(e.currentTarget).css opacity:1
#
# hideControls = () -> $('.controls').css display:'none';
# showControls = () -> $('.controls').css display:'block';
# initControls = () ->
#   initShadowIconParent()
#   initShadowBody()
#   svgHovers()
#   mainShowHideEvent()
#
# initControls()
