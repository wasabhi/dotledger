DotLedger.module 'Views.Goals', ->
  class @List extends Backbone.Marionette.CompositeView
    template: 'goals/list'
    getChildView: -> DotLedger.Views.Goals.ListItem
    events:
      'click button.save-all': 'saveAll'
    templateHelpers: ->
      categoryTypes: =>
        types = _.uniq(@collection.pluck('category_type'))
        _.map types, (type)->
          label: type
          id: "category-type-#{_.string.underscored(type)}"

    attachHtml: (collectionView, childView, index)->
      list_id =  "category-type-#{_.string.underscored(childView.model.get('category_type'))}"
      collectionView.$("div##{list_id}").append(childView.el)

    saveAll: ->
      @children.call('save')
