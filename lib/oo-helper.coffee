OoHelperView = require './oo-helper-view'
{CompositeDisposable} = require 'atom'

DOMListener = require 'dom-listener'
OoHelperView = require './oo-helper-view'

# add a capitilization method to string class
String::capitalize = ->
  @substr(0, 1).toUpperCase() + @substr(1)

module.exports = OoHelper =
  config:
    createVirtualDestructor:
      type: 'boolean'
      default: false
    createCopyConstructor:
      type: 'boolean'
      default: true
    createAssignmentOperator:
      type: 'boolean'
      default: true

  ooHelperView: null
  modalPanel: null
  subscriptions: null
  listener: null
  classDotCpp:null
  classDotH:null
  bracket:null
  # parameters
  virtualDestructor: null
  copyConstructor: null
  assignmentOperator: null # lame that it doesnt take a bool
  parentClass: null
  activate: (state) ->
    #@ooHelperView = new OoHelperView(state.ooHelperViewState)
    #console.log (state.ooHelperViewState)
    #console.log("state: " + state)
    unless state?
      console.log "stat undefined. creating.."
      state={}
    unless state.ooHelperViewState?
      console.log "state.ooHelperViewState undefined. creating..."
      console.log state
      state.ooHelperViewState = {}
      state.ooHelperViewState.assignmentOperatorChecked = atom.config.get('oo-helper.createAssignmentOperator')
      @assignmentOperator = @setCheckboxState.call(@,state.ooHelperViewState.assignmentOperatorChecked)

      state.ooHelperViewState.parentClassChecked = atom.config.get('oo-helper.createParentClass')
      @parentClass = @setCheckboxState.call(@, state.ooHelperViewState.parentClassChecked)

      state.ooHelperViewState.virtualDestructorChecked = atom.config.get('oo-helper.createVirtualDestructor')
      @virtualDestructor = @setCheckboxState.call(@, state.ooHelperViewState.virtualDestructorChecked)

      state.ooHelperViewState.copyConstructorChecked = atom.config.get('oo-helper.createCopyConstructor')
      @copyConstructor = @setCheckboxState.call(@, state.ooHelperViewState.copyConstructorChecked)

    console.log("calling new OoHelperView with state")
    console.log state.ooHelperViewState
    @ooHelperView = new OoHelperView(state.ooHelperViewState)
    #@modalPanel = atom.workspace.addModalPanel(item: @ooHelperView.getElement(), visible: false)
    @modalPanel = atom.workspace.addModalPanel(item: @ooHelperView, visible: false)
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @listener = new DOMListener(document.querySelector('.oo-helper-container'))
    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'oo-helper:toggle': => @toggle()
    # Register listeners
    @listener.add '.oo-helper-button', 'click', (event) =>
      console.log "classname " + @ooHelperView.getClassname()
      @createClass.call(@,@ooHelperView.getClassname())
    @listener.add '.oo-helper-checkbox', 'click', @checkboxClicked.bind(@)
    @listener.add '.oo-helper-input', 'keypress', (event) => @validateInput event, true

  checkboxClicked: (event) ->
    #console.log event.target.id + " clicked: " + event.target.checked
    #console.log event.target
    #console.log @
    switch event.target.id
      when 'oohelper-addCopyConstructor' then @copyConstructor = @setCheckboxState(event.target.checked)
      when 'oohelper-addAssignmentOperator' then @assignmentOperator = @setCheckboxState(event.target.checked)
      when 'oohelper-useParentClass' then @parentClass = @setCheckboxState(event.target.checked)
      when 'oohelper-virtualDestructor' then @virtualDestructor = @setCheckboxState(event.target.checked)

  setCheckboxState: (bool) ->
    ret = if bool then "yes" else  null

  createClass: (classname) ->
    console.log "createclass called with classname:" + classname
    path = require('path')
    fs = require "fs"
    unless @classDotCpp?
      @bracket = require('bracket-templates')
      cdcpp = path.join(__dirname, "../etc/classDotCPP.txt")
      cdh = path.join(__dirname,"../etc/classDotH.txt")

      @classDotCpp = fs.readFileSync(cdcpp)
      @classDotH = fs.readFileSync(cdh)
    data =
      name: classname.capitalize()
      virtualDestructor: @virtualDestructor
      copyConstructor: @copyConstructor
      assignmentOperator: @assignmentOperator
    console.log "data"
    console.log data
    # get directories
    paths = atom.project.getPaths()
    if paths.length > 0
      # contstruct paths to header and cpp files
      newClassDotCpp = path.join(paths[0], classname + ".cpp")
      newClassDotH = path.join(paths[0], classname + ".h")
      # test for existance and create if they don't exist
      unless fs.existsSync(newClassDotCpp)
        fs.writeFileSync(newClassDotCpp, @.bracket.render(String(@classDotCpp), data ) )
      unless fs.existsSync(newClassDotH)
        fs.writeFileSync(newClassDotH, @bracket.render(String(@classDotH), data ) )
      @toggle()

  validateInput: (evt) =>
    evt = evt or window.event5
    keyCode = evt.keyCode or evt.which;7
    if ' ' == String.fromCharCode(keyCode)
      evt.preventDefault()
    else
      num = parseInt( String.fromCharCode(keyCode), 10)
      evt.preventDefault() unless isNaN num

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @uiTestView.destroy()
    @listener.dispose()

  serialize: ->
    ooHelperViewState: @ooHelperView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
