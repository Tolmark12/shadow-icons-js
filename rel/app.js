var ShadowIcons, pxicons;

ShadowIcons = (function() {
  function ShadowIcons() {
    window.shadowIconsInstance = this;
  }

  ShadowIcons.prototype.svgReplaceWithString = function(svgString, $jqueryContext) {
    return this.replacePlaceholdersWithSVGs(svgString, $jqueryContext);
  };

  ShadowIcons.prototype.svgReplaceWithExternalFile = function(url, $jqueryContext) {
    return $.ajax({
      url: url,
      type: "GET",
      dataType: "xml",
      success: (function(_this) {
        return function(svgData, status, jqXHR) {
          return _this.replacePlaceholdersWithSVGs(svgData, $jqueryContext);
        };
      })(this)
    });
  };

  ShadowIcons.prototype.replacePlaceholdersWithSVGs = function(svg, $jqueryContext) {
    var $holder, $svg, $targetSvg, box, id, image, images, lockToMax, modBox, newNode, rawHtml, scalable, serializer, usesSymbols, xtra, _i, _len, _ref, _ref1, _ref2, _ref3, _results;
    $svg = $(this.buildSvg(svg, "main"));
    images = $("img.shadow-icon", $jqueryContext);
    _results = [];
    for (_i = 0, _len = images.length; _i < _len; _i++) {
      image = images[_i];
      id = $(image).attr("data-src");
      scalable = ((_ref = $(image).attr("scalable")) != null ? _ref.toUpperCase() : void 0) === 'TRUE';
      xtra = $(image).attr("xtra") != null ? Number($(image).attr("xtra")) : 0;
      lockToMax = ((_ref1 = $(image).attr("lock-to-max")) != null ? _ref1.toUpperCase() : void 0) === 'TRUE';
      lockToMax || (lockToMax = ((_ref2 = $(image).attr("data-lock-to-max")) != null ? _ref2.toUpperCase() : void 0) === 'TRUE');
      scalable || (scalable = ((_ref3 = $(image).attr("data-scalable")) != null ? _ref3.toUpperCase() : void 0) === 'TRUE');
      $targetSvg = $("#" + id, $svg)[0];
      usesSymbols = false;
      if ($targetSvg == null) {
        _results.push(console.error("Shadow Icons : Tried to add an SVG with the id '" + id + "', but a SVG with id doesn't exist in the library SVG."));
      } else {
        serializer = new XMLSerializer();
        rawHtml = serializer.serializeToString($targetSvg);
        if (usesSymbols) {
          newNode = $(this.buildSvg(rawHtml, id, pxSymbolString));
        } else {
          newNode = $(this.buildSvg(rawHtml, id));
        }
        $('body').append(newNode);
        box = newNode[0].getBBox();
        modBox = {
          width: Math.round(box.width),
          height: Math.round(box.height)
        };
        if (scalable) {
          newNode.get(0).setAttribute("viewBox", "0 0 " + (modBox.width + xtra) + " " + (modBox.height + xtra));
          $holder = $("<div class='holder'><div>");
          $holder.css({
            "width": "100%",
            "display": "inline-block"
          });
          if (lockToMax) {
            $holder.css({
              "max-width": "" + (modBox.width + xtra) + "px",
              "max-height": "" + (modBox.height + xtra) + "px"
            });
          }
          $holder.append(newNode);
          _results.push($(image).replaceWith($holder));
        } else {
          newNode.attr({
            width: "" + (modBox.width + xtra) + "px",
            height: "" + (modBox.height + xtra) + "px"
          });
          _results.push($(image).replaceWith(newNode));
        }
      }
    }
    return _results;
  };

  ShadowIcons.prototype.buildSvg = function(svgSubElement, id, symbols) {
    if (symbols == null) {
      symbols = "";
    }
    return "<svg id=\"" + id + "\" preserveAspectRatio= \"xMinYMin meet\" class=\"pagoda-icon\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">\n  " + symbols + "\n  " + svgSubElement + "\n</svg>";
  };

  return ShadowIcons;

})();

pxicons = {};

pxicons.ShadowIcons = ShadowIcons;
