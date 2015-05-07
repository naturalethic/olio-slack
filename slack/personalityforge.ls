require! \co-request
require! \crypto
require! \urlencode

export re = '''
  (copperbot|cb)\\s+
  (?<line> .*)
'''

json-encode = require "#__dirname/../lib/json-encode"

export fn = (message, line) ->*
  user = state.users[message.user]
  outmsg =
    message:
      message: line
      chatBotID: olio.config.personalityforge.bot
      timestamp: Date.now!
    user:
      firstName: user.profile.first_name
      lastName: user.profile.last_name
      gender: \m
      externalID: user.id
  outmsg = json-encode outmsg
  .replace(/[\u2018\u2019]/g, "'")
  .replace(/[\u201C\u201D]/g, '"')
  hash = crypto.create-hmac \sha256, olio.config.personalityforge.secret
  hash.update outmsg
  hash = hash.digest \hex
  result = yield co-request "http://www.personalityforge.com/api/chat/?apiKey=#{olio.config.personalityforge.key}&hash=#{hash}&message=#{urlencode outmsg}"
  if (index = result.body.index-of '{"success":1') > -1
    result = JSON.parse result.body.substr index
    return type: \message, channel: message.channel, text: result.message.message
  null
