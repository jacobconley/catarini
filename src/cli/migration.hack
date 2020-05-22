namespace catarini\cli; 

use catarini\db; 
use catarini\db\{ DatabaseInstance }; 

class Migration { 

    private DatabaseInstance $DB; 
    public function __construct(DatabaseInstance $DB) { 
        $this->DB = $DB; 
    }

    public static function connect(?string $name = NULL) : Migration { 
        return new Migration(\catarini\meta\CONFIG::GET()->getDatabase($name));
    }


    // Main methods
    // up
    // down (rollback)


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