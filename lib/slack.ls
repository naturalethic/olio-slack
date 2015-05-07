require! \co-request
require! \ws
require! \xregexp

global.randint = (min, max) ->
  Math.floor(Math.random! * (max - min + 1)) + min

global.random-element = (list) ->
  list[randint(0, list.length - 1)]

global.state =
  message-id: 0

call = (method, data) ->*
  if not olio.config.slack?token
    error "You must provide a value for 'slack.token' in your olio configuration.".red
  data.token = olio.config.slack?token
  response = yield co-request do
    uri: "https://api.slack.com/api/#method"
    method: \post
    form-data: data
  JSON.parse response.body

send = ->
  it.id = state.message-id++
  state.socket.send JSON.stringify it

invoke = (re, fn, message) ->*
  re = re.replace /\$USER/, '<@[A-Z0-9]+>'
  re = xregexp.XRegExp re, \xni
  if m = re.xexec message.text
    args = [ message ]
    for name in (re.xregexp.capture-names or [])
      if um = /^<@([A-Z0-9]+)>$/.exec m[name]
        m[name] = state.users[um.1]
      args.push m[name]
    if /function\*/.test fn.to-string!
      reply = yield fn ...args
    else
      reply = fn ...args
    send reply if reply
    return true
  false

export start = (listener) ->*
  load-modules = ->
    state.modules = {}
    mods = require-dir \slack
    for name in olio.config.slack.modules
      state.modules[name] = mods[name] if mods[name]
  if olio.option.reload-modules
    watcher.watch 'slack', persistent: true, ignore-initial: true .on 'all', (event, path) ->
      info "Module '#path' changed, reloading."
      slack-module = require.cache[fs.realpath-sync path]
      for fname, func of slack-module
        delete module.exports[fname]
      delete require.cache[fs.realpath-sync path]
      load-modules!
  state <<< yield call \rtm.start, agent: \node-slack
  state.users |> each -> state.users[it.name] = it; state.users[it.id] = it
  state.ims   |> each -> state.users[it.user].im = it.id
  state.usernames = state.users |> map -> it.name
  state.userids   = state.users |> map -> it.id
  state.socket = new ws state.url
  state.socket.on \open, ->
  state.socket.on \message, co.wrap (data, flags) ->*
    message = JSON.parse data
    info message
    if (message.channel and state.users[message.user]) and (message.channel == state.users[message.user].im) and !/(cb|copperbot)/.test message.text
      message.text = 'cb ' + message.text
    if message.type is \message and message.reply_to is undefined
      for mname, {re, fn} of state.modules
        continue if mname == olio.config.slack.default
        continue if not (re and fn)
        return if yield invoke re, fn, message
      {re, fn} = state.modules[olio.config.slack.default]
      yield invoke re, fn, message
