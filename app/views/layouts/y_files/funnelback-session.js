'use strict';

angular
.module('Funnelback', ['ngResource'])
.controller('DefaultCtrl', ['$scope', 'CartService', function($scope, cartService) {
    $scope.cart = cartService.query();
    $scope.displayed = 'results';
    $scope.searchHistoryEmpty = false;

    $scope.itemForms = {
        0: 'no items',
        one: '{} item',
        other: '{} items'
    }

    $scope.toggleCart = function() {
        if ($scope.displayed !== 'cart' && $scope.cart.length > 0) {
            $scope.displayed = 'cart';
        } else {
            $scope.displayed = 'results';
        }
    }

    $scope.toggleHistory = function() {
        if ($scope.displayed === 'history') {
            $scope.displayed = 'results';
        } else {
            $scope.displayed = 'history';
        }
    }

    $scope.hideCart = function() {
        $scope.displayed = 'results';
    }

    $scope.hideHistory = function() {
        $scope.displayed = 'results';
    }

    $scope.isDisplayed = function(type) {
        return $scope.displayed === type;
    }

}])
.controller('CartCtrl', ['$scope', 'CartService', function($scope, cartService) {
    $scope.cartSelected = [];

    $scope.clear = function(msg) {
        if (confirm(msg)) {
            cartService.clear();
            $scope.$parent.hideCart();
        }
    }

    $scope.remove = function(url) {
        if (confirm('This item will be removed from your selection')) {
            cartService.remove(url);
        }
    }

    $scope.$watch('cart', function(newValue) {
        $scope.cartSelected = [];

        // Watch for empty cart
        if ($scope.newValue < 1) {
            $scope.$parent.hideCart();
            return;
        }

        // Watch for item selection
        for (var i=0; i<newValue.length; i++) {
            if (newValue[i].selected) {
                $scope.cartSelected.push(newValue[i].indexUrl);
            }
        }

    }, true);

}])
.controller('SearchHistoryCtrl', ['$scope', 'HistoryService', function($scope, historyService) {

    $scope.clear = function(msg) {
        if (confirm(msg)) {
            historyService.clear('search');
            $scope.$parent.searchHistoryEmpty = true;
        }
    }
}])
.controller('ClickHistoryCtrl', ['$scope', 'HistoryService', function($scope, historyService) {
    $scope.clickHistoryEmpty = false;

    $scope.clear = function(msg) {
        if (confirm(msg)) {
            historyService.clear('click');
            $scope.clickHistoryEmpty = true;
        }
    }

}])
.factory('collection', function() {
    var re =/[&?]collection=([^&#]+)/;
    var matches = re.exec(document.URL);
    if (matches && matches[1] && matches[1] !== '') {
        return matches[1];
    } else {
        throw "A 'collection' parameter should be present in the URL";
    }
})
.service('CartService', ['$resource', 'collection', function($resource, collection) {
    var cartResource = $resource('/s/cart.json',
        {collection: collection},
        {
            query: {method: 'GET',    params: {collection: collection}, isArray: true},
            clear: {method: 'DELETE', params: {collection: collection}, isArray: true},
            save:  {method: 'POST',   params: {collection: collection}, isArray: true}, 
            delete:{method: 'DELETE', params: {collection: collection}, isArray: true}
        });

    var cartData = cartResource.query(function() {
        for (var i=0; i<cartData.length; i++) {
            // Augment cart data with selection status (checkboxes
            // for the cart UI)
            cartData[i].selected = false;

            // Format multi-valued fields
            for (var j=0; j<cartData[i].metaData.length; j++) {
                cartData[i].metaData[j] = cartData[i].metaData[j].replace(/\|/, ', ');
            }
        }

    });

    return {
        query: function() {
            return cartData;
        },
        clear: function() {
            cartResource.clear(function(data) {
                cartData.splice(0, cartData.length);
                cartData.push.apply(cartData, data);
            });
        },
        add: function(url) {
            cartResource.save({url: url}, {}, function(data) {
                cartData.splice(0, cartData.length);
                cartData.push.apply(cartData, data);
            });
        },
        remove: function(url) {
            cartResource.delete({url: url},{}, function(data) {
                cartData.splice(0, cartData.length);
                cartData.push.apply(cartData, data);
            });
        }
    } 
}])
.service('HistoryService', ['$resource', 'collection', function($resource, collection) {
    var historyResource = $resource('/s/:op-history.json',
        {collection: collection},
        {
            clear: {method: 'DELETE', params: {collection: collection}},
        });

    return {
        clear: function(type) {
            historyResource.clear({op: type});
        }
    }
}])
.directive('cart', ['CartService', function(cartService) {
    return {
        restrict: 'E',
        controller: function($scope) {
            $scope.remove = function(item) {
                cartService.remove(item);
            }

            $scope.clear = function() {
                cartService.clear();
            }
        },
        link: function(scope) {
            scope.cart = cartService.query();
        }
    }
}])
.directive('fbResult', ['CartService', '$location', function(cartService, $location) {
    var trim = function(s) {
        return s.replace(/^\s+/, '')
            .replace(/\s+$/, '');
    }

    return {
        restrict: 'A',
        scope: true,
        controller: function($scope, $element, $attrs) {
            /**
             * Update the cart status of the result, depending
             * if it's in the cart or not.
             */
            $scope.update = function() {
                for (var i=0; i<$scope.cart.length; i++) {
                    if ($scope.indexUrl === $scope.cart[i].indexUrl) {
                        $scope.cartState = 'in';
                        return;
                    }
                }

                $scope.cartState = 'out';
            };
        },
        link: function(scope, elt, attrs) {
            // Initial state: Result is not in cart
            scope.cartState = 'out';

            scope.cart = cartService.query();

            // Find result index URL
            attrs.$observe('fbResult', function(val) {
                scope.indexUrl = val;
                // Update status if URL changes
                scope.update();
            });

            scope.$watch('cart', function(newValue) {
                // Update status if cart changes
                scope.update();
            }, true);
        }
    }
}])
.directive('cartLink', ['CartService', function(cartService) {
    return {
        restrict: 'EA',
        controller: function($scope, $element, $attrs) {
            $scope.toggle = function() {
                if ($scope.cartState === 'in') {
                    $scope.cartState = 'out';
                    cartService.remove($scope.indexUrl);
                } else {
                    $scope.cartState = 'in';
                    cartService.add($scope.indexUrl);
                }
            }
        },
        link: function(scope, elt, attrs) {
            // Setup save/remove labels
            attrs.$observe('labels', function(val) {
                var labels = angular.isDefined(val) ? val : 'Save|Remove';
                scope.labels = {
                    'out': labels.split(/\|/)[0],
                    'in' : labels.split(/\|/)[1]
                };
            });

            // Setup in/out css classes
            attrs.$observe('css', function(val) {
                var csss = angular.isDefined(val) ? val : 'save|remove';
                scope.csss = {
                    'out': csss.split(/\|/)[0],
                    'in' : csss.split(/\|/)[1]
                };
            });

            // Change label and CSS class when state changes
            scope.$watch('cartState', function(newValue) {
                scope.label = scope.labels[newValue];
                scope.css   = scope.csss[newValue];
            });
        }
    }
}])
.directive('fbHistoryClear', ['HistoryService', function(historyService) {
    return {
        scope : {
            historyType: '@fbHistoryClear'
        },
        restrict: 'A',
        controller: function($scope) {
            $scope.clear = function() {
                historyService.clearHistory($scope.historyType);
                $scope.history = [];
            }
        },
        link: function(scope, elt, attrs) {
            scope.history = ['non-empty'];
        }
    }
}])
.filter('cut', function () {
    return function(text, cut) {
        if (text === null || text.length === 0) {
            return null;
        }
        var re = new RegExp('^'+cut);
        return text.replace(re, '');
    };
})
.filter('truncate', function() {
    return function(text, limit) {
        if (text ===null || text.length === 0) {
            return null;
        }
        if (text.length > limit) {
            return text.substring(0, limit) + "…";
        } else {
            return text;
        }
    }
});
