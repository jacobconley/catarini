namespace catarini\db\migration\actions;

use catarini\db\{ Database, TableCreatorBlock, TableChangerBlock  }; 

// These are the underlying classes that provide reversible functionality for the Migration API 
// It's super boilerplate... super automatable... worth looking into 

abstract class Action { 
    public abstract function up()       : void; 
    public function down()              : void { }
    
    protected bool $reversible = FALSE; 
    public function isReversible() : bool { return $this->reversible; }
}



class addTable extends Action { 

    private Database $DB;
    private string $name; 
    private TableCreatorBlock $block; 
    public function __construct(Database $DB, string $name, TableCreatorBlock $block) { 
        $this->DB = $DB;
        $this->name = $name; 
        $this->block = $block; 
    }

    public function up() : void { $this->DB->addTable($this->name, $this->block); }
    public function down() : void { $this->DB->delTable($this->name); }

}

class changeTable extends Action { 

    private Database $DB;
    private string $name; 
    private TableChangerBlock $block; 
    public function __construct(Database $DB, string $name, TableChangerBlock $block) { 
        $this->DB = $DB;
        $this->name = $name; 
        $this->block = $block; 
    }

    public function up() : void { $this->DB->changeTable($this->name, $this->block); }

}


class delTable extends Action { 
    
    private Database $DB;
    private string $name; 
    public function __construct(Database $DB, string $name) { 
        $this->DB = $DB;
        $this->name = $name; 
    }

    public function up() : void { $this->DB->delTable($this->name); }
}