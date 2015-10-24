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

  }]);