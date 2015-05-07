greetings = [
  'Greets'
  'Holla'
  'How do?'
  'How goes it?'
  "How's it hanging?"
  "How ya goin?"
  "Howzit?"
  "Sup"
  "Wassap"
  "What is the scene?"
  "What it be?"
  "What it is?"
  "What's clicking?"
  "What's cooking?"
  "What's crack-a-lackin?"
  "What's in the bag?"
  "What's poppin?"
  "What's shakin?"
  "What's the dilly?"
  "What's the dizzle?"
  "What up?"
]

export re = '''
  (copperbot|cb)\\s+NONO
  (hello|hi|greet|morning|good\\smorning)
'''

export fn = (message) ->
  type: \message channel: message.channel, text: "<@#{message.user}> #{random-element greetings}"
