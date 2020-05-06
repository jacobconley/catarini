namespace catarini;

class CONFIG { 

    <<__Memoize>>
    public static function findRoot(string $dir = __FILE__) : string { 
        $dir = \realpath($dir); 
        if(\file_exists("$dir/..hhconfig"))     return $dir; 
        else if($dir != '/')                    return CONFIG::findRoot("$dir/.."); 
        else throw new \catarini\Exception("[!] Could not find root directory");
    }

    <<__Memoize>>
    public static function GET() : CONFIG { return new CONFIG(); }

    public function __construct() { 
        $this->load(); 
    }


    private static bool $loaded = FALSE;
    private function load() : void { 
        if(CONFIG::$loaded) throw new \catarini\Exception("[!] Config already loaded"); 
        CONFIG::$loaded = TRUE; 

        $file = CONFIG::findRoot().'/config/catarini.toml';

        if(\file_exists($file)) { 
            $toml = \toml\parseFile($file); 
        }
        else { 
            echo "[?] Could not find config/catarini.toml; using defaults"; 
        }
    }
}