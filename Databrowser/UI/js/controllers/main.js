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

    vm.updatePlot = updatePlot;                 
    vm.status = RequestService.status;          // request status and results
    vm.popup = { visible: false, url: null };   // plot zoom popup object
    vm.clicked = clicked;

    vm.plotTableClass = plotTableClass;

    // Initial plot
    updatePlot();

    ///////////////
    ///////////////
    ///////////////

    document.onkeydown = function(e) {
      e = e || window.event;
      console.log(vm.popup)
      if (vm.popup.visible) {
        var index = vm.returnData.plotTypes.indexOf(vm.popup.plotType);
        switch(e.which || e.keyCode) {
          case 37: // left
          index = index - 1 < 0 ? vm.returnData.plotTypes.length - 1 : index - 1;
          break;

          case 39: // right
          index = index + 1 > vm.returnData.plotTypes.length - 1 ? 0 : index + 1;
          break;
        }
        console.log(index);
        vm.popup.plotType = vm.returnData.plotTypes[index];
        vm.popup.url = vm.popup.relBase + "_" + vm.popup.plotType;
        $scope.$apply();
      }
    }


    // Make request
    function updatePlot() {
      RequestService.get(LocalData.request)
        .then(function(result) {  
          var json = result.data.return_json;
          json = JSON.parse(json).returnValues;
          vm.returnData.plotTypes = vm.request.plotTypes.split(",");
          vm.returnData.relBase = result.data.rel_base;
        });
    }

    // Plot click popup behavior
    function clicked(relBase, plotType){
      var url = relBase + "_" + plotType;
      vm.popup.relBase = relBase;
      vm.popup.plotType = plotType;
      vm.popup.visible = true;
      vm.popup.url = url;
    };

    function plotTableClass() {
      switch(vm.returnData.plotTypes.length) {

        // Two columns
        case 1:
          return "col-md-12";
          break;
        case 2:
          return "col-md-6";
          break;
        // Three columns
        case 3:
        case 5:
        case 6:
        case 9:
          return "col-md-4";
          break;
        // Four columns
        case 4:
        case 7:
        case 8:
        case 10:
        case 11:
        case 12:
          return "col-md-3";
          break;

        // Two columns
        default:
          return "col-md-6";

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

    // // When URL params change apply those changes to the request object
    // $scope.$watch(function() {
    //   return $location.search();
    // }, function(params, old) {

    //   // If param is an attribute of request, add it's 
    //   // value to request
    //   for (var attr in params) {
    //     if (vm.request.hasOwnProperty(attr)) {
    //       vm.request[attr] = params[attr];
    //     }
    //   }

    // }, true);

    // // When the request object changes apply those changes to the URL params
    // $scope.$watch(function() { 
    //   return vm.request; 
    // }, function(params) {

    //   var par = $location.search();
    //   for (var attr in params) {
    //     par[attr] = params[attr];
    //   }
    //   $location.search(par);

    // }, true);

  }

})();
