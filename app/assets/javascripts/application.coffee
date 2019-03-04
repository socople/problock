#= require jquery
#= require jquery_ujs
#= require jquery.slick
# require sharer
#= require cocoon
#= require hqy.interact
#= require quotation

#-- Uncomment (add "=" after "#") to use photoswipe --
#
# require photoswipe
# require photoswipe-ui-default
# require photoswipe-init

$ ->

  $('.truck-item .delete').on 'click', (e) ->
    e.preventDefault()

    if confirm('¿Está seguro?')
      item = $(this).closest('.truck-item')
      item.find('.destroy').val("1")
      item.fadeOut 'fast', ->
        checkOverloaded()

  $('.truck-item .change').on 'click', (e) ->
    e.preventDefault()

    item = $(this).closest('.truck-item')
    input = item.find('.quantity')
    elemt = item.find('span')
    current_quantity = input.val()

    new_quantity = prompt('Ingrese la nueva cantidad', current_quantity)
    if new_quantity == null || (parseInt(new_quantity) + '') != new_quantity || new_quantity < 1
      new_quantity = current_quantity
      alert 'No se cambió la cantidad porque debe introducir un número entero mayor que cero'

    new_percent = parseFloat(item.data('percent')) /
                  parseInt(current_quantity) *
                  parseInt(new_quantity)

    new_percent = Math.round(new_percent * 10000) / 10000

    item.data('percent', new_percent)
    item.attr('data-percent', new_percent)
    input.val(new_quantity)
    elemt.text(new_quantity)
    checkOverloaded()

  checkOverloaded = ->
    setTimeout (->
      $('.truck').removeClass('overloaded')
      $('.edit_quotation .btn')
        .removeClass('disabled')
        .attr('disabled', false)
      $.each $('.truck'), (_, truck) ->
        count = 0
        $.each $(truck).find('.truck-item:visible'), (_, item) ->
          count = count + parseFloat($(item).data('percent'))
        if count > 100
          $(truck).addClass('overloaded')
          $('.edit_quotation .btn')
            .addClass('disabled')
            .attr('disabled', true)
    ), 100

  setTruckIds = ->
    setTimeout (->
      $.each $('.truck'), (_, truck) ->
        $(truck).find("[name*=truck_id]").val($(this).data('id'))
    ), 100

  $('.date-select-container').hide()
  $('.truck [type=radio]').on 'change', ->
    container = $(this).closest('.truck').find('.date-select-container')
    if $(this).val() == '0'
      container.fadeIn()
    else
      container.fadeOut()

  $ph = aixsY = null
  $('.truck-item').hqyDraggable
    proxy: 'clone'
    onStartDrag: (event, target) ->
      $(target).width($(this).width())

      $ph = $(this).clone()
      $ph.addClass('op2')
      $(this).hide().before($ph)

    onStopDrag: ->
      $ph.after(this)
      $ph.remove()
      $ph = null
      $(this).show()
      setTruckIds()
      checkOverloaded()

  $('.truck').hqyDroppable
    onDragEnter: (event, target) ->
      $(this).find('.products-list').append($ph)


  $('.slider').each (_, s) ->

    $(s).slick
      arrows: false

    $(s).closest('.panels').find('.slick-prev').on 'click', (e) ->
      e.preventDefault()
      $(s).slick('slickPrev')

    $(s).closest('.panels').find('.slick-next').on 'click', (e) ->
      e.preventDefault()
      $(s).slick('slickNext')

    $(s).on 'beforeChange', (slick, currentSlide, prevSlide, nextSlide) ->
      $(s).closest('.container').find('.background').fadeOut()
      bg = $(s)
            .closest('.container')
            .find("[data-slick-index=#{nextSlide}]")
            .find('.slide')
            .data('slide')
      $("[data-background=#{bg}]").fadeIn()


  $('[data-open]').on 'click', (e) ->
    e.preventDefault()
    $('body').addClass('noscroll')
    o = $('[data-popup=' + $(this).data('open') + ']')
    o.fadeIn()
    o.find('.slider').slick('setPosition')

  $('[data-close]').on 'click', (e) ->
    e.preventDefault()
    $('body').removeClass('noscroll')
    $('[data-popup=' + $(this).data('close') + ']').fadeOut()

  $('[data-nav]').on 'click', (e) ->
    e.preventDefault()
    $('nav').fadeToggle 'fast', ->
      if $('nav').is(':visible')
        $('body').addClass('noscroll')
      else
        $('body').removeClass('noscroll')

@initMap = ->
  if document.getElementById("map")
    map = new google.maps.Map(document.getElementById("map"), {
      center: { lat: 13.430697, lng: -88.112297 },
      zoom: 15,
      scrollwheel: false
    })

    marker = new google.maps.Marker {
      position: { lat: 13.430697, lng: -88.112297 },
      map: map
    }

    infowindow = new google.maps.InfoWindow()
    infowindow.setContent("ProBlock")
    infowindow.open(map, marker)
