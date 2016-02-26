{CompositeDisposable} = require 'atom'

module.exports = AroundMe =
  subscriptions: null
  enabled: false

  config:
    enableOnLoad:
      title: 'Enable on load',
      description: 'Should this package activate itself when Atom loads? (Default: checked)'
      type: 'boolean'
      default: true
    isNewsSticky:
      title: 'Sticky news',
      description: 'Should news hang around (checked) or dismiss themselves (unchecked)? (Default: unchecked)'
      type: 'boolean'
      default: true
    notificationType:
      title: 'Notification Type',
      description: 'The type of notification that should be used to display the news. (Default: Info)'
      type: 'string',
      default: 'Info',
      enum: ['Success', 'Info', 'Warning', 'Error']
    newsDisplayFrequency:
      title: 'Display Frequency'
      description: 'How frequently (in seconds) should this package should display a news item? (Default: 60)'
      type: 'integer'
      default: 60
      minimum: 60

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'around-me:mashable': => @mashable()

  deactivate: ->
    @subscriptions.dispose()

  show: ->
    atom.notifications.addInfo('Not defined yet!', { dismissable: true });

  mashable: ->
    request = require('request')
    FeedParser = require('feedparser')
    req = request('http://feeds.mashable.com/Mashable?format=xml')
    feedparser = new FeedParser()
    items = []
    addFn = 'add' + atom.config.get('around-me.notificationType')
    display_delay = atom.config.get('around-me.newsDisplayFrequency') * 1000
    req.on 'error', (error) ->
      console.log('Oops, Something was wrong!')
      return
    req.on 'response', (res) ->
      stream = this
      if res.statusCode != 200
        return @emit('error', new Error('Bad status code'))
      stream.pipe feedparser
      return
    feedparser.on 'error', (error) ->
      console.log('Oops, Something was wrong!')
      return
    feedparser.on 'end', ->
      showNews = (news_array) ->
        atom.notifications.addInfo(news_array.pop(), { dismissable: true });
        if news_array.length > 0
          setTimeout (news_array) ->
            showNews(news_array)
          ,display_delay
          ,news_array
      showNews(items)
    feedparser.on 'readable', ->
      stream = this
      meta = @meta
      item = undefined
      while item = stream.read()
        items.push("<a href=" + item['origlink'] + ">" + item['title'] + "</a>")
      return
