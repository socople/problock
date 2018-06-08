app.factory('AttachmentsCollection', [
  '$resource',
  function ($resource) {
    return $resource('../../attachments/:attachable_type/:attachable_id',
      { attachable_type: '@attachable_type', attachable_id: '@attachable_id' },
      { get: { isArray: true } }
    )
  }
])

app.factory('AttachmentsSort', [
  '$resource',
  function ($resource) {
    return $resource('../../attachments/sort', {}, { update: { method: 'PUT' } })
  }
])

app.factory('AttachmentDestroy', [
  '$resource',
  function ($resource) {
    return $resource('../../attachments/:id', { id: '@id' },
    { destroy: { method: 'DELETE' } })
  }
])

app.controller('attachmentsController', [
  '$scope',
  'AttachmentsCollection',
  'AttachmentsSort',
  'AttachmentDestroy',
  'Upload',
  'Toast',
  '$timeout',
  function ($scope, AttachmentsCollection, AttachmentsSort, AttachmentDestroy, Upload, Toast, $timeout) {
    //
    $scope.name = ''
    $scope.description = ''
    $scope.id = ''
    $scope.require_attachment = true
    $scope.attachment_url = ''
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
      $scope.attachment_url = ''
      $scope.name = ''
      $scope.description = ''
      $scope.file = null
      $scope.require_attachment = true
    }

    $scope.showingForm = function (form) {
      return $scope.showing_form === form
    }

    $scope.editAttachment = function (id) {
      var index = $scope.attachments.map(function (o) { return o.id }).indexOf(id)
      $scope.id = id

      $scope.errors = ''
      $scope.name = $scope.attachments[index].name
      $scope.description = $scope.attachments[index].description
      $scope.attachment_url = $scope.attachments[index].attachment_url
      $scope.file = $scope.attachments[index].attachment_url
      $scope.require_attachment = false
      $scope.showForm('edit')
    }

    $scope.updatePriorities = function () {
      var priorities = {}
      angular.forEach($scope.attachments, function (attachment, index) {
        priorities[attachment.id] = index
      })
      AttachmentsSort.update({ priorities: priorities })
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
        AttachmentDestroy.destroy({ id: id }, function () {
          Toast.flash('Archivo eliminada correctamente', 3000)
          var index = $scope.attachments.map(function (o) { return o.id }).indexOf(id)
          $scope.attachments.splice(index, 1)
        })
      }
    }

    $scope.fetchAttachments = function () {
      $scope.items = AttachmentsCollection.get({
        attachable_type: $scope.attachable_type,
        attachable_id: $scope.attachable_id
      },
      function (result) {
        $scope.attachments = result
      })
    }

    $scope.resetForm = function () {
      var forms = document.querySelectorAll('.new_attachment')
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

    $scope.uploadAttachment = function (e, file) {
      e.preventDefault()
      $scope.errors = ''
      $scope.disabledForm(true)

      file.upload = Upload.upload({
        url: ($scope.id !== '' ? ('../../attachments/' + $scope.id) : '../../attachments'),
        method: ($scope.id !== '' ? 'PUT' : 'POST'),
        data: {
          id: $scope.id,
          attachable_type: $scope.attachable_type,
          attachable_id: $scope.attachable_id,
          name: $scope.name,
          description: $scope.description,
          attachment: file
        },
        formDataAppender: function (fd, key, val) {
          if (angular.isArray(val)) {
            angular.forEach(val, function (v) {
              fd.append('attachment[' + key + ']', v)
            })
          } else {
            fd.append('attachment[' + key + ']', val)
          }
        }
      })
      .then(
        function (response) {
          $timeout(function () {
            if ($scope.id !== '') {
              var index = $scope.attachments.map(function (o) { return o.id }).indexOf($scope.id)
              $scope.attachments[index] = response.data
            } else {
              $scope.attachments.push(response.data)
            }

            Toast.flash('Archivo cargado correctamente', 3000)
            $scope.clearData()
            $scope.showing_form = ''

            $scope.updatePriorities()
            $scope.resetForm()
            $scope.disabledForm(false)
          })
        },
        function (response) {
          if (response.status > 0) {
            $scope.errors = response.data
            console.log($scope.errors)
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
