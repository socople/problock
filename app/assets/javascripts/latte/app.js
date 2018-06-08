// https://stackoverflow.com/questions/41063947/angular-1-6-0-possibly-unhandled-rejection-error
//
app.config(['$qProvider', function ($qProvider) {
  $qProvider.errorOnUnhandledRejections(false)
}])

app.factory('Member', [
  '$resource',
  function ($resource) {
    return $resource(window.location.pathname + '/:id.json', { id: '@id' }, {
      'update': { method: 'PUT' }
    })
  }
])

app.factory('Collection', [
  '$resource',
  function ($resource) {
    return $resource(window.location.pathname + '/:action.json', { action: '@action' }, {
      updates: { method: 'PUT' },
      destroys: { method: 'PUT' }
    })
  }
])

app.factory('GridCollection', [
  '$resource',
  function ($resource) {
    return $resource(window.location.pathname + '.json', {}, {
      get: { isArray: true },
      save: { method: 'POST' }
    })
  }
])

app.factory('SelectList', [
  '$resource',
  function ($resource) {
    return $resource('/latte/:controller/list.json', { controller: '@controller' },
      { get: { method: 'GET', isArray: true } }
    )
  }
])

app.factory('AdminSetting', [
  '$resource',
  function ($resource) {
    return $resource('/latte/admin_settings/table_columns.json', {},
      { update: { method: 'PUT' } }
    )
  }
])

app.controller('tableController', [
  '$scope',
  'NgTableParams',
  '$resource',
  'Collection',
  'Member',
  'SelectList',
  'AdminSetting',
  'Toast',
  function ($scope, NgTableParams, $resource, Collection, Member, SelectList, AdminSetting, Toast) {
    var api = $resource(window.location.pathname + '.json')
    var self = this

    $scope.dateRangePickerOptions = {
      callback: function (_day) {
        var pkrs = document.getElementsByClassName('date-range-picker-container')
        angular.element(pkrs).removeClass('displayed')
      }
    }

    $scope.dateFields = {}
    self.dateFilter = function (field) {
      var options = {}
      options[field + '_date_gteq'] = '/date-filter-from-template.html'
      options[field + '_date_lteq'] = '/date-filter-to-template.html'
      return options
    }

    $scope.string2date = function (string) {
      if (string === null || typeof string === 'undefined') {
        return null
      }
      return moment(string)._d
    }

    $scope.clearFilters = function ($event) {
      $event.preventDefault()
      self.tableParams.filter({})
    }

    $scope.showCalendarPicker = function ($event) {
      $event.preventDefault()

      angular
        .element($event.target)
        .parent()
        .toggleClass('displayed')
    }

    $scope.data = []
    $scope.indeterminate = false
    $scope.loaded = false

    self.tableParams = new NgTableParams({ filter: {}, count: 25 }, {
      counts: [],
      getData: function (params) {
        $scope.urlParams = params.url()
        return api.get(params.url()).$promise.then(function (data) {
          params.total(data.total_entries)
          $scope.data = data.result
          $scope.total_entries = data.total_entries
          $scope.checkboxes = { checked: false, ids: [] }

          if (data.admin_setting !== null) {
            var controller = /[^/]*$/.exec(window.location.pathname)[0]
            if (typeof data.admin_setting.table_columns[controller] !== 'undefined') {
              angular.forEach(self.cols, function (col, i) {
                col.show(data.admin_setting.table_columns[controller][i])
              })
            }
          }

          $scope.loaded = true
          return $scope.data
        })
      }
    })

    $scope.$watch(
      function () {
        var arr = []
        angular.forEach(self.cols, function (col) {
          arr.push(col.show())
        })
        return arr
      },
      function () {
        if ($scope.loaded) {
          var arr = []
          var controller = /[^/]*$/.exec(window.location.pathname)[0]
          angular.forEach(self.cols, function (col) {
            arr.push(col.show())
          })
          var data = {}
          data[controller] = arr
          AdminSetting.update({ admin_setting: { table_columns: data } })
        }
      },
      true
    )

    $scope.apiUrl = function () {
      if (typeof $scope.urlParams !== 'undefined') {
        delete $scope.urlParams.page
        delete $scope.urlParams.count

        var url = Object.keys($scope.urlParams).map(function (key) {
          return encodeURIComponent(key) + '=' + encodeURIComponent($scope.urlParams[key])
        }).join('&')

        return window.location.pathname + '.csv?' + url
      }
    }

    $scope.getSelectList = function (path) {
      var list = []
      SelectList.get(
        { controller: path },
        function (result) {
          angular.forEach(result, function (data) {
            list.push({ id: data.id, title: data[Object.keys(data)[1]] })
          })
        }
      )
      return list
    }

    $scope.checkboxes = { checked: false, ids: [] }
    $scope.item = {}
    $scope.showing_form = ''

    $scope.boolean_select_list = [
      { id: 1, title: 'Si' },
      { id: 0, title: 'No' }
    ]

    $scope.showForm = function (form) {
      $scope.showing_form = form
    }

    $scope.hideForms = function () {
      $scope.showing_form = ''
      $scope.item = {}
    }

    $scope.showingForm = function (form) {
      return $scope.showing_form === form
    }

    $scope.submitForm = function ($event) {
      $event.preventDefault()
      Collection.updates(
        {
          action: 'updates',
          ids: $scope.checkboxes.ids,
          item: $scope.item
        },
        function () {
          self.tableParams.reload()
          $scope.hideForms()
          Toast.flash('Registros actualizados correctamente', 3000)
        }
      )
    }

    $scope.deleteSelection = function ($event) {
      $event.preventDefault()

      if (window.confirm('¿Está seguro?')) {
        Collection.destroys(
          {
            action: 'destroys',
            ids: $scope.checkboxes.ids
          },
          function () {
            self.tableParams.reload()
            Toast.flash('Registros eliminados correctamente', 3000)
          }
        )
      }
    }

    $scope.submitField = function ($event, field, item) {
      angular
        .element($event.target)
        .addClass('requesting')

      var data = {}
      data[field] = item[field]
      Member.update(
        { id: item.id, item: data },
        function () {
          angular
            .element($event.target)
            .removeClass('requesting')
        }
      )
    }

    $scope.$watch('checkboxes.checked',
      function (value, prevalue) {
        if (value) {
          angular.forEach($scope.data, function (item) {
            if ($scope.checkboxes.ids.indexOf(item.id) === -1) {
              $scope.checkboxes.ids.push(item.id)
            }
          })
        } else {
          $scope.checkboxes.ids = []
        }
      }
    )

    $scope.$watch('checkboxes.ids',
      function (ids) {
        var e = angular.element(document.getElementsByClassName('all'))
        $scope.indeterminate = false
        e.prop('indeterminate', false)

        if (ids.length === $scope.data.length) {
          $scope.checkboxes.checked = true
        } else if (ids.length === 0) {
          $scope.checkboxes.checked = false
        } else {
          $scope.indeterminate = true
          e.prop('indeterminate', true)
        }
      },
      true
    )
  }
])

