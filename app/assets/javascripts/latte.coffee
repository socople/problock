#= require jquery
#= require jquery_ujs
#= require jquery.tagify
#= require cocoon
#= require ckeditor/init
#= require angular
#= require angular-resource
#= require angular-animate
#= require ng-table
#= require checklist-model
#= require handsontable.full
#= require ngHandsontable
#= require moment-with-locales
#= require moment-range
#= require angular-mighty-datepicker
#= require ng-sortable
#= require ng-file-upload-shim
#= require ng-file-upload
#= require latte/init
#= require photoswipe
#= require photoswipe-ui-default
#= require photoswipe-init
#= require latte/app
#= require latte/habtm
#= require latte/gallery
#= require latte/attachments
#= require latte/external_videos

$ ->

  $('[data-fakepass]').attr('type', 'password')

  if $('.tagify').length > 0
    $.get '/latte/tags', (result) ->
      $('.tagify').tagify whitelist: result

  $('[data-toggable-from-select]').hide()
  $.each $('[data-toggable-from-select]'), (i, e) ->
    toggable = $(e)
    toggler  = $("##{toggable.data('toggler-id')}")
    hide_on  = $.map toggable.data('toggable-hide-on').split(','), (value) ->
      return value.replace(/ /g, '')

    toggler.on 'change', ->
      if $.inArray($(this).val(), hide_on) != -1
        toggable.hide()
      else
        toggable.show()
    toggler.trigger('change')


  $('[data-xhrpopup]').on 'ajax:complete', (event, xhr, settings) ->
    html = $(xhr.responseText).hide()
    $('body').append(html).addClass('overlayed')
    html.fadeIn 'fast'

    $('[data-close]').on 'click', (e) ->
      e.preventDefault()
      $(this).closest('.overlay').fadeOut 'fast', ->
        $(this).remove()
        $('.overlayed').removeClass('overlayed')


  $.each $('[data-tab]'), (i, t) ->
    $(t).on 'click', (e) ->
      e.preventDefault()

      $.each $('[data-tab]'), (j, x) ->
        $($(x).data('tab')).hide()

      $('[data-tab]').removeClass('active')
      $(this).addClass('active')
      $($(this).data('tab')).show()

    $($(t).data('tab')).hide() unless $(t).hasClass('active')
