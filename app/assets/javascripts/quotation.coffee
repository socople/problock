directionsService = null
directionsDisplay = null
startpoint = null
defaultend = null

@initQuotationMap = ->
  divid = 'quotation-map'

  if document.getElementById(divid)

    startpoint = new google.maps.LatLng(13.430697, -88.112297)
    defaultend = new google.maps.LatLng(13.4785149, -88.2041086)

    map = new google.maps.Map(document.getElementById(divid), {
      center: startpoint,
      zoom: 15,
      scrollwheel: false
    })

    geocoder = new google.maps.Geocoder()
    document.getElementById('quotation_address').addEventListener 'blur', ->
      geocodeAddress(geocoder, map)

    directionsService = new google.maps.DirectionsService
    directionsDisplay = new google.maps.DirectionsRenderer({
      draggable: true,
      map: map
    })

    directionsDisplay.addListener 'directions_changed', ->
      computeTotalDistance(directionsDisplay.getDirections())

@geocodeAddress = (geocoder, resultsMap) ->
  address = document.getElementById('quotation_address').value
  return if address == ''

  document.getElementById('quotation-map-container').style.display = 'block'

  geocoder.geocode { 'address': address }, (results, status) ->
    if status == 'OK'
      displayRoute(startpoint, results[0].geometry.location, directionsService, directionsDisplay)
    else
      displayRoute(startpoint, defaultend, directionsService, directionsDisplay)

@displayRoute = (startpoint, destination, service, display) ->
  service.route {
    origin: startpoint,
    destination: destination,
    travelMode: 'DRIVING',
    avoidTolls: true
  }
  ,
  (response, status) ->
    if status == 'OK'
      display.setDirections(response)
    else
      alert('Could not display directions due to: ' + status);

@computeTotalDistance = (result) ->
  total = 0
  myroute = result.routes[0]

  for leg in myroute.legs
    total += leg.distance.value

  document.getElementById('quotation_distance').value = total

$ ->
  $('.add-product').trigger 'click'

  $('.date-select-container').hide()
  $('[type=radio]').on 'change', ->
    if $(this).val() == '0'
      $('.date-select-container').fadeIn()
    else
      $('.date-select-container').fadeOut()
