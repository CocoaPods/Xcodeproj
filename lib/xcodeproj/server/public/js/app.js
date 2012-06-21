var App, Node;

App = Em.Application.create();

Node = Ember.Resource.extend({
  resourceUrl: '/nodes',
  name: null,
  type: null,
  parents: (function() {
    var result;
    result = [];
    if (this.parent) {
      if (this.parent.get('parent')) result.pushObject(this.parent.get('parent'));
      result.pushObject(this.parent);
    }
    result.compact;
    return result;
  }).property('parent')
});

App.node_cache = new Ember.Set();

App.node_for_id = function(id, parent) {
  var node;
  node = App.node_cache.findProperty('id', id);
  if (!node) {
    node = Node.create({
      id: id
    });
    node.findResource();
    node.set('parent', parent);
    App.node_cache.add(node);
  }
  return node;
};

App.set('targets', Ember.ResourceController.create({
  resourceType: Node,
  resourceUrl: '/targets'
}));

App.controller = Ember.Object.create({
  selectedNode: null,
  selectedTarget: null,
  editorView: (function() {
    var node, r;
    if (!this.selectedNode) return null;
    console.log(this.selectedNode.id);
    node = Node.create({
      id: this.selectedNode.id
    });
    node.findResource().fail(function(e) {
      return console.log('FUNDE RRO');
    });
    console.log(this.selectedNode);
    console.log(Node);
    console.log(node);
    console.log(node.id);
    console.log(node.get('name'));
    console.log(node.type);
    r = (function() {
      switch (node.type) {
        case 'Group':
          return App.GroupView.create();
        case 'File':
          return App.FileView.create();
        case 'BuildSettings':
          return App.BuildSettings.create();
        default:
          return null;
      }
    })();
    console.log(r);
    return r;
  }).property('selectedNode'),
  editorNode: (function() {
    if (!this.selectedNode) return null;
    return App.node_for_id(this.selectedNode.get('id'));
  }).property('selectedNode'),
  currentNavigation: (function() {
    var r;
    r = this.navigationStack.content[this.navigationStack.content.length - 1];
    return r;
  }).property('navigationStack.content'),
  navigationStack: Ember.ArrayController.create()
});

App.NodeView = Ember.View.extend({
  tagName: 'li',
  classNameBindings: ['active'],
  click: function(event) {
    var selection;
    selection = this.get('content');
    if (!(selection instanceof Node)) {
      selection = App.node_for_id(selection.id, App.controller.get('selectedNode'));
    }
    App.controller.set('selectedNode', selection);
    return false;
  },
  touchEnd: function() {
    return this.click();
  },
  active: (function() {
    return App.controller.get('selectedNode') === this.get('content');
  }).property('App.controller.selectedNode')
});

App.NodeRowView = App.NodeView.extend({
  tagName: 'tr'
});

App.IconView = Ember.View.extend({
  tagName: 'i',
  classNameBindings: ['type', 'icon-white'],
  type: (function() {
    switch (this.getPath('content.type')) {
      case 'Group':
        if (App.controller.get('selectedNode') === this.get('content')) {
          return 'icon-folder-open';
        } else {
          return 'icon-folder-close';
        }
        break;
      case 'File':
        return 'icon-file';
      case 'Framework':
        return 'icon-book';
      default:
        return 'icon-question-sign';
    }
  }).property('App.controller.selectedNode.type'),
  'icon-white': (function() {
    return App.controller.get('selectedNode') === this.get('content');
  }).property('App.controller.selectedNode.type')
});

App.ProjectNavigator = Ember.CollectionView.extend({
  tagName: 'ul',
  classNames: ['nav', 'nav-list'],
  itemViewClass: App.NodeView,
  emptyView: Ember.View.extend({
    template: Ember.Handlebars.compile("Loading...")
  })
});

App.GroupView = Ember.View.extend({
  templateName: 'group-view'
});

App.BreadcrumbView = Ember.View.extend({
  templateName: 'breadcrumb-view'
});

App.project = Ember.ResourceController.create({
  resourceType: Node,
  resourceUrl: '/'
});

App.project.findAll().done(function() {
  App.controller.navigationStack.addObject(App.project.content);
  return App.controller.set('selectedNode', App.project.content[0]);
});

App.get('targets').findAll().done(function() {
  return App.controller.set('selectedTarget', App.targets.content[0]);
});
