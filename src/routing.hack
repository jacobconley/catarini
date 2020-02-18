namespace catarini\routing; 

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
		if($this->Route != NULL) throw new \catarini\exception\Exception($this->C, 'Route has already been set'); 
		$this->Route = $Route;
	}
	/**
	 * Returns the current route.  If there is none, throws exception.
	 * @throws \catarini\exception\Exception
	 */
	public function getRoute() : string {
		if($this->Route == NULL) throw new \catarini\exception\Exception($this->C, 'No route has been set');
		return $this->Route; 
	}
	public function hasRoute() : bool { return ($this->Route != NULL); }



    //
    // Routing logic
    //



    private function uri_matches(string $route, string $request) : bool { 
        return $route === $request; //TODO: Params
    }
 

    private function matches(vec<string> $routes, string $method) : bool 
    {
        $request_uri = \catarini\PARTIAL::getRequestURI(); 
        $request_mtd = \catarini\PARTIAL::getRequestMethod(); 
        $request_rsc = \explode('?', $request_uri, 2)[0]; // Remove query string if present 

        $match = FALSE; 
        foreach($routes as $route) { 
            if($this->uri_matches($route, $request_uri)){ $match = TRUE; break; }
        }
        
        if($match) { 
            $this->setRoute($routes[0]); 

            if($method === $request_mtd) return TRUE; 
            else $this->MethodNotAllowed = TRUE; 
        }

        return FALSE; 
    }


    //
    // API
    //


    private function route(mixed $route, string $method) : Route 
    { 
        $routes = NULL;  
        if($route is string) $routes = vec[ $route ]; 
        else $routes = \Facebook\TypeAssert\matches<vec<string>>($route); 

        if(! $this->matches($routes, $method)) return new Route($this, $method); 
        return new RouteRender($this, $method); 
    }



    public function get(mixed $route) : Route { 
        return $this->route($route, 'GET'); 
    }

    public function post(mixed $route) : Route { 
        return $this->route($route, 'POST'); 
    }

}


//
// Render action chaining 
//

class Route { 

    protected Router $parent;
    protected string $method; 
    public function __construct(Router $parent, string $method) { 
        $this->parent = $parent; 
        $this->method = $method; 
    }

    public function callback((function() : void) $lambda) : Router { return $this->parent; }
    public function xhp((function() : \XHPRoot) $lambda) : Router { return $this->parent; }
}


class RouteRender extends Route { 

    public function xhp((function() : \XHPRoot) $lambda) : Router { 
        \catarini\render\html($lambda); 
    }


    // public function json(dict $json) { 
    //     //TODO: Other
    // }

}
