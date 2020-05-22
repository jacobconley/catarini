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

        $dir = \realpath($dir); 
        if(\file_exists("$dir/.hhconfig"))      return $dir; 
        else if($dir != '/')                    return CONFIG::getRoot("$dir/.."); 
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
            $cfg = TypeAssert\matches<database_mysql>($this->toml['database']);
            return mysql\Database::PoolConnect($cfg['host'],  Shapes::idx($cfg, 'port', 3306),  $cfg['database'], $cfg['username'], $cfg['password']);
        }
        catch(\Exception $e) { 
            \error_log("[!] Could not connect to database"); 
            throw $e; 
        }
    }

}