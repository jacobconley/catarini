namespace catarini\db\migration;

use HH\Lib\{ Regex, Vec }; 
use Facebook\TypeAssert;

use \catarini\db\DatabaseInstance; 

class MigrationVersion { 
    public ?string $before;
    public string $after;
    public function __construct(string $current, ?string $before) { 
        $this->before   = $before;
        $this->after    = $current; 
    }
}

class MigrationController { 

    private DatabaseInstance $DB; 
    public function __construct(DatabaseInstance $DB) { 
        $this->DB = $DB; 
    }


    // public function currentMigration() : string { 

    // }

    <<__Memoize>>
    public function available() : vec<string> { 
        $res = vec[];
        $dir = \catarini\meta\CONFIG::getRoot();

        $scan = \scandir($dir); 
        foreach($scan as $file) 
        { 
            $match = Regex\first_match($file, re"/^migration_(\d+)\.hack$/");
            if($match === NULL) continue; 

            $res[] = $match[1]; 
        }

        return $res; 
    }


    /**
     * Returns all of the migrations between the current one and the target
     * @param $up TRUE if migrating forward, FALSE if rolling back
     * @throws \catarini\exceptions\InconsistentState if a specified version does not exist
     * @throws \catarini\exceptions\InvalidOperation if attempting a moot rollback         
     */
    public function delta(bool $up) : vec<string> { 
        $available = $this->available();
        $version = $this->DB->migrations_current();

        return $this->_delta($up, $available, $version);
    }
    public function _delta(bool $up, vec<string> $available, ?MigrationVersion $version) : vec<string> { 
        $count = \count($available);
        if($count == 0) return vec[]; 

        //TODO: What if a rollback comes across an irreversible migration? 
        // It shouldn't proceed past it by default
        // but how would that work with our versioning scheme 
        
        if($up ) { 
            if($version is null) return $available;

            $target = $version->after;

            $x = Vec\find_first_key($available, $x ==> $x === $target); 
            if($x is null) throw new \catarini\exceptions\InconsistentState("The current database version '$target' is unknown to Catarini.");
            return Vec\slice($available, $x + 1); 
        }
        else { 
            if($version is null) throw new \catarini\exceptions\InvalidOperation("There is no migration to undo"); 

            if($version->before is null) return Vec\reverse($available); // No previous version; roll back everything

            $ini = Vec\find_first_key($available, $x ==> $x === $version->after); 
            $fin = Vec\find_first_key($available, $x ==> $x === $version->before); 
            if($ini is null) throw new \catarini\exceptions\InconsistentState("The current version '$version->after' is unknown to Catarini."); 
            if($fin is null) throw new \catarini\exceptions\InconsistentState("The previous version '$version->before' is unknown to Catarini.");
            
            return   Vec\slice($available, $fin + 1,  $ini - $fin)  |>  Vec\reverse($$); 
        }
    }


    // also, should error handling be standardized across the various CLI commands? probably 
    // TODO: Namespacing here?? 
    public function load(string $migration) : ManualMigration
    { 
        // Reflection stuff here 

        $classname  = "migration_$migration"; 

        $class      = new \ReflectionClass($classname); 
        $instance   = $class->newInstance($this->DB);


        if($instance is AutomaticMigration) { 
            $instance->load(); 
        }

        return $instance; 
    }

}
