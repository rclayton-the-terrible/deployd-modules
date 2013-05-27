gfs = require "../gridfsstore"
gs = new gfs()
gs.write "hello2", { "Content-Type": "text/plain", chunkSize: 1024 }, "Hi Mom!", (e, r) -> console.log r

gs.read "hello2", process.stdout