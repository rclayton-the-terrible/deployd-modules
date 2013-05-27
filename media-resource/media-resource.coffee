Resource = require "deployd/lib/resource"
Script   = require "deployd/lib/script"
util     = require "util"

class MediaResource extends Resource

  @label: "Media"
  @events: [ "get", "post", "delete", "put" ]
  clientGeneration: true

  handle: (ctx, next) =>

    parts = ctx.url.split("/").filter (p) -> p

    result = {}

    domain =
      url: ctx.url
      parts: parts
      query: ctx.query
      body: ctx.body
      "this": result
      setResult: (val) -> result = val

    if ctx.method is "POST" and @events.post
      @events.post.run ctx, domain, (err) =>
        ctx.done err, result
    else if ctx.method is "GET" and @events.get
      @events.get.run ctx, domain, (err) =>
        ctx.done err, result
    else
      next()

module.exports = MediaResource