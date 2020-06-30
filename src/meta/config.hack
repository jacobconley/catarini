namespace catarini\meta; 

use catarini\db;
use catarini\db\backend\mysql;

use Facebook\{ TypeAssert, TypeCoerce }; 


//
// Config types
//

type database_mysql = shape(
    ?'name'         => string,
     'host'         => string,
    ?'port'         => int,
     'database'     => string,
     'username'     => string,
     'password'     => string
);


//
// Main object
//


class CONFIG { 


    public static ?string $_forced_root;
    public static function _forceRoot(string $root) : void { CONFIG::$_forced_root = $root; }

    <<__Memoize>>
    public static function getRoot(string $dir = __FILE__) : string { 
        $force = CONFIG::$_forced_root;
        if($force) return $force;         

        $last = NULL; 
        $dir = \realpath($dir); 

        while(TRUE) { 
            if(\file_exists("$dir/.hhconfig")) $last = $dir; 
            $dir = \realpath("$dir/.."); 
            if($dir == '/') break;
        }

        if($last != NULL) { return $last; }
        else throw new \catarini\Exception("[!] Could not find root directory");
    }

    <<__Memoize>>
    public static function GET() : CONFIG { return new CONFIG(); }

    public function __construct() { 
        $this->load(); 
    }


    // Default options go here
    private dict<string, nonnull> $toml = dict[];


    private static bool $loaded = FALSE;
    private function load() : void { 
        if(CONFIG::$loaded) throw new \catarini\Exception("[!] Config already loaded"); 
        CONFIG::$loaded = TRUE; 

        $file = CONFIG::getRoot().'/config/catarini.toml';

        if(\file_exists($file)) { 
            $this->toml = \toml\parseFile($file); 
        }
        else { 
            echo "[?] Could not find config/catarini.toml; using defaults"; 
        }
    }


    //
    // Interface
    //


    public function getDatabase(?string $name = NULL) : db\DatabaseInstance { 
        //TODO: Multiple names
        // for now, the first one 

        //TODO: Different types 


        try { 
            $vec = TypeAssert\matches<vec<database_mysql>>($this->toml['database']);
            if(\count($vec) == 0)throw new \catarini\exceptions\Config("`database` array is empty"); 
            //TODO: Move this typa stuff to another function I think 

            $cfg = $vec[0];
            return mysql\Database::PoolConnect($cfg['host'],  Shapes::idx($cfg, 'port', 3306),  $cfg['database'], $cfg['username'], $cfg['password']);
        }
        catch(\Exception $e) { 
            \error_log("[!] Could not connect to database"); 
            throw $e; 
        }
    }

}