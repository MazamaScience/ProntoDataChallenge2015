// Main js file. JS code follows many of the guidelines specified at https://github.com/johnpapa/angular-styleguide

(function() {
  'use strict';

  // Define our application, 'App', and list module dependencies
  angular
    .module('App', ['ui.router', 'ngMaps', 'ui.slider', 'ui.bootstrap'])
    .config(configure);

  configure.$inject = 
    ['$stateProvider', '$urlRouterProvider'];

  function configure($stateProvider, $urlRouterProvider) {

    $stateProvider
      .state("index", {
        url: "/",
        templateUrl: "views/main.html"
      })
      .state("about", {
        url: "/about",
        templateUrl: "views/about.html"
      });

    $urlRouterProvider.otherwise("/");

  }

})();// Main controller
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

        case 1:
        case 2:
          return "col-md-6";
          break;
        case 3:
        case 5:
        case 6:
          return "col-md-4";
          break;
        case 4:
        case 7:
        case 8:
          return "col-md-3";
          break;

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
// Creates a full page popup that fades out when clicked
// Relies on CSS rules from Mazama_databrowser_base.css
// There should be no need to make changes to this

angular.module('App')

	.directive('selectMenu', ['$compile', function ($compile) {

    return {
      restrict: 'E',		// Is an element <popup> </popup>
      transclude: true,		// Allows HTML content inside
      scope: {
        model: '=',
        options: '='
      },
      template: '<div class="btn-group" dropdown><button type="button" class="btn btn-default btn-block" dropdown-toggle>{{getText(model)}} <span class="caret"></span></button><ul class="dropdown-menu" role="menu"><li ng-repeat="opt in options" ng-click="click(opt)"><a>{{opt.text}}</a></li></ul></div>',
      link: function($scope, ele, atr) {

        var options = $scope.options;

        $scope.getText = function(m) {
          for (var i=0; i<options.length; i++) {
            if (options[i].value === m) {
              return options[i].text;
            }
          }
          return "";
        }

        $scope.click = function(opt) { 
          $scope.model = opt.value;
        }

        $compile(ele.html())($scope);
        
      }
    }

  }]);// Creates a full page popup that fades out when clicked
// Relies on CSS rules from Mazama_databrowser_base.css
// There should be no need to make changes to this

angular.module('App')

	.directive('popup', function (MapObjects) {

    return {
      restrict: 'E',		// Is an element <popup> </popup>
      transclude: true,		// Allows HTML content inside
      scope: {
        visible: '='		// Binds it to some boolean attribute, will show when true
        					// Because this is binded with "=" when the popup is clicked
        					// The external variable this is bound to will change to false
      },
      template: '<div class="popup-wrapper" ng-click="visible=false" ng-class="{visible: visible}"><div class="row popup" ng-transclude></div></div>'
    }

  });// I store all of the in memory data here. Controllers pull from and modify
// this data.

