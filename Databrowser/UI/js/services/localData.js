// I store all of the in memory data here. Controllers pull from and modify
// this data.

(function() {
  'use strict';

  angular.module('App')
    .factory('LocalData', LocalData);

  LocalData.$inject = [];

  function LocalData() {

    var request = {
      language: "en",
      plotWidth: 700,
      plotType: "growth",
      userType: "Annual Member",
      weekday_weekend: "weekday",
      lat: 47,
      lng: -122
    };

    var forms = {
      userType: [{
        text: "Annual Member",
        value: "Annual Member"
      }, {
        text: "Short-Term Pass Holder",
        value: "Short-Term Pass Holder"
      }],
      weekday_weekend: [{
        text: "Weekday",
        value: "Weekday"
      }, {
        text: "Weekend",
        value: "Weekend"
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
