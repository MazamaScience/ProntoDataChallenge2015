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
      plotWidth: 640,
      productType: "systemTable",
      plotType: "weeklyUsageByDayOfWeek",
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
      plotType: [{
        text: "Weekly by DoW",
        value: "weeklyUsageByDayOfWeek"
      }, {
        text: "Daily by Hour",
        value: "dailyUsageByHourOfDay"
      }, {
        text: "Daylight",
        value: "daylight"
      }, {
        text: "Weather Calendar",
        value: "weatherCalendar"
      }, {
        text: "stationBubble",
        value: "stationBubble"
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
