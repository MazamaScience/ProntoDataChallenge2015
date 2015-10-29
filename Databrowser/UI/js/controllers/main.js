// Main controller
// Exposes the model to the template
// Contains plot options, map, and overlay options

(function() {
  'use strict';

  angular.module('App')
    .controller('Main', Main);

  Main.$inject = ['$scope', 'LocalData', 'RequestService', '$location'];

  function Main($scope, LocalData, RequestService, $location) {

    // vm stands for view model
    var vm = this;

    vm.request = LocalData.request;
    vm.returnData = {};

    vm.forms = LocalData.forms;

    // ng-maps events
    vm.map = LocalData.map($scope);
    vm.map.events = vm.map.events;
    vm.marker = LocalData.marker;

    // vm.updatePlot = updatePlot;                 
    vm.generatePlotTable = generatePlotTable;
    vm.status = RequestService.status;          // request status and results
    vm.popup = { visible: false, url: null };   // plot zoom popup object

    vm.plotTableClass = plotTableClass;

    // Initial plot
    // updatePlot();
    generatePlotTable();

    ///////////////
    ///////////////
    ///////////////

    // Make request
    function updatePlot() {
      RequestService.get(LocalData.request)
        .then(function(result) {
          LocalData.result = result;
        });
    }

    function generatePlotTable() {
      LocalData.request.productType = 'plotTable';
      // vm.returnData.url = window.location.href;
      RequestService.get(LocalData.request)
        .then(function(result) {  
          var json = result.data.return_json;
          json = JSON.parse(json).returnValues;
          // vm.returnData.plotTypes = json.plotTypes;
          // vm.returnData.relBase = result.data.rel_base;
          vm.returnData.plotTypes = ["a","b","c","d"];
        });
    };

    function plotTableClass() {
      switch(vm.returnData.plotTypes.length) {

        case 1:
        case 2:
          return "col-sm-6";
          break;
        case 3:
        case 5:
        case 6:
          return "col-sm-4";
          break;
        case 4:
        case 7:
        case 8:
          return "col-sm-3";
          break;

        default:
          return "col-sm-6";

      }
    }

    // // Watched for changes in plotURL, which translates to this function firing
    // // whenever a successful request is made
    // $scope.$watch(function() {
    //   return LocalData.result;
    // }, function() {
    //   if(LocalData.result) {
    //     vm.url = LocalData.result.data.rel_base + ".png";
    //     vm.popup.url = vm.url;
    //   }
    // });

    // When URL params change apply those changes to the request object
    $scope.$watch(function() {
      return $location.search();
    }, function(params, old) {

      // If param is an attribute of request, add it's 
      // value to request
      for (var attr in params) {
        if (vm.request.hasOwnProperty(attr)) {
          vm.request[attr] = params[attr];
        }
      }

    }, true);

    // When the request object changes apply those changes to the URL params
    $scope.$watch(function() { 
      return vm.request; 
    }, function(params) {

      var par = $location.search();
      for (var attr in params) {
        par[attr] = params[attr];
      }
      $location.search(par);

    }, true);

  }

})();