app.controller('gridController', [
  '$scope',
  'SelectList',
  'GridCollection',
  function ($scope, SelectList, GridCollection) {
    $scope.message = { message: 'Cargando... Por favor, espere.' }
    $scope.grid_options = {}
    $scope.filters = {}

    var objectParametize = function (obj, delimeter, q) {
      var str = []
      if (!delimeter) delimeter = '&'
      for (var key in obj) {
        switch (typeof obj[key]) {
          case 'string':
          case 'number':
            str[str.length] = key + '=' + obj[key]
            break
          case 'object':
            str[str.length] = objectParametize(obj[key], delimeter)
        }
      }
      return (q === true ? '?' : '') + str.join(delimeter)
    }

    $scope.items = GridCollection.get({}, function () {
      $scope.message = {}
    })

    $scope.filter = function ($event) {
      $event.preventDefault()
      $scope.message = { message: 'Filtrando... Por favor, espere.' }

      var filtersParams = {}
      for (var f in $scope.filters) {
        if ($scope.filters[f] === null) {
          delete $scope.filters[f]
          continue
        }
        filtersParams['filter[' + f + ']'] = $scope.filters[f]
      }

      $scope.items = GridCollection.get(filtersParams, function () {
        $scope.message = {}
      })
    }

    $scope.save = function () {
      $scope.message = { message: 'Procesando la información... Por favor, espere.' }
      GridCollection.save(
        { items: $scope.items },
        function (result) {
          $scope.items = result.items
          if (result.errors) {
            $scope.message = {
              message: 'Algunos registros no fueron guardados, por favor revise.',
              explanation: 'ATENCIÓN: Si recarga esta página, la información que NO LOGRÓ SER GUARDADA volverá a su estado original.',
              button: true
            }
          } else {
            $scope.message = {
              message: '¡Listo!',
              explanation: 'La información fue guardada exitosamente.',
              button: true
            }
          }
        }
      )
    }

    $scope.clearMessage = function ($event) {
      $event.preventDefault()
      $scope.message = {}
    }

    $scope.gridOptions = function (path) {
      if (typeof $scope.grid_options[path] === 'undefined') {
        $scope.grid_options[path] = []
        return SelectList.get(
          { controller: path },
          function (result) {
            angular.forEach(result, function (data) {
              $scope.grid_options[path].push(
                { id: data[Object.keys(data)[0]], name: data[Object.keys(data)[1]] }
              )
            })
          }
        )
      } else {
        return $scope.grid_options[path]
      }
    }

    angular.forEach(angular.element(document).find('hot-autocomplete'), function (e) {
      $scope.$eval(e.attributes['datarows'].value.match(/^\s*([\s\S]+?)\s+in\s+([\s\S]+?)\s*$/)[2])
    })

    $scope.addRow = function ($event) {
      $event.preventDefault()
      var last = $scope.items[0]
      var nrow = angular.copy(last)

      angular.forEach(nrow, function (value, i) {
        if (i === 'id') {
          nrow[i] = null
        } else if (angular.isObject(value)) {
          nrow[i] = value
        } else if (angular.isNumber(value)) {
          nrow[i] = 0
        } else if (typeof value === 'boolean') {
          nrow[i] = false
        } else {
          nrow[i] = ''
        }
      })
      $scope.items.push(nrow)
    }
  }
])
