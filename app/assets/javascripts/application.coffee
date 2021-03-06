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

  if $('#q1').length > 0
    history.pushState(null, null, '')
    window.addEventListener 'popstate', (event) ->
      window.location.assign("/quotations/new?o=#{$('#q1').data('id')}")

  if $('#q2').length > 0
    history.pushState(null, null, '')
    window.addEventListener 'popstate', (event) ->
      window.location.assign("/quotations/#{$('#q2').data('id')}/edit")

  if $('#q3').length > 0
    history.pushState(null, null, '')
    window.addEventListener 'popstate', (event) ->
      window.location.assign("/quotations/#{$('#q3').data('id')}")

  $('#q2 form').on 'submit', (e) ->
    unless confirm('Enviará la información necesaria para que podamos procesar su solicitud\n¿Desea continuar?')
      e.preventDefault()

  $('#trucks').on 'cocoon:after-insert', (e, insertedItem) ->
    item = $(insertedItem)
    item.find('.truck').hqyDroppable droppableProps

    item.find('.date-select-container').hide()
    item.find('[type=radio]:first').prop('checked', true)
    item.find('[type=radio]').on 'change', ->
      container = $(this).closest('.truck').find('.date-select-container')
      if $(this).val() == 'false'
        container.fadeIn()
      else
        container.fadeOut()

    checkEmpty()
    placeTruckCounter()

  $('#trucks').on 'cocoon:before-remove', (e, itemToRemove) ->
    message = 'Eliminará el camión y todos los productos en él\n¿Está seguro?'
    if $(e.target).hasClass('products-list')
      message = 'Eliminará este producto del camión\n¿Está seguro?'
    if !confirm(message)
      e.preventDefault()
    else
      if itemToRemove.find('.dynamic').length > 0
        itemToRemove.find("[name*='_destroy']").val('1')
        itemToRemove
          .find('.truck-item')
          .hide()
          .appendTo(itemToRemove.parent())

  $('#trucks').on 'cocoon:after-remove', ->
    checkOverloaded()
    checkEmpty()
    placeTruckCounter()

  $('.truck-item .change').on 'click', (e) ->
    e.preventDefault()
    changeQuantity($(this))

  changeQuantity = (truck_item) ->
    item  = truck_item.closest('.truck-item')
    input = item.find('.quantity')
    elemt = item.find('span')
    current_quantity = input.val()

    new_quantity = prompt('Ingrese la nueva cantidad', current_quantity)
    return if new_quantity == null

    if (parseInt(new_quantity) + '') != new_quantity || new_quantity < 1
      alert 'No se cambió la cantidad porque debe introducir un número entero mayor que cero'
      return

    new_percent = parseFloat(item.data('percent')) /
                  parseInt(current_quantity) *
                  parseInt(new_quantity)

    new_percent = Math.round(new_percent * 10000) / 10000

    item.data('percent', new_percent)
    item.attr('data-percent', new_percent)
    input.val(new_quantity)
    elemt.text(new_quantity)
    checkOverloaded()
    checkEmpty()

  placeTruckCounter = ->
    counter = 0
    $.each $('.truck:visible'), (_, truck) ->
      counter++
      $(this).find('.truck-counter').text(counter)

  placeTruckCounter()

  checkEmpty = ->
    setTimeout (->
      $('.truck').removeClass('empty')
      $.each $('.truck'), (_, truck) ->
        if $(truck).find('.truck-item:visible').length == 0
          $(truck).addClass('empty')
    ), 100

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

  cloneTruckItem = (org) ->

    truck = org.closest('.truck')
    item  = org.clone()
    elemt = item.find('span')
    quantity_input     = item.find('.quantity')
    current_quantity   = quantity_input.val()
    suggested_quantity = Math.floor(parseFloat(current_quantity) / 2)

    new_quantity = prompt('¿Cuántas unidades desea dividir?', suggested_quantity)
    return if new_quantity == null

    if (parseInt(new_quantity) + '') != new_quantity || new_quantity < 1
      alert 'Debe introducir un número entero mayor que cero'
      return
    else if parseInt(current_quantity) <= new_quantity
      alert "Debe introducir un número menor que #{current_quantity}"
      return

    reference_input = truck.find('[name$="[_destroy]"]').not('[name*=truck_quotation_products_attributes]')
    truck_index     = reference_input.attr('name').match(/\[trucks_attributes\]\[(.*?)\]\[/)[1]
    item_index      = new Date().getTime()

    item.find("[name*='[id]']").remove()

    setNameFor(item, truck_index, item_index, 'truck_id')
    setNameFor(item, truck_index, item_index, 'quotation_product_id')
    setNameFor(item, truck_index, item_index, 'quantity')
    setNameFor(item, truck_index, item_index, '_destroy')

    setQuantityAndPercent(org, (parseInt(current_quantity) - parseInt(new_quantity)))
    setQuantityAndPercent(item, new_quantity)

    org.after(item)
    item.hqyDraggable draggableProps

    item.find('.change').on 'click', (e) ->
      e.preventDefault()
      changeQuantity($(this))

    item.find('.split').on 'click', (e) ->
      e.preventDefault()
      cloneTruckItem(item)

  $('.split').on 'click', (e) ->
    e.preventDefault()
    cloneTruckItem($(this).closest('.truck-item'))

  setQuantityAndPercent = (truck_item, new_quantity) ->
    input            = truck_item.find('.quantity')
    elemt            = truck_item.find('span')
    current_quantity = input.val()
    new_percent      = parseFloat(truck_item.data('percent')) /
                       parseInt(current_quantity) *
                       parseInt(new_quantity)

    new_percent = Math.round(new_percent * 10000) / 10000

    truck_item.data('percent', new_percent)
    truck_item.attr('data-percent', new_percent)
    input.val(new_quantity)
    elemt.text(new_quantity)

  setTruckIds = (item) ->
    setTimeout (->
      item = $(item)
      truck = item.closest('.truck')
      reference_input = truck.find('[name$="[_destroy]"]').not('[name*=truck_quotation_products_attributes]')
      truck_index     = reference_input.attr('name').match(/\[trucks_attributes\]\[(.*?)\]\[/)[1]
      item_index      = new Date().getTime()

      item.find("[name*=truck_id]").val(truck.data('id'))

      if !truck.data('id')
        helper = truck.find('.op2')

        helper.find("[name*=_destroy]").val("1")
        helper.removeClass('op2')

        item.find("[name*='[id]']").remove()

        setNameFor(item, truck_index, item_index, 'truck_id')
        setNameFor(item, truck_index, item_index, 'quotation_product_id')
        setNameFor(item, truck_index, item_index, 'quantity')
        setNameFor(item, truck_index, item_index, '_destroy')
      else
        truck.find('.op2').remove()
    ), 100

  setNameFor = (t, truck_index, item_index, field) ->
    name = "quotation[trucks_attributes][#{truck_index}][truck_quotation_products_attributes][#{item_index}][#{field}]"
    t.find("[name*='[#{field}]']").attr('name', name)

  $('.date-select-container').hide()
  $('.truck [type=radio]').on 'change', ->
    container = $(this).closest('.truck').find('.date-select-container')
    if $(this).val() == 'false'
      container.fadeIn()
    else
      container.fadeOut()
  $('.truck [type=radio]:checked').trigger 'change'

  $ph = aixsY = null

  draggableProps = {
    proxy: 'clone'
    onStartDrag: (event, target) ->
      $(target).width($(this).width())

      $ph = $(this).clone()
      $ph.addClass('op2')
      $(this).hide().before($ph)

    onStopDrag: ->
      $ph.after(this)
      $ph.hide()
      $ph = null
      $(this).show()
      setTruckIds(this)
      checkOverloaded()
      checkEmpty()
  }

  droppableProps = {
    onDragEnter: (event, target) ->
      $(this).find('.products-list').append($ph)
  }

  $('.truck-item').hqyDraggable draggableProps
  $('.truck').hqyDroppable droppableProps

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
  
    $('[data-open]').on 'click', (e) ->
    e.preventDefault()


  $('[data-open]').on 'click', (e) ->
    e.preventDefault()
    $("[data-overlay='#{$(this).data('open')}']").fadeIn()

  $('[data-close]').on 'click', (e) ->
    e.preventDefault()
    $("[data-overlay='#{$(this).data('close')}']").fadeOut()

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
