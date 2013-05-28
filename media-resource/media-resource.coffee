Resource   = require "deployd/lib/resource"
Script     = require "deployd/lib/script"
httpUtil   = require "deployd/lib/util/http"
util       = require "util"
formidable = require "formidable"
uuid       = require "node-uuid"
FSStore    = require "./fsstore"

class MediaResource extends Resource

  @label: "Media"

  @events: [ "get", "delete", "upload" ]

  @basicDashboard:
    settings: [
      name: "Save Directory"
      type: "string"
    ]

  clientGeneration: true

  constructor: (name, options) ->
    super(name, options)
    @fileStore = new FSStore({ basedir: @config["Save Directory"] })

  handle: (ctx, next) =>

    req = ctx.req

    parts = ctx.url.split("/").filter (p) -> p

    domain =
      url: ctx.url

    if req.method is "POST" and not req.internal and req.headers["content-type"].indexOf("multipart/form-data") is 0
      form = new formidable.IncomingForm()
      remaining = 0
      files = []
      error = null

      uploadedFile = (err) =>
        if err?
          error = err
          ctx.done err
        else
          remaining--
          if remaining <= 0
            if req.headers.referer?
              httpUtil.redirect ctx.res, req.headers.referer ? "/"
            else
              ctx.done null, files

      handleFile = (name, file) =>
        remaining++

        if @events.upload
          domain:
            url: ctx.url
            fileSize: file.size
            fileName: file.filename
          @events.upload.run ctx, domain, (err) =>
            if err?
              return uploadedFile(err)
            else
              #@fileStore.write uuid.v4(),
              console.log file.filename
              uploadedFile()
        else
          console.log file.filename
          uploadedFile()

      handleError = (err) =>
        ctx.done(err)
        error = err

      form.parse(req).on("file", handleFile).on("error", handleError)

      req.resume()

    else if req.method is "GET"

      return next() if ctx.res.internal

      if @events.get
        @events.get.run ctx, domain, (err) =>
          return ctx.done(err) if err?
          next()


module.exports = MediaResource