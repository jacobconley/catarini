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


    public function delta() : vec<string> { 
        $available = $this->available();
        $count = \count($available);
        if($count == 0) return vec[]; 

        $version = $this->DB->migrations_current();
        if($version is null) return $available; // migration table exists, but none have been applied 

        $migration = $version->after;  
        $x = Vec\find_first_key($available, $x ==> $x === $migration); 
        if($x is null) throw new \catarini\exceptions\InconsistentState("The current database version is unknown to Catarini.");

        return Vec\slice($available, $count - $x - 1); 
    }


    // also, should error handling be standardized across the various CLI commands? probably 
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
