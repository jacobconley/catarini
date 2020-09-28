namespace catarini\meta; 

use catarini\db;
use catarini\db\backend\mysql;
use catarini\db\codegen\Codegen; 

use Facebook\{ TypeAssert, TypeCoerce }; 
use HH\Lib\{ Vec, Str, Dict };


//
// Config types
//

type database_mysql = shape(
    ?'name'         => string,
     'host'         => string,
    ?'port'         => int,
     'database'     => string,
     'username'     => string,
     'password'     => string,

    ?'entities'     => shape (
        ?'namespace'    => string, 
        ?'dir'          => string, 
    )
);


//
// Main object
//


class CONFIG { 


    private static ?string $_forced_root;
    public static function _forceRoot(string $root) : void { CONFIG::$_forced_root = $root; }

    /**
     * Returns the root project directory - defined as the directory containing .hhconfig
     */
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
    private dict<string, nonnull> $toml = dict[
        'database'  => vec[]
    ];


    private static bool $loaded = FALSE;
    private function load() : void { 
        if(CONFIG::$loaded) throw new \catarini\Exception("[!] Config already loaded"); 
        CONFIG::$loaded = TRUE; 

        $file = CONFIG::getRoot().'/config/catarini.toml';

        if(\file_exists($file)) { 
            $this->toml = Dict\merge($this->toml, \toml\parseFile($file));
        }
        else { 
            echo "[?] Could not find config/catarini.toml; using defaults"; 
        }
    }


    //
    // Interface
    //



    private function getDBConfig(?string $name) : database_mysql { 
        //TODO: Multiple names
        // for now, the first one 
        
        $vec = TypeAssert\matches<vec<database_mysql>>($this->toml['database']);
        if(\count($vec) == 0) throw new \catarini\exceptions\Config("`database` array is empty"); 
        //TODO: Move this typa stuff to another function I think 

        $cfg = $vec[0];
        return $cfg; 
    }


    public function getDatabase(?string $name = NULL) : db\DatabaseInstance { 

        //TODO: Different types 

        try { 
            $cfg = $this->getDBConfig($name);
            return mysql\Database::PoolConnect($cfg['host'],  Shapes::idx($cfg, 'port', 3306),  $cfg['database'], $cfg['username'], $cfg['password']);
        }
        catch(\Exception $e) { 
            \error_log("[!] Could not connect to database"); 
            throw $e; 
        }
    }

    /**
     * Creates a codegen object for the configuration of the given database.
     */
    public function getDatabaseCodegen(?string $name = NULL) : Codegen { 
        $cfg = $this->getDBConfig($name); 


        $root = CONFIG::getRoot();
        $pvtdir = "$root/.catarini/include/";

        $namespace = NULL;
        $dir = NULL;
        if(Shapes::keyExists($cfg, 'entities')) {
            $ent = $cfg['entities'];
            $namespace  = Shapes::idx($ent, 'namespace');
            $dir        = Shapes::idx($ent, 'dir'); 
        }



        return new Codegen($name, $namespace,   $dir  ??  "$root/src/db"  , NULL, $pvtdir);
    }

}