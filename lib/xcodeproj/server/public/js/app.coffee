# The application

App = Em.Application.create()

# Models ######################################################################

# The base model for each node
Node = Ember.Resource.extend
  resourceUrl: '/nodes'
  name: null
  type: null
  parents: ( ->
    result = []
    if @parent
      result.pushObject(@parent.get('parent')) if @parent.get('parent')
      result.pushObject(@parent)
    result.compact
    result
  ).property('parent')

# Cache the nodes to avoid to require them on every requests
App.node_cache = new Ember.Set()

# Returns or creates a new node
App.node_for_id = (id, parent) ->
  node = App.node_cache.findProperty('id',id)
  unless node
    node = Node.create(id: id)
    node.findResource()
    node.set('parent', parent)
    App.node_cache.add(node)
  node

# Controllers #################################################################

# The targets of the project
App.set 'targets', Ember.ResourceController.create
  resourceType: Node
  resourceUrl:  '/targets'

# State

App.controller = Ember.Object.create
  selectedNode: null
  selectedTarget: null

  editorView: ( ->
    return null unless @selectedNode

    console.log @selectedNode.id
    node = Node.create(id: @selectedNode.id)
    node.findResource().fail (e) ->
        console.log 'FUNDE RRO'

    console.log @selectedNode
    console.log Node
    console.log node
    console.log node.id
    console.log(node.get('name'))
    console.log node.type

    r = switch node.type
      when 'Group'         then App.GroupView.create()
      when 'File'          then App.FileView.create()
      when 'BuildSettings' then App.BuildSettings.create()
      else null
    console.log r
    r
  ).property('selectedNode')

  editorNode: ( ->
    return null unless @selectedNode
    App.node_for_id(@selectedNode.get('id'))
  ).property('selectedNode')

  currentNavigation: (->
    r = @navigationStack.content[@navigationStack.content.length - 1]
    r
  ).property('navigationStack.content')


  navigationStack: Ember.ArrayController.create()

# Views #######################################################################

# ProjectNavigator

App.NodeView = Ember.View.extend
  tagName: 'li'
  classNameBindings: ['active']

  click: (event) ->
    selection = @get('content')
    selection = App.node_for_id(selection.id, App.controller.get('selectedNode')) unless selection instanceof Node
    App.controller.set('selectedNode', selection)
    false

  touchEnd: ->
    @click()

  active: ( ->
    App.controller.get('selectedNode') == @get('content')
    ).property('App.controller.selectedNode')

App.NodeRowView = App.NodeView.extend
  tagName: 'tr'

App.IconView = Ember.View.extend
  tagName: 'i'
  classNameBindings: ['type', 'icon-white']

  type: ( ->
    switch @getPath('content.type')
      when 'Group'
        if App.controller.get('selectedNode') == @get('content') then 'icon-folder-open' else 'icon-folder-close'
      when 'File'      then  'icon-file'
      when 'Framework' then  'icon-book'
      else 'icon-question-sign'
  ).property('App.controller.selectedNode.type')

  'icon-white': ( ->
    App.controller.get('selectedNode') == @get('content')
  ).property('App.controller.selectedNode.type')

App.ProjectNavigator = Ember.CollectionView.extend
  tagName:'ul'
  classNames: ['nav', 'nav-list']
  itemViewClass: App.NodeView
  emptyView: Ember.View.extend
      template: Ember.Handlebars.compile("Loading...")

# Editor

App.GroupView = Ember.View.extend
  templateName: 'group-view'

# BreadcrubView

App.BreadcrumbView = Ember.View.extend
  templateName: 'breadcrumb-view'

# GO


App.project = Ember.ResourceController.create
  resourceType: Node
  resourceUrl:  '/'

App.project.findAll().done ->
  App.controller.navigationStack.addObject(App.project.content)
  App.controller.set('selectedNode', App.project.content[0])

App.get('targets').findAll().done ->
  App.controller.set('selectedTarget', App.targets.content[0])


# editor = ace.edit("editor");
# editor.setTheme("ace/theme/solarized_dark")
# CScriptMode = require("ace/mode/c_cpp").Mode
# editor.getSession().setMode(new CScriptMode())
# editor.setShowPrintMargin(false)

# sample_code = jQuery.ajax(
#   url: 'files/F8E469B71395759C00DB05C8/raw',
#   dataType: 'text').done (data) =>
#     editor.getSession().getDocument().setValue(data)
