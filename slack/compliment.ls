compliments = fs.read-file-sync "#__dirname/compliment.txt" .to-string!split '\n'

export re = '''
  (copperbot|cb)\\s+
  (comp|compliment)\\s+
  (?<user> $USER)(\\s+)?
  (?<priv> priv)?
'''

export fn = (message, user, priv) ->
  if priv
    return type: \message, channel: user.im, text: random-element compliments
  type: \message, channel: message.channel, text: "<@#{user.id}> #{random-element compliments}"