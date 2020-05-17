namespace catarini\db\migration;

use catarini\db\{ schema };
use catarini\db\schema\{ TableCreatorBlock, TableChangerBlock }; 
use catarini\db\migration\actions;
use catarini\db\migration\actions\Action; 

/*
 * This wraps around schema\Database to provide a reversible class with the same API 
 */ 

class API implements schema\Database
{ 

    private schema\Database $DB;
    public function __construct(schema\Database $DB) { 
        $this->DB = $DB;
    }
 

    private bool $reversible = TRUE; 
    private vec<Action> $Actions = vec[]; 
    private function addAction(Action $a) : void { 
        if(! $a->isReversible()) $this->reversible = FALSE; 
    } 


    public function _up() : void { 
        foreach($this->Actions as $action) $action->up(); 
    }
    public function _down() : void { 
        if(! $this->reversible) throw new \catarini\Exception("Attempting to revert an irreversible migration"); 
        foreach($this->Actions as $action) $action->down(); 
    }


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

}