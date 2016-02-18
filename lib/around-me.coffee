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
      default: false
    notificationType:
      title: 'Notification Type',
      description: 'The type of notification that should be used to display the news. (Default: Info)'
      type: 'string',
      default: 'Info',
      enum: ['Success', 'Info', 'Warning', 'Error']
    newsFetchFrequency:
      title: 'Fetch Frequency'
      description: 'How frequently (in minutes) should this package fetch news from the sources? (Default: 60)'
      type: 'integer'
      default: 60
      minimum: 30
    newsDisplayFrequency:
      title: 'Display Frequency'
      description: 'How frequently (in seconds) should this package fetch news from the sources? (Default: 60)'
      type: 'integer'
      default: 60
      minimum: 30

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'around-me:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'around-me:show': => @show()

  deactivate: ->
    @subscriptions.dispose()

  show: ->
    atom.notifications.addInfo('Not defined yet!', { dismissable: true });

  fetchNews: ->
    request = require('request')
    FeedParser = require('feedparser')
    req = request('http://feeds.mashable.com/Mashable?format=xml')
    feedparser = new FeedParser()
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
    feedparser.on 'readable', ->
      stream = this
      meta = @meta
      item = undefined
      addFn = 'add' + atom.config.get('around-me.notificationType')
      while item = stream.read()
        atom.notifications[addFn](item['title'], { dismissable: atom.config.get('around-me.isNewsSticky') });
      return

  toggle: ->
    @enabled = !@enabled
    if @enabled
      atom.notifications.addInfo('Around Me: Enabled', { dismissable: false });
      @fetchNews()
    else
      atom.notifications.addInfo('Around Me: Disabled', { dismissable: false });
