AroundMeView = require './around-me-view'
{CompositeDisposable} = require 'atom'

module.exports = AroundMe =
  aroundMeView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @aroundMeView = new AroundMeView(state.aroundMeViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @aroundMeView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'around-me:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @aroundMeView.destroy()

  serialize: ->
    aroundMeViewState: @aroundMeView.serialize()

  toggle: ->
    console.log 'AroundMe was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
