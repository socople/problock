app.factory('ExternalVideosCollection', [
  '$resource',
  function ($resource) {
    return $resource('../../external_videos/:external_videoable_type/:external_videoable_id',
      { external_videoable_type: '@external_videoable_type', external_videoable_id: '@external_videoable_id' },
      { get: { isArray: true } }
    )
  }
])

app.factory('ExternalVideosSort', [
  '$resource',
  function ($resource) {
    return $resource('../../external_videos/sort', {}, { update: { method: 'PUT' } })
  }
])

app.factory('ExternalVideoDestroy', [
  '$resource',
  function ($resource) {
    return $resource('../../external_videos/:id', { id: '@id' },
    { destroy: { method: 'DELETE' } })
  }
])

app.factory('ExternalVideoUpdate', [
  '$resource',
  function ($resource) {
    return $resource('../../external_videos/:id', { id: '@id' }, {
      update: { method: 'PUT' }
    })
  }
])

app.factory('ExternalVideoCreate', [
  '$resource',
  function ($resource) {
    return $resource('../../external_videos', {}, {
      create: { method: 'POST' }
    })
  }
])

app.controller('externalVideosController', [
  '$scope',
  'ExternalVideosCollection',
  'ExternalVideosSort',
  'ExternalVideoCreate',
  'ExternalVideoUpdate',
  'ExternalVideoDestroy',
  'Toast',
  function ($scope, ExternalVideosCollection, ExternalVideosSort, ExternalVideoCreate, ExternalVideoUpdate, ExternalVideoDestroy, Toast) {
    //
    $scope.id = ''
    $scope.name = ''
    $scope.description = ''
    $scope.url = ''
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
      $scope.name = ''
      $scope.description = ''
      $scope.url = ''
    }

    $scope.showingForm = function (form) {
      return $scope.showing_form === form
    }

    $scope.editExternalVideo = function (id) {
      var index = $scope.external_videos.map(function (o) { return o.id }).indexOf(id)
      $scope.errors = ''
      $scope.id = id
      $scope.name = $scope.external_videos[index].name
      $scope.description = $scope.external_videos[index].description
      $scope.url = $scope.external_videos[index].url
      $scope.showForm('edit')
    }

    $scope.updatePriorities = function () {
      var priorities = {}
      angular.forEach($scope.external_videos, function (external_video, index) {
        priorities[external_video.id] = index
      })
      ExternalVideosSort.update({ priorities: priorities })
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
        console.log('1234')
        ExternalVideoDestroy.destroy({ id: id }, function () {
          console.log('asdf')
          Toast.flash('Vídeo eliminado correctamente', 3000)
          var index = $scope.external_videos.map(function (o) { return o.id }).indexOf(id)
          $scope.external_videos.splice(index, 1)
        })
      }
    }

    $scope.fetchExternalVideos = function () {
      $scope.items = ExternalVideosCollection.get({
        external_videoable_type: $scope.external_videoable_type,
        external_videoable_id: $scope.external_videoable_id
      },
      function (result) {
        $scope.external_videos = result
      })
    }

    $scope.resetForm = function () {
      var forms = document.querySelectorAll('.new_external_video')
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

    $scope.saveExternalVideo = function (e) {
      e.preventDefault()
      $scope.errors = ''
      $scope.disabledForm(true)

      var data = {
        external_videoable_id: $scope.external_videoable_id,
        external_videoable_type: $scope.external_videoable_type,
        name: $scope.name,
        description: $scope.description,
        url: $scope.url
      }

      if ($scope.id !== '') {
        ExternalVideoUpdate.update({ id: $scope.id, external_video: data },
          function (result) {
            var index = $scope.external_videos.map(function (o) { return o.id }).indexOf($scope.id)
            $scope.external_videos[index] = result
            Toast.flash('Vídeo actualizado correctamente', 3000)
            $scope.clearData()
            $scope.showing_form = ''
            $scope.resetForm()
            $scope.disabledForm(false)
          },
          function (result) {
            $scope.errors = result.data
            $scope.disabledForm(false)
          }
        )
      } else {
        ExternalVideoCreate.create({ external_video: data },
          function (result) {
            $scope.external_videos.push(result)

            Toast.flash('Vídeo creado correctamente', 3000)
            $scope.clearData()
            $scope.showing_form = ''
            $scope.updatePriorities()
            $scope.resetForm()
            $scope.disabledForm(false)
          },
          function (result) {
            $scope.errors = result.data
            $scope.disabledForm(false)
          }
        )
      }
    }
  }
])
