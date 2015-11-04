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
      plotGroups: "pie_user,barplot_hourByUser,barplot_monthByUser",
      plotTypes: "pie_user,barplot_hourByUser,barplot_monthByUser",
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
        text: "Departure/Arrival Maps",
        value: "bubble_stationFrom,bubble_stationTo,cumulative_coasting"
      }, {
        text: "Station Usage",
        value: "bubble_stationTotal,barplot_station"
      }, {
        text: "Calendar",
        value: "heatmap_weekByHour,calendar_weather"
      }, {
        text: "Time of Day",
        value: "heatmap_weekByHour,pie_daylight"
      }, {
        text: "Single Station Focus",
        value: "bubble_stationTotal,heatmap_weekByHour,barplot_station,barplot_hourByUser"
      }, {
        text: "Chart Junkie",
        value: "pie_user,barplot_hourByUser,barplot_monthByUser,pie_daylight," +
               "bubble_stationFrom,bubble_stationTo,bubble_stationTotal,cumulative_coasting," +
               "barplot_station,heatmap_weekByHour,calendar_weather" 
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
      }, {
        text: "APA Conference: Apr 18-21",
        value: "APA_conference"
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
        text: "from Any Station",
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
