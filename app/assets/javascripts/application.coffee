#= require jquery
#= require jquery_ujs
#= require jquery.slick
# require sharer

#-- Uncomment (add "=" after "#") to use photoswipe --
#
# require photoswipe
# require photoswipe-ui-default
# require photoswipe-init

$ ->

  slider = $('.slider').slick
    arrows: false

  $('.slick-prev').on 'click', (e) ->
    e.preventDefault()
    slider.slick('slickPrev')

  $('.slick-next').on 'click', (e) ->
    e.preventDefault()
    slider.slick('slickNext')

  slider.on 'beforeChange', (slick, currentSlide, prevSlide, nextSlide) ->
    $('.background').fadeOut()
    bg = $("[data-slick-index=#{nextSlide}]").find('.panel').data('slide')
    $("[data-background=#{bg}]").fadeIn()
