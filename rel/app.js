var ShadowIcons, castShadows, pxicons, shadowIcons,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

ShadowIcons = (function() {
  function ShadowIcons() {
    this.svgReplaceWithString = __bind(this.svgReplaceWithString, this);
    window.shadowIconsInstance = this;
  }

  ShadowIcons.prototype.svgReplaceWithString = function($jqueryContext, svgString) {
    if (svgString == null) {
      svgString = pxSvgIconString;
    }
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

  ShadowIcons.prototype.replacePlaceholdersWithSVGs = function(svg, $context) {
    var $images, $svg, image, _i, _len, _results;
    $context = this.validateContext($context);
    $svg = this.buildSvg(svg, "main");
    $images = $context.querySelectorAll("img.shadow-icon");
    _results = [];
    for (_i = 0, _len = $images.length; _i < _len; _i++) {
      image = $images[_i];
      _results.push(this.createSvg(image, $svg));
    }
    return _results;
  };

  ShadowIcons.prototype.createHtmlElement = function(str) {
    var template;
    template = document.createElement('template');
    template.innerHTML = str;
    return template.content.firstChild;
  };

  ShadowIcons.prototype.createSvg = function(image, svgStr) {
    var $g, $holder, $svg, $targetSvg, id, lockToMax, modBox, newNode, rawHtml, scalable, serializer, size, usesSymbols, _ref, _ref1, _ref2, _ref3;
    $svg = this.createHtmlElement(svgStr);
    id = image.getAttribute("data-src");
    scalable = ((_ref = image.getAttribute("scalable")) != null ? _ref.toUpperCase() : void 0) === 'TRUE';
    lockToMax = ((_ref1 = image.getAttribute("lock-to-max")) != null ? _ref1.toUpperCase() : void 0) === 'TRUE';
    lockToMax || (lockToMax = ((_ref2 = image.getAttribute("data-lock-to-max")) != null ? _ref2.toUpperCase() : void 0) === 'TRUE');
    scalable || (scalable = ((_ref3 = image.getAttribute("data-scalable")) != null ? _ref3.toUpperCase() : void 0) === 'TRUE');
    $g = $svg.querySelectorAll("#" + id)[0];
    if ($g == null) {
      console.log("Shadow Icons : Tried to add an SVG with the id '" + id + "', but an SVG with id doesn't exist in the library SVG.");
      return;
    } else if ($g.getAttribute("data-size") == null) {
      console.log("Unable to find the size attribute on '" + id + "'");
      return;
    }
    size = $g.getAttribute("data-size").split('x');
    modBox = {
      width: size[0],
      height: size[1]
    };
    $targetSvg = $g;
    usesSymbols = false;
    serializer = new XMLSerializer();
    rawHtml = serializer.serializeToString($targetSvg);
    if (usesSymbols) {
      newNode = this.createHtmlElement(this.buildSvg(rawHtml, id, pxSymbolString));
    } else {
      newNode = this.createHtmlElement(this.buildSvg(rawHtml, id));
    }
    document.body.appendChild(newNode);
    if (scalable) {
      newNode.setAttribute("viewBox", "0 0 " + modBox.width + " " + modBox.height);
      $holder = this.createHtmlElement("<div class='holder'><div>");
      $holder.style.width = "100%";
      $holder.style.display = "inline-block";
      if (lockToMax) {
        $holder.style['max-width'] = "" + modBox.width + "px";
        $holder.style['max-height'] = "" + modBox.height + "px";
      }
      $holder.appendChild(newNode);
      return image.parentNode.replaceChild($holder, image);
    } else {
      newNode.setAttribute("width", "" + modBox.width + "px");
      newNode.setAttribute("height", "" + modBox.height + "px");
      return image.parentNode.replaceChild(newNode, image);
    }
  };

  ShadowIcons.prototype.validateContext = function($context) {
    if ($context == null) {
      return document.body;
    }
    if ($context instanceof jQuery) {
      return $context[0];
    }
    if (typeof $context === 'object') {
      if (Object.keys($context).length === 0) {
        return document.body;
      } else {
        return $context[Object.keys($context)[0]];
      }
    }
    return $context;
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

shadowIcons = new pxicons.ShadowIcons();

castShadows = shadowIcons.svgReplaceWithString;
