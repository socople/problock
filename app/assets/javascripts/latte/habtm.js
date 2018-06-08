app.factory('AvailableCollection', [
  '$resource',
  function ($resource) {
    return $resource('/latte/habtm/available', { model: '@model', item_type: '@item_type', item_id: '@item_id' },
      { get: { isArray: true } }
    )
  }
])

app.factory('EnabledCollection', [
  '$resource',
  function ($resource) {
    return $resource('/latte/habtm/enabled', { model: '@model', item_type: '@item_type', item_id: '@item_id' },
      { get: { isArray: true } }
    )
  }
])

app.controller('habtmController', [
  '$scope',
  'AvailableCollection',
  'EnabledCollection',
  function ($scope, AvailableCollection, EnabledCollection) {
    //
    $scope.fetchAvailable = function (model, item_type, item_id) {
      $scope.available = AvailableCollection.get({
        model: model,
        item_type: item_type,
        item_id: item_id
      },
      function (result) {
        $scope.available = result
      })
    }

    $scope.fetchEnabled = function (model, item_type, item_id) {
      $scope.enabled = EnabledCollection.get({
        model: model,
        item_type: item_type,
        item_id: item_id
      },
      function (result) {
        $scope.enabled = result
      })
    }

    $scope.add = function (item) {
      var index = $scope.available.indexOf(item)
      $scope.available.splice(index, 1)
      $scope.enabled.push(item)
    }

    $scope.remove = function (item) {
      var index = $scope.enabled.indexOf(item)
      $scope.enabled.splice(index, 1)
      $scope.available.push(item)
    }
  }
])
