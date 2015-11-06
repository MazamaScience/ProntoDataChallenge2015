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
      })
      .state("dataStories", {
        url: "/dataStories",
        templateUrl: "views/dataStories.html"
      });

    $urlRouterProvider.otherwise("/");

  }

})();
