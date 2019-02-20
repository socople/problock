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

  $ph = aixsY = null
  $('.draggable').hqyDraggable
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

  $('.droppable').hqyDroppable
  	onDragEnter: (event, target) ->
  		$(this).append($ph)


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
