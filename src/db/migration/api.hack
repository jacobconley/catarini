namespace catarini\db\migration;

use catarini\db;
use catarini\db\Database;
use catarini\db\{ TableCreatorBlock, TableChangerBlock }; 
use catarini\db\migration\actions;
use catarini\db\migration\actions\Action; 

/*
 * This wraps around schema\Database to provide a reversible class with the same API 
 */ 


// maybe rename this irreversible migration
abstract class ManualMigration implements Database { 

    protected db\Database $DB;
    protected string $name;
    public function __construct(Database $DB, string $name) { 
        $this->DB = $DB;
        $this->name = $name; 
    }

    public function getName() : string { return $this->name; }

    public function isReversible() : bool { return FALSE; }

    public abstract function up() : void; 

}

abstract class ReversibleMigration extends ManualMigration { 

    public function isReversible() : bool { return TRUE; }

    public abstract function down() : void; 

}



abstract class AutomaticMigration extends ReversibleMigration
{ 
 

    private bool $reversible = TRUE; 
    public function isReversible() : bool { return $this->reversible; }


    private vec<Action> $Actions = vec[]; 
    private function addAction(Action $a) : void { 
        if(! $a->isReversible()) $this->reversible = FALSE; 
        $this->Actions[] = $a; 
    } 


    public function up() : void { 
        foreach($this->Actions as $action) $action->up(); 
    }
    public function down() : void { 
        if(! $this->reversible) throw new \catarini\Exception("Attempting to revert an irreversible migration '$this->name'"); 
        foreach($this->Actions as $action) $action->down(); 
    }

    public abstract function load() : void; 


    // Implemented actions


    public function addTable(string $name, TableCreatorBlock $block) : this { 
        $this->addAction(new actions\addTable($this->DB, $name, $block));
        return $this; 
    }

    public function changeTable(string $name, TableChangerBlock $block) : this { 
        $this->addAction(new actions\changeTable($this->DB, $name, $block)); 
        return $this; 
    }

    public function delTable(string $name) : this { 
        $this->addAction(new actions\delTable($this->DB, $name));
        return $this; 
    }



    //
    // Private accessors
    //
    public function _getActions() : vec<Action> { return $this->Actions; }

}