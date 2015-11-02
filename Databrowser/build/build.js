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

        // Two columns
        case 1:
        case 2:
        case 4:
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
      plotWidth: 1024,
      productType: "systemTable", 
      plotGroups: "pie_user,barplot_hourByUser,barplot_monthByUser",
      plotTypes: "pie_user",
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

      plotGroups: [{
        text: "System Overview",
        value: "pie_user,barplot_hourByUser,barplot_monthByUser"
      }, {
        text: "Time of Day",
        value: "heatmap_weekByHour,pie_daylight"
      }, {
        text: "Calendar",
        value: "heatmap_weekByHour,calendar_weather"
      }, {
        text: "Departure/Arrival Maps",
        value: "bubble_stationFrom,bubble_stationTo"
      }, {
        text: "Station Usage",
        value: "bubble_stationTotal,barplot_station"
      }, {
        text: "Individual Station",
        value: "bubble_stationTotal,barplot_station,heatmap_weekByHour,pie_daylight"
      }, {
        text: "Chart Junkie",
        value: "pie_user,barplot_hourByUser,barplot_monthByUser,pie_daylight," +
               "bubble_stationFrom,bubble_stationTo,bubble_stationTotal,barplot_station," +
               "heatmap_weekByHour,calendar_weather" 
      }, {
        text: "... experimental ...",
        value: "pie_user"
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
      }, {
        text: "October - March",
        value: "Oct_Mar"
      }, {
        text: "April - September",
        value: "Apr_Sep"
/*
      }, {
        text: "< .02 in Rain",
        value: "rain__02"
      }, {
        text: "> 0.2 in Rain",
        value: "rain_02"
*/
      }, {
        text: "> 0.5 in Rain",
        value: "rain_05"
/*
      }, {
        text: "> 1.0 in Rain",
        value: "rain_10"
*/
      }, {
        text: "< 50 F",
        value: "temp__50"
      }, {
        text: "> 50 F",
        value: "temp_50"
/*
      }, {
        text: "> 60 F",
        value: "temp_60"
      }, {
        text: "> 70 F",
        value: "temp_70"
*/
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
        text: "from 1st Ave & Marion St",
        value: "CBD-05",
      }, {
        text: "from 2nd Ave & Blanchard St",
        value: "BT-05",
      }, {
        text: "from 2nd Ave & Pine St",
        value: "CBD-13",
      }, {
        text: "from 2nd Ave & Vine St",
        value: "BT-03",
      }, {
        text: "from 2nd Ave & Spring St",
        value: "CBD-06",
      }, {
        text: "from 3rd Ave & Broad St",
        value: "BT-01",
      }, {
        text: "from 6th Ave & Blanchard St",
        value: "BT-04",
      }, {
        text: "from 6th Ave S & S King St",
        value: "ID-04",
      }, {
        text: "from 7th Ave & Union St",
        value: "CBD-03",
      }, {
        text: "from 9th Ave N & Mercer St",
        value: "DPD-01",
      }, {
        text: "from 12th Ave & E Denny Way",
        value: "CH-06",
      }, {
        text: "from 12th Ave & E Mercer St",
        value: "CH-15",
      }, {
        text: "from 12th Ave & NE Campus Pkwy",
        value: "UD-04",
      }, {
        text: "from 12th Ave & E Yesler Way",
        value: "CD-01",
      }, {
        text: "from 15th Ave NE & NE 40th St",
        value: "UW-04",
      }, {
        text: "from 15th Ave E & E Thomas St",
        value: "CH-05",
      }, {
        text: "from Bellevue Ave & E Pine St",
        value: "CH-12",
      }, {
        text: "from Burke Museum",
        value: "UW-02",
      }, {
        text: "from Burke-Gilman Trail",
        value: "UD-01",
      }, {
        text: "from Cal Anderson Park",
        value: "CH-08",
      }, {
        text: "from Children's Hospital",
        value: "DPD-03",
      }, {
        text: "from City Hall",
        value: "CBD-07",
      }, {
        text: "from Dexter Ave & Denny Way",
        value: "SLU-18",
      }, {
        text: "from Dexter Ave N & Aloha St",
        value: "SLU-02",
      }, {
        text: "from E Blaine St & Fairview Ave E",
        value: "EL-03",
      }, {
        text: "from E Harrison St & Broadway Ave E",
        value: "CH-02",
      }, {
        text: "from E Pine St & 16th Ave",
        value: "CH-07",
      }, {
        text: "from Eastlake Ave E & E Allison St",
        value: "EL-05",
      }, {
        text: "from Fred Hutchinson Cancer Research Center",
        value: "EL-01",
      }, {
        text: "from Frye Art Museum",
        value: "FH-01",
      }, {
        text: "from Harvard Ave & E Pine St",
        value: "CH-09",
      }, {
        text: "from Key Arena",
        value: "SLU-19",
      }, {
        text: "from King Street Station Plaza",
        value: "PS-05",
      }, {
        text: "from Mercer St & 9th Ave N",
        value: "SLU-21"
      }, {
        text: "from NE 42nd St & University Way NE",
        value: "UD-02",
      }, {
        text: "from NE 47th St & 12th Ave NE",
        value: "UD-07",
      }, {
        text: "from Occidental Park",
        value: "PS-04",
      }, {
        text: "from PATH",
        value: "SLU-07",
      }, {
        text: "from Pier 69",
        value: "WF-01",
      }, {
        text: "from Pine St & 9th Ave",
        value: "SLU-16",
      }, {
        text: "from Pronto shop",
        value: "XXX-01",
      }, {
        text: "from REI",
        value: "SLU-01",
      }, {
        text: "from Republican St & Westlake Ave N",
        value: "SLU-04",
      }, {
        text: "from Seattle Aquarium",
        value: "WF-04",
      }, {
        text: "from Seattle University",
        value: "FH-04",
      }, {
        text: "from Lake Union Park",
        value: "SLU-17",
      }, {
        text: "from Summit Ave & E Denny Way",
        value: "CH-01",
      }, {
        text: "from Summit Ave E & E Republican St",
        value: "CH-03",
      }, {
        text: "from Terry Ave & Stewart St",
        value: "SLU-20",
      }, {
        text: "from Union St & 4th Ave",
        value: "CBD-04",
      }, {
        text: "from UW Engineering Library",
        value: "UW-06",
      }, {
        text: "from UW Magnuson Health Sciences Center Rotunda",
        value: "UW-10",
      }, {
        text: "from UW McCarty Hall",
        value: "UW-01",
      }, {
        text: "from UW Intramural Activities Building",
        value: "UW-07",
      }, {
        text: "from Westlake Ave & 6th Ave",
        value: "SLU-15"
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