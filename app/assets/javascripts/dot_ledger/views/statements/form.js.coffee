DotLedger.module 'Views.Statements', ->
  class @Form extends Backbone.Marionette.ItemView
    template: 'statements/form'

    ui:
      file: 'input[name=file]'
      button: 'button'

    events:
      'click button.save': 'save'
      'submit form': 'save'

    onRender: ->
      new DotLedger.Helpers.FormErrors(@model, @$el)

    templateHelpers: ->
      accountName: @options.account.get('name')
      accountId: @options.account.get('id')

    save: ->
      @ui.button.button('loading')

      # FIXME: this is a bit hacky

      data = new FormData()
      files = @ui.file[0].files
      if files.length > 0
        data.append('file', files[0])
      data.append('account_id', @options.account.get('id'))

      Pace.track =>
        $.ajax
          url: '/api/statements'
          data: data
          cache: false
          contentType: false
          processData: false
          type: 'POST'
          success: =>
            @trigger 'save'
            @ui.button.button('reset')
          error: (resp)=>
            if resp.status == 422
              @ui.button.button('reset')
              errors = JSON.parse(resp.responseText).errors
              @model.validationError = errors
              @model.trigger "invalid", @model, errors, {validationError: errors}

      false
