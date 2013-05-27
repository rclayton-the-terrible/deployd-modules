fs = require "fs"


class FSStore

  constructor: (conf)->
    conf = conf ? {}
    @basedir = conf.basedir ? "/opt/data/media-resource"

  write: (id, file, callback) =>
    fs.writeFile @_getFileName(id), file, (err) ->
      callback(err) if callback

  read: (id, encoding, callback) =>
    handler = callback
    ct = encoding
    unless callback?
      ct = "utf-8"
      handler = encoding
    fs.readFile @_getFileName(id), ct, (err, file) ->
      handler(err, file) if handler

  streamRead: (id, outputStream) =>
    rs = fs.createReadStream @_getFileName(id)
    rs.on "open", -> rs.pipe outputStream
    rs.on "error", (err) -> outputStream.end(err)


  _getFileName: (id) =>
    "#{@basedir}/#{id}"


module.exports = FSStore