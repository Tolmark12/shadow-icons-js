utils = require('loader-utils')
debug = require('debug')('loader/svg')
fs    = require('fs');


class SvgCompiler

  compile: (cssData, resource, uniqueStr) ->
    jsString = @compileJsString fs.readFileSync(resource, "utf8"), uniqueStr
    return "#{cssData}\n#{jsString}"

  getUniqueStr : (context) ->
    return 'asdf'
    uniqueStr = utils.getOptions(context).uniqueStr
    if !uniqueStr?
      return ""
    else
      return uniqueStr

  compileJsString : (data, uniqueStr)->
    # data = file.contents.toString()
    fileName = "some-files"             # Replace this
    namespace = "#{fileName}-svg "


    data = data.replace /<\?xml.+/g, ''                                                                               # Strip out the xml header
    data = data.replace /<!-- Gen.+/g, ''                                                                             # Strip out the Adobe Generator comment
    data = data.replace /<!DOC.+/g, ''                                                                                # Strip out the DOCTYPE
    data = data.replace /<style[\s\S]*<\/style>/g, ''                                                                 # Strip out the generated css
    data = data.replace /(class="st[0-9]+)/g, "$1_#{uniqueStr}"                                                       # Add the unique string to all the classes generated by illustrator. ex : class="st0"  ->  class="st0_3vf9sW"
    data = data.replace /(SVGID_[0-9]+_)/g, "$1#{uniqueStr}"                                                          # Add the unique string to all the gradients. ex : <linearGradient id="SVGID_1_"  ->  <linearGradient id="SVGID_1_3vf9sW"
    data = data.replace /<text(.+?(class="(.+?)"|<tspan)+?(.+?<tspan.+?class="(.+?)"))/g, '<text class="$3 $5" $1' ;  # illustrator does this weird thing with tspans.. grab the class and attach it to the text element
    data = data.replace /<tspan.+?>(.+?)<\/tspan>/g, '$1'                                                             # Get rid of the tspans
    data = data.replace /(<g id=".+)_x60_(.+?)x(.+?)"/g, '$1" data-size="$2x$3"'                                      # When we generate the svg, we also record the width/height as : layername`10x10   replace that with  :  id="layername" data-size="10x10"
    data = data.replace /_x5F_/g, '_'                                                                                 # Replace _x5F_'s with _'s (illustrator's character for underscore)
    data = data.replace /id="(.+)?_x[23]E_(.+?)"/g, 'id="$1" class="$2" '                                             # id / class id>class1,class2,class3
    data = data.replace /class="([a-z0-9\-_]+)"\s+class="([a-z0-9\-_]+)"/g, 'class="$1 $2"'                           # If there are multiple classes, concat them into one
    data = data.replace /id=""/g, ''                                                                                  # Delete empty ids
    data = data.replace /(<g id.+")/g, "$1 class=\"#{namespace}\""                                                    # Delete empty ids
    data = data.replace /_x2C_/g, ' '                                                                                 # Replace all commas between class with spaces
    data = data.replace /class="(.+)_[0-9]+_(.*)"/g, 'class="$1 $2"'                                                  # Strip out superfluous underscores illustrator adds to duplicate layer names, but keep the illustrator generated class
    data = data.replace /\/>\s+/g, '/>'                                                                               # remove superfluous spaces
    data = data.replace /\n|\r/g, ''                                                                                  # Strip out all returns
    data = data.replace /<svg.+?>([\s\S]*)<\/svg>/g, '$1'                                                             # Strip out svg tags

    data = data.replace /([\s\S]*)/g, "window.pxSvgIconString = window.pxSvgIconString || ''; window.pxSvgIconString+='$1';"           # Save just the svgs

    return data


module.exports = (data)->
  compiler = new SvgCompiler()
  uniqueStr = compiler.getUniqueStr this
  return compiler.compile data, this.resource, uniqueStr
