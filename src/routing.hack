namespace catarini\routing; 

use catarini\exception\HttpException;
use HH\Lib\{ Regex, Str }; 

// Dynamic URL / Route schema parsing 
class DynamicRouteSpec { 

    // Static and dynamic part arrays 
    private vec<?string> $static = vec[], $dynamic = vec[]; 
    private int $count; 

    public function _debug() : (int, vec<?string>, vec<?string>) { 
        return tuple($this->count, $this->static, $this->dynamic); 
    }

    public function __construct(string $spec) { 
        $split = \explode('/', $spec);
        $this->count = \count($split); 

        foreach($split as $component) { 
            if($component[0] == '$') { 
                $this->static[]     = NULL;
                $this->dynamic[]    = $component;
                $this->is_dynamic   = TRUE; 
            }

            else { 
                $this->static[]     = $component;
                $this->dynamic[]    = NULL; 
            }
        }
    }

    private bool $is_dynamic = FALSE; 
    public function isDynamic() : bool { 
        return $this->is_dynamic;
    }


    public function matches(string $path) : bool { 
        $split = \explode('/', $path);  
        if(\count($split) != $this->count) return FALSE;

        for($i = 0; $i < \count($split); $i++) { 
            if($this->dynamic[$i] is null && !($this->static[$i] === $split[$i])) return FALSE;
        }
        
        return true; 
    }

    public function getRawParams(string $path) : dict<string, string> {
        $res = dict<string, string>[]; 
        $split = \explode('/', $path); 

        for($i = 0; $i < \count($this->dynamic); $i++) { 
            $dyn = $this->dynamic[$i];
            if($dyn is nonnull) $res[$dyn] = $split[$i]; 
        }

        return $res; 
    }

}




class Router { 

    private \Catarini $C; 
    public function __construct(\Catarini $parent){ 
        $this->C = $parent; 
    }


 	//
 	// Request state 
 	//

    private bool $MethodNotAllowed = FALSE;

	private ?string $Route;
	/**
	 * Set the route of the current request.  Can only be done once.  
	 * This is used for parallel inclusions
	 */
	public function setRoute(string $Route) : void { 
		if($this->Route != NULL) throw new \catarini\exception\Exception('Route has already been set'); 
		$this->Route = $Route;
	}
	/**
	 * Returns the current route.  If there is none, throws exception.
	 * @throws \catarini\exception\Exception
	 */
	public function getRoute() : string {
		if($this->Route == NULL) throw new \catarini\exception\Exception('No route has been set');
		return $this->Route; 
	}
	public function hasRoute() : bool { return ($this->Route != NULL); }



    //
    // Routing logic
    //


    private ?dict<string, string> $url_params;
    public function _rawurlparams() : ?dict<string, string> { 
        return $this->url_params;
    }

    private function uri_matches(string $route, string $request) : bool { 
        $route      = Str\trim_left($route, '/');
        $request    = Str\trim_left($request, '/'); 

        $spec = new DynamicRouteSpec($route); 

        if($spec->isDynamic() && $spec->matches($request)) { 
            //TODO: Standardize starting and ending with a slash? 
            
            $this->url_params = $spec->getRawParams($request);
            return TRUE; 
        }

        else return $route === $request;
    }

    public function _matches (
            vec<string> $routes, 
            string $method, 
            string $request_uri, 
            string $request_mtd 

    ) : bool  { 

        $request_rsc = \explode('?', $request_uri, 2)[0]; // Remove query string if present 

        foreach($routes as $route) { 
            if($this->uri_matches($route, $request_rsc))
            {
                $this->setRoute($routes[0]); 

                if($method === $request_mtd) return TRUE; 
                else $this->MethodNotAllowed = TRUE;  
                break;
            }
        }
        
        return FALSE; 
    }
 

    private bool $hasMatch = false; 
    /*
     * Tests if the current requests matches the given route and method,
     *  and changes the state of this Router accordingly. 
     *
     * [NEEDS WORK]
     *
     *  Prefers the first route in the list 
     * 
     */
    public function matches(vec<string> $routes, string $method) : bool 
    {
        $request_uri = \catarini\PARTIAL::getRequestURI(); 
        $request_mtd = \catarini\PARTIAL::getRequestMethod(); 

        $matches = $this->_matches($routes, $method, $request_uri, $request_mtd);
        $this->hasMatch = $matches;
        return $matches; 
    }


    //
    // API
    //


    private function route(mixed $route, string $method) : RouteAction 
    { 
        if($this->hasMatch) return new RouteAction($this, $method);

        $routes = NULL;  
        if($route is string) $routes = vec[ $route ]; 
        else $routes = \Facebook\TypeAssert\matches<vec<string>>($route); 

        if(! $this->matches($routes, $method)) return new RouteAction($this, $method); 
        return new RouteRender($this, $method); 
    }



    public function get(mixed $route) : RouteAction { 
        return $this->route($route, 'GET'); 
    }

    public function post(mixed $route) : RouteAction { 
        return $this->route($route, 'POST'); 
    }

    public function done() : void { 
        if($this->hasMatch) return; 
        \catarini\render\xhp_exception(new HttpException(404));
    }

}


//
// Render action chaining 
//

class RouteAction { 

    protected Router $parent;
    protected string $method; 
    public function __construct(Router $parent, string $method) { 
        $this->parent = $parent; 
        $this->method = $method; 
    }

    public function callback((function() : void) $lambda) : Router { return $this->parent; }
    public function xhp((function() : \XHPRoot) $lambda) : Router { return $this->parent; }
}


class RouteRender extends RouteAction { 

    public function xhp((function() : \XHPRoot) $lambda) : Router { 
        \catarini\render\xhp_lambda($lambda); 
    }


    // public function json(dict $json) { 
    //     //TODO: Other
    // }

}