(function() {
  'use strict';

  angular.module('App')
    .factory('LocalData', LocalData);

  LocalData.$inject = [];

  function LocalData() {

    var request = {
      language: "en",
      plotWidth: 640,
<<<<<<< HEAD
      productType: "systemTable", 
      plotTypes: "heatmapHourByDay,daylight,weatherCalendar",
=======
      productType: "systemTable",
      plotType: "barplot_weekByDay",
>>>>>>> af84eec6a4850e9b013cb3be7dcd888d4a61abd8
      userType: "all",
      age: "all",
      gender: "all",
      dayType: "all",
      timeOfDay: "all",
      distance: "all",
      stationId: "all",
      lat: 47,
      lng: 122
    };

    var forms = {
<<<<<<< HEAD

      plotGroups: [{
        text: "Group 1",
        value: "heatmapHourByDay,daylight,weatherCalendar"
      }, {
        text: "Group 2",
        value: "barplotDayByWeek,heatmapHourByDay,daylight,weatherCalendar,stationBubble"
      }, {
        text: "Group 3",
        value: "barplotDayByWeek,heatmapHourByDay"
=======
      plotType: [{
        text: "barplot_weekByDay",
        value: "barplot_weekByDay"
      }, {
        text: "heatmap_weekByHour",
        value: "heatmap_weekByHour"
      }, {
        text: "pie_daylight",
        value: "pie_daylight"
      }, {
        text: "calendar_weather",
        value: "calendar_weather"
      }, {
        text: "bubble_station",
        value: "bubble_station"
>>>>>>> af84eec6a4850e9b013cb3be7dcd888d4a61abd8
      }],

      userType: [{
        text: "All Users",
        value: "all"
      }, {
        text: "Annual",
        value: "annual"
      }, {
        text: "Short-Term",
        value: "shortTerm"
      }],

      age: [{
        text: "All Ages",
        value: "all"
      }, {
        text: "Under 21",
        value: "_21"
      }, {
        text: "21 to 30",
        value: "21_30"
      }, {
        text: "31 to 40",
        value: "31_40"
      }, {
        text: "41 to 60",
        value: "41_60"
      }, {
        text: "Over 60",
        value: "61_"
      }],

      gender: [{
        text: "All Genders",
        value: "all"
      }, {
        text: "Male",
        value: "male"
      }, {
        text: "Female",
        value: "female"
      }, {
        text: "Other",
        value: "other"
      }],

      dayType: [{
        text: "All Days",
        value: "all"
      }, {
        text: "Weekday",
        value: "weekday"
      }, {
        text: "Weekend",
        value: "weekend"
      }],

      timeOfDay: [{
        text: "All Times",
        value: "all"
      }, {
        text: "Early 4-6",
        value: "early"
      }, {
        text: "AM Commute 7-9",
        value: "amCommute"
      }, {
        text: "Mid Day 10-3",
        value: "midday"
      }, {
        text: "PM Commute 4-6",
        value: "pmCommute"
      }, {
        text: "Evening 7-10",
        value: "evening"
      }, {
        text: "Night 11-3",
        value: "night"
      }],

      distance: [{
        text: "All Distances",
        value: "all"
      }, {
        text: "Zero",
        value: "zero"
      }, {
        text: "0-1 km",
        value: "0_1"
      }, {
        text: "1-2 km",
        value: "1_2"
      }, {
        text: "2-3 km",
        value: "2_3"
      }, {
        text: "3-5 km",
        value: "3_5"
      }, {
        text: " >5 km",
        value: "5_"
      }],

      stationId: [{
        text: "All Stations",
        value: "all"
      }, {
        text: "Pier 69",
        value: "WF-01"
      }]

    };

    var map = function($scope) {
      return {
        center: [47, -122],
        zoom: 4,
        events: {
          click: function(e) {
            factory.request.lat = Math.round(Math.pow(10,4) * e.latLng.lat()) / Math.pow(10,4);
            factory.request.lng = Math.round(Math.pow(10,4) * e.latLng.lng()) / Math.pow(10,4);
            $scope.$apply();
          }
        }
      };
    };

    var marker = {
      options: function() {
        return {
          draggable: true
        };
      },
      decimals: 4
    };

    var factory = {
      request: request,
      forms: forms,
      map: map,
      marker: marker
    };
    
    return factory;

  }

})();
// Service for making JSON requests. Also provides access to the request status, i.e. 
// loading or error messages

(function() {
  'use strict';

  angular.module('App')
    .factory('RequestService', RequestService);

  RequestService.$inject = ['$http', '$q'];
    
  function RequestService($http, $q) {

    // Databrowser cgi url, this is always the same
    var url = '/cgi-bin/__DATABROWSER__.cgi?';

    // Current status
    var status = {
      loading: false,
      error: false
    };

    var factory = {
      status: getStatus,
      get: get
    };

    return factory;

    ///////////////
    ///////////////
    ///////////////

    function getStatus() {
      return status;
    }

    // Serialize object
    function serialize(obj) {
      var str = "";
      for (var key in obj) {
        if (str !== "") {
          str += "&";
        }
        str += key + "=" + obj[key];
      }
      return str;
    }

    // Error handling (this won't usually happen)
    function error(response) {
      return ($q.reject(response.data.message));
    }

    // Success handling. This includes handling errors that are
    // successfuly returned.
    function success(response) {
      status.loading = false;
      if (response.data.status === "ERROR") {
        status.error = response.data.error_text;
        return ($q.reject(response.data.error_text));
      }
      return (response);
    }

    // Make a json request with an object of data
    function get(data) {
      status.loading = true;
      status.error = false;
      var request = $http({
        method: 'POST',
        url: url + serialize(data)
      });
      return (request.then(success, error));
    }


  }

})();