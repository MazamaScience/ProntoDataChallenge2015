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
      plotWidth: 1024,
      productType: "systemTable", 
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
        text: "Members vs. Visitors",
        value: "pie_user"
      }, {
        text: "Time of Day",
        value: "heatmap_weekByHour,pie_daylight"
      }, {
        text: "Calendar Views",
        value: "heatmap_weekByHour,calendar_weather"
      }, {
        text: "Station Analysis",
        value: "bubble_station"
      }, {
        text: "Everything",
        value: "pie_user,barplot_weekByDay,heatmap_weekByHour,pie_daylight,calendar_weather,bubble_station"
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
/*
      }, {
        text: "< .02 in Rain",
        value: "rain__02"
      }, {
        text: "> 0.2 in Rain",
        value: "rain_02"
      }, {
        text: "> 0.5 in Rain",
        value: "rain_05"
      }, {
        text: "> 1.0 in Rain",
        value: "rain_10"
      }, {
        text: "< 50 F",
        value: "temp__50"
      }, {
        text: "> 50 F",
        value: "temp_50"
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
