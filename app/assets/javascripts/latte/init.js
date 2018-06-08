var angular = angular || null
var moment  = moment  || null

moment.locale('es')

var app = angular.module('latte', [
  'ngTable',
  'ngResource',
  'ngAnimate',
  'checklist-model',
  'mightyDatepicker',
  'ngHandsontable',
  'ngFileUpload',
  'as.sortable'
])

app.factory('Toast', ['$timeout', function ($timeout) {
  var template = document.createElement('div')
  var body = document.querySelector('body')

  template.classList.add('toast')
  template.style.transition = 'all .25s linear'

  return {
    flash: function (text, duration) {
      template.style.opacity = 0
      template.innerText = text
      body.appendChild(template)

      $timeout(
        function () { template.style.opacity = 1 },
        100
      )
      .then(function () {
        $timeout(
          function () { template.style.opacity = 0 },
          duration
        )
        .then(function () {
          $timeout(
            function () { template.parentNode.removeChild(template) },
            250
          )
        })
      })
    }
  }
}])
