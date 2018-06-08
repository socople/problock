app.factory('GalleryCollection', [
  '$resource',
  function ($resource) {
    return $resource('../../images/:imageable_type/:imageable_id',
      { imageable_type: '@imageable_type', imageable_id: '@imageable_id' },
      { get: { isArray: true } }
    )
  }
])

app.factory('GallerySort', [
  '$resource',
  function ($resource) {
    return $resource('../../images/sort', {}, { update: { method: 'PUT' } })
  }
])

app.factory('ImageDestroy', [
  '$resource',
  function ($resource) {
    return $resource('../../images/:id', { id: '@id' },
    { destroy: { method: 'DELETE' } })
  }
])

app.controller('galleryController', [
  '$scope',
  'GalleryCollection',
  'GallerySort',
  'ImageDestroy',
  'Upload',
  'Toast',
  '$timeout',
  function ($scope, GalleryCollection, GallerySort, ImageDestroy, Upload, Toast, $timeout) {
    //
    $scope.description = ''
    $scope.id = ''
    $scope.require_image = true
    $scope.image_url = ''
    $scope.errors = ''

    $scope.showForm = function (form) {
      $scope.showing_form = form
    }

    $scope.hideForms = function ($event) {
      $event.preventDefault()
      $scope.clearData()
      $scope.showing_form = ''
    }

    $scope.clearData = function () {
      $scope.id = ''
      $scope.image_url = ''
      $scope.description = ''
      $scope.file = null
      $scope.require_image = true
    }

    $scope.showingForm = function (form) {
      return $scope.showing_form === form
    }

    $scope.editImage = function (id) {
      var index = $scope.images.map(function (o) { return o.id }).indexOf(id)
      $scope.id = id

      $scope.errors = ''
      $scope.description = $scope.images[index].description
      $scope.image_url = $scope.images[index].image_urls.small
      $scope.file = $scope.images[index].image_urls.original
      $scope.require_image = false
      $scope.showForm('edit')
    }

    $scope.updatePriorities = function () {
      var priorities = {}
      angular.forEach($scope.images, function (image, index) {
        priorities[image.id] = index
      })
      GallerySort.update({ priorities: priorities })
    }

    $scope.dragControlListeners = {
      orderChanged: function (event) {
        $scope.updatePriorities()
      },
      clone: false,
      allowDuplicates: false
    }

    $scope.delete = function (id) {
      if (confirm('¿Está seguro?')) {
        ImageDestroy.destroy({ id: id }, function () {
          Toast.flash('Imagen eliminada correctamente', 3000)
          var index = $scope.images.map(function (o) { return o.id }).indexOf(id)
          $scope.images.splice(index, 1)
        })
      }
    }

    $scope.fetchImages = function () {
      $scope.items = GalleryCollection.get({
        imageable_type: $scope.imageable_type,
        imageable_id: $scope.imageable_id
      },
      function (result) {
        $scope.images = result
      })
    }

    $scope.resetForm = function () {
      var forms = document.querySelectorAll('.new_image')
      for (var i = 0; i < forms.length; i++) {
        forms[i].reset()
      }
    }

    $scope.disabledForm = function (bool) {
      var btns = document.querySelectorAll('button')
      for (var i = 0; i < btns.length; i++) {
        btns[i].disabled = bool
      }
    }

    $scope.uploadPic = function (e, file) {
      e.preventDefault()
      $scope.errors = ''
      $scope.disabledForm(true)

      file.upload = Upload.upload({
        url: ($scope.id !== '' ? ('../../images/' + $scope.id) : '../../images'),
        method: ($scope.id !== '' ? 'PUT' : 'POST'),
        data: {
          id: $scope.id,
          imageable_type: $scope.imageable_type,
          imageable_id: $scope.imageable_id,
          description: $scope.description,
          image: file
        },
        formDataAppender: function (fd, key, val) {
          if (angular.isArray(val)) {
            angular.forEach(val, function (v) {
              fd.append('image[' + key + ']', v)
            })
          } else {
            fd.append('image[' + key + ']', val)
          }
        }
      })
      .then(
        function (response) {
          $timeout(function () {
            if ($scope.id !== '') {
              var index = $scope.images.map(function (o) { return o.id }).indexOf($scope.id)
              $scope.images[index] = response.data
            } else {
              $scope.images.push(response.data)
              $scope.updatePriorities()
            }

            Toast.flash('Imagen cargada correctamente', 3000)
            $scope.clearData()
            $scope.showing_form = ''
            $scope.resetForm()
            $scope.disabledForm(false)
          })
        },
        function (response) {
          if (response.status > 0) {
            $scope.errors = response.data
            $scope.disabledForm(false)
          }
        },
        function (evt) {
          file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total))
        }
      )
    }
  }
])
