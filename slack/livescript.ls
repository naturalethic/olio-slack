require! \sandbox
require! \livescript

sbox = new sandbox
srun = promisify (code, cb) ->
  sbox.run code, (output) ->
    cb null, output

export re = '''
  `(?<code> [^`]+)
'''

export fn = (message, code) ->*
  try
    result = yield srun livescript.compile "return (#code)"
    return type: \message, channel: message.channel, text: "`#{result.result}`"
  catch
    info 'Failed to compile:', message.text
  false
