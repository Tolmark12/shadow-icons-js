var utils = require('loader-utils');

module.exports = {

  getUniqueStr : function(context) {
    uniqueStr = utils.getOptions(context).uniqueStr;
    if (uniqueStr == null) {
      return "";
    } else {
      return uniqueStr;
    }
  },

  getFileName : function(path) {
    path     = path.split('/')
    file     = path.pop()
    fileName = file.split('.')
    fileName.pop()
    return fileName.join('')
  }

}
