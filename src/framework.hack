use catarini\routing\Router; 
use catarini\PARTIAL; 
use namespace Facebook\{ TypeAssert, TypeCoerce };
use HH\Lib\Dict; 

class Catarini { 

    private static ?Catarini $singleton;
    public static function GET() : Catarini { 
        if(Catarini::$singleton) return Catarini::$singleton; 

        $x = new Catarini(); 
        Catarini::$singleton = $x; 
        return $x; 
    }

    public static function SET(Catarini $x) : void { 
        Catarini::$singleton = $x; 
    }

    public function __construct() { 
    }


    //
    //
    //

    // Routing

    private ?Router $router; 
    public function route() : Router { 
        if($this->router) return $this->router; 
        $x = new Router($this);
        $this->router = $x;
        return $x;
    }
    

    <<__Memoize>>
    public function errors() : catarini\render\ErrorHandler { return new catarini\render\ErrorHandler(); }
    

    // 
    // Request
    // 

    <<__Memoize>>
    public function urldict() : dict<string, mixed> { 
        $x = PARTIAL::_GET();
        $rp = $this->route()->_rawurlparams(); 
        if($rp) return Dict\merge($x, $rp); 
        else return $x; 
    }

    <<__Memoize>>
    public function bodydict() : dict<string, mixed> { 
        
        if(PARTIAL::getRequestContentType() == 'application/json') { 
            return json_decode(file_get_contents('php://input'), true);
        }
        return PARTIAL::_POST(); 

    }

    public function urlparams<reify T>() : T { 
        return TypeCoerce\match<T>($this->urldict()); 
    }
    public function bodyparams<reify T>() : T { 
        return TypeAssert\matches<T>($this->bodydict()); 
    }

    public function urlparam<reify T>(string $key) : T { 
        return TypeCoerce\match<T>($this->urldict()[ $key ]); 
    }
    public function bodyparam<reify T>(string $key) : T { 
        return TypeAssert\matches<T>($this->bodydict()[ $key ]);
    }


    // 
    // HTML Stuff
    // 

    <<__Memoize>>
    public function html() : _CatariniXHP { 
        return new _CatariniXHP($this); 
    }


    //TODO: Locales a
}