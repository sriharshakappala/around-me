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
      description: 'The type of notification that should be used to display the strategies. (Default: Info)'
      type: 'string',
      default: 'Info',
      enum: ['Success', 'Info', 'Warning', 'Error']

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'around-me:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'around-me:show': => @show()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
    aroundMeViewState: @aroundMeView.serialize()

  toggle: ->
    @enabled = !@enabled
    if @enabled
      atom.notifications.addInfo('Oblique Strategies: Enabled', { dismissable: false });
    else
      atom.notifications.addInfo('Oblique Strategies: Disabled', { dismissable: false });
