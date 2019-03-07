directionsService = null
directionsDisplay = null
startpoint = null
defaultend = null
showMapExample = true

@initQuotationMap = ->
  divid = 'quotation-map'

  if document.getElementById(divid)

    startpoint = new google.maps.LatLng(13.430697, -88.112297)
    defaultend = new google.maps.LatLng(13.4785149, -88.2041086)

    map = new google.maps.Map(document.getElementById(divid), {
      center: startpoint,
      zoom: 15,
      scrollwheel: false,
      mapTypeId: 'hybrid'
    })

    geocoder = new google.maps.Geocoder()

    document.getElementById('quotation_address').onkeypress = (e) ->
      code = if e.keyCode then e.keyCode else e.which
      if code == 13
        e.preventDefault()
        geocodeAddress(geocoder, map)
        showExample()
        window.location.hash = 'quotation-map'

    document.getElementById('quotation_address').addEventListener 'blur', ->
      geocodeAddress(geocoder, map)
      showExample()
      window.location.hash = 'quotation-map'

    directionsService = new google.maps.DirectionsService
    directionsDisplay = new google.maps.DirectionsRenderer({
      draggable: true,
      map: map
    })

    directionsDisplay.addListener 'directions_changed', ->
      computeTotalDistance(directionsDisplay.getDirections())

@showExample = ->
  if showMapExample && document.getElementById('move-b-example')
    document.getElementById('move-b-example').style.display = 'block'
    showMapExample = false

@geocodeAddress = (geocoder, resultsMap) ->
  address = document.getElementById('quotation_address').value
  return if address == ''

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
    region: 'https://maps.google.com.sv/'
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
  hideOrShowAddLink = ->
    if $('#quotation-items .nested-fields:visible').length <= 1
      $('#quotation-items .remove').hide()
    else
      $('#quotation-items .remove').show()

  $('#quotation-items').on 'cocoon:after-insert', hideOrShowAddLink
  $('#quotation-items').on 'cocoon:after-remove', hideOrShowAddLink

  if $('#quotation-items .nested-fields:visible').length == 0
    $('.add-product').trigger 'click'
