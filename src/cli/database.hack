namespace catarini\cli; 

use catarini\db; 
use catarini\db\{ DatabaseInstance }; 
use catarini\db\migration\{ MigrationController, ReversibleMigration };

use HH\Lib\{ Vec }; 

final class DatabaseCommand { 

    private DatabaseInstance $DB; 
    private MigrationController $controller;

    public function __construct(DatabaseInstance $DB) { 
        $this->DB = $DB; 
        $this->controller = new MigrationController($DB); 
    }

    public static function connect(?string $name = NULL) : this { 
        return new DatabaseCommand(\catarini\meta\CONFIG::GET()->getDatabase($name));
    }


    // Main methods
    // up
    // down (rollback)

    /**
     *
     */
    public function Migrate(bool $forward) : void { 
        if(! $this->DB->migrations_enabled()) $this->DB->migrations_enable();
        $current = $this->DB->migrations_current();
        
        $delta = $this->controller->delta(TRUE);
        if(\count($delta) == 0) { 
            echo "[-] The database is up-to-date; no work to be done.";
            return; 
        }

        //TODO: Error handling in here?  
        foreach($delta as $x) { 
            $script = $this->controller->load($x); 
            $name = $script->getName();

            if($forward)        $script->up();
            else {
                if($script is ReversibleMigration) $script->down();
                else throw new \catarini\exceptions\InvalidOperation("Attempting to reverse non-reversable migration '$name'");
            }
        }

        // TODO: Gotta update or remove the sql after this
        // then output
        // Schema loading?  
    }


    //TODO: Determine which steps to take - how far behind current migration db is, or what can be rolled back

    //TODO: Migration listing, loading functions 


    // Output section
    // 1) codegen
    // 2) schema information (human readable, so maybe "codegen" namespace / folder should be renamed
    // 3) migration history info so that it can be rolled back somewhere
    /*
        we'll need a spec somewhere... already have somewhat of an idea 
     */



}