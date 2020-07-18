namespace catarini\cli; 

use catarini\db; 
use catarini\db\{ DatabaseInstance }; 
use catarini\db\migration\{ MigrationController, ReversibleMigration, SchemaWriter };

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

        // TODO: Schema loading?  
        // Will need to be done for the output 

        //TODO: Error handling in here?  
        foreach($delta as $x) { 
            $script = $this->controller->load($x); 
            $name = $script->getName();

            // Uncomment this when it's ready to go!

            // if($forward)        $script->up();
            // else {
            //     if($script is ReversibleMigration) $script->down();
            //     else throw new \catarini\exceptions\InvalidOperation("Attempting to reverse non-reversable migration '$name'");
            // }
        }

        //TODO: Dirs, make this retrievable from the migration controller?  I guess
        // why even have a separate migration controller?  this will need to be documented
        // $writer = $this->DB->getSchemaWriter($dir)
    } 


    // Output section
    // 1) codegen
    // 2) schema information (human readable, so maybe "codegen" namespace / folder should be renamed
    // 3) migration history info so that it can be rolled back somewhere
    /*
        we'll need a spec somewhere... already have somewhat of an idea 
     */

}