require! \slack-node

if olio.config.slack?name
  slack = new slack-node
  slack.set-webhook olio.config.slack.hook

module.exports = (next) ->*
  @slack = ->
    if olio.config.slack?name
      slack.webhook {
        username: olio.config.slack.name
        channel: olio.config.slack.channel
        text: it
      }, (error, response) ->
  yield next
