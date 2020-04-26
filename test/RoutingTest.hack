use Catarini; 
use catarini\routing\{ Router, DynamicRouteSpec }; 

use function Facebook\FBExpect\expect; 

class RoutingTest extends Facebook\HackTest\HackTest{ 

    // There's a concern about making a new catarini without using the standard singleton method
    private function getRouter() : Router { 
        return (new Catarini())->route(); 
    }
    

    //
    // DynamicRouteSpec tests
    // 

    public function testDrsParsing() : void 
    { 
        $spec   = new DynamicRouteSpec('test/$id/guy'); 
        $debug  = $spec->_debug(); 
        expect($spec->isDynamic())->toBeTrue(); 
        expect($debug[0])->toBeSame(3); 
        expect($debug[1])->toBeSame(vec[ 'test', NULL, 'guy' ],     "Static part");
        expect($debug[2])->toBeSame(vec[ NULL, '$id', NULL ],       "Dynamic part"); 
    }

    public function testDrsMatching() : void 
    { 
        $spec   = new DynamicRouteSpec('users/$id/students/$student/thing'); 

        expect($spec->matches('users/22/students/150/thing'))->toBeTrue();
        expect($spec->matches('users/22/student/150/thing'))->toBeFalse();
        expect($spec->matches('users/22/thing'))->toBeFalse(); 
    }

    public function testDrsMatchParsing() : void 
    { 
        $req    = 'test/220/guy'; 
        $spec   = new DynamicRouteSpec('test/$id/guy');

        expect($spec->matches($req))->toBeTrue(); 
        expect($spec->getRawParams($req))->toBeSame(dict[
            '$id' => '220'
        ]);

    }


    //
    //
    // Routing algorithm tests
    //
    //


    private function assertRoute(Router $x, string $route) : void { 
        expect($x->hasRoute())->toBeTrue(); 
        expect($x->getRoute())->toBeSame($route); 
    }


    public function testBasicEquality() : void 
    { 
        $router = $this->getRouter();
        expect($router->_matches(vec[ 'test' ], 'GET', 'test', 'GET'))->toBeTrue();
        $this->assertRoute($router, 'test');
    }

    public function testOptions() : void 
    { 
        // Could be split into two; tests options successfully, chooses correct option successfully
        $router = $this->getRouter();
        expect($router->_matches(vec[ 'option', 'test' ], 'GET', 'test', 'GET'))->toBeTrue();
        $this->assertRoute($router, 'option');
    }

    public function testMethod() : void { 
        expect($this->getRouter()->_matches(vec[ 'test' ], 'GET', 'test', 'POST'))->toBeFalse();
        expect($this->getRouter()->_matches(vec[ 'test' ], 'POST', 'test', 'GET'))->toBeFalse();
        // Incomplete
        // Needs more scenarios
        // Needs MethodNotAllowed
    }

    public function testSlashesTrim() : void { 
        expect(  $this->getRouter()->_matches(vec[ 'test' ], 'GET',         'test', 'GET'))->toBeTrue(); 
        expect(  $this->getRouter()->_matches(vec[ 'test' ], 'GET',         '/test', 'GET'))->toBeTrue(); 
        expect(  $this->getRouter()->_matches(vec[ '/test' ], 'GET',        'test', 'GET'))->toBeTrue(); 
        expect(  $this->getRouter()->_matches(vec[ '/test' ], 'GET',        '/test', 'GET'))->toBeTrue(); 
    }

    public function testIgnoresQueryString() : void { 
        expect($this->getRouter()->_matches(vec[ 'test' ], 'GET', '/test?thing=guy', 'GET'))->toBeTrue(); 
    }


    public function testDynamic() : void { 
        $router = $this->getRouter(); 
        expect($router->_matches(vec['object/$id/thing'], 'GET', '/object/12/thing', 'GET'))->toBeTrue(); 
        expect($router->_rawurlparams())->toBeSame(dict[ '$id' => '12' ]);
    }


    //
    // 

}