Mongo = require "mongodb"


class GridFSStore

  constructor: (conf)->
    conf = conf ? {}
    @host = conf.host ? "127.0.0.1"
    @port = conf.port ? 27017
    @dbname = conf.dbname ? "files"
    @db = new Mongo.Db(@dbname, new Mongo.Server(@host, @port), {safe: false})
    @db.open (err) =>
      if err then throw "Can't connect to Mongo"


  __getFileHandle: (filename, mode, options) =>
    new Mongo.GridStore @db, filename, mode, options

  write: (id, meta, file, callback) =>
    console.log "Write called"
    gfile = @__getFileHandle id, "w", meta
    gfile.open (err, gfile) ->
      console.log "Got handle, writing"
      gfile.write file, (err, gfile) ->
        console.log "Done writing, closing"
        gfile.close (err, result) ->
          console.log "Done closing"
          callback err, result if callback?

  read: (id, outputStream) =>
    gfile = @__getFileHandle id, "r"
    gfile.open (err, gfile) ->
      rs = gfile.stream(true)
      rs.pipe(outputStream)



module.exports = GridFSStore