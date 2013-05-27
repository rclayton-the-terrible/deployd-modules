FSStore = require "../fsstore"
assert  = require "assert"

FILENAME = "hereismyfile.txt"
CONTENT  = "Here is the content"

store = new FSStore({ basedir: "./data" })

store.write FILENAME, CONTENT, (err) ->

  console.log "Done writing; err? #{err}"

  store.read FILENAME, (err, data) ->

    console.log "Done reading; err? #{err}"

    assert.strictEqual(data, CONTENT)

    store.streamRead FILENAME, process.stdout