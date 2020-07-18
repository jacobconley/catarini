namespace catarini\db; 

use HH\Lib\Vec; 

class table_creator { 

    protected vec<Column> $cols = vec[];
    protected string $name; 

    public function __construct(string $name, ?vec<Column> $cols = NULL) { 
        $this->name = $name;
        if($cols) $this->cols = $cols; 
    }

    // maybe these should be private? to emphasize add(), the only thing that matters 
    public function getColumns() : vec<Column> { return $this->cols; }
    protected function getColumn(string $name) : Column { 
        return Vec\filter($this->cols, $x ==> $x->getName() === $name)[0];
    }

    public function getTable() : Table { 
        return new Table($this->name, $this->cols); 
    }

    // These functions add columns and shit 

    public function add(string $name) : column_changer{
        if(Vec\find_first_key($this->cols, $col ==> $col->getName() === $name) is nonnull) throw new \catarini\Exception("Defining a duplicate column");
        return new column_changer($this, $name);
    }


    //
    // Private APIS
    //


    public function _reg<T as Column>(string $name, T $col, ?int $index) : T {  
        
        if($index is nonnull) { 
            $this->cols[$index]     = $col; 
        } else {  
            $this->cols[]           = $col; 
        }
        return $col; 
    }

    // Test/Debug
}

class table_changer extends table_creator { 

    protected vec<string> $deletedNames = vec[]; 
        // We'll need this for migration API schtuf
        // so that the ALTER TABLE can include DROP COLUMN directives 

    protected vec<string> $changedNames = vec[]; 



    //TODO: How to handle no-such-column errors?

    public function del(string $name) : void { 
        $this->deletedNames[] = $name; 
        $this->cols =   Vec\first_key($this->cols, $x ==>  $x->getName() === $name  )  |>  Vec\without($this->cols, $$); 
    }

    public function change(string $name) : column_changer { 
        $i = Vec\first_key($this->cols, $x ==> $x->getName() === $name); 
        $this->changedNames[] = $name; 
        return new column_changer($this, $name, $i);
    }


    //
    // Private test/debug
    //

    public function _getDeleted() : vec<string> { return $this->deletedNames; }
    public function _getChanged() : vec<string> { return $this->changedNames; } 

}


class column_changer { 

    private table_creator $parent;
    private string $name;
    private ?int $index;
    public function __construct(table_creator $parent, string $name, ?int $index = NULL) { 
        $this->parent   = $parent;
        $this->name     = $name; 
        $this->index    = $index; 
    }

    // Schema API 
    public function int()  : Column { 
        return $this->parent->_reg($this->name, new Column(Type::INT, $this->name), $this->index);
    }

    // // public function numeric(, int $precision, int $scale) : Column { 
    // //     return $this->reg($name, new Column(Type::NUMERIC, $name)); 
    // // }
    // public function real() : Column { 
    //     return $this->reg($name, new Column(Type::REAL, $name)); 
    // }

    // public function string(int $length)                             : Column; 
    // public function text()                                          : Column; 

    // public function timestamp()                                     : Column; 
    // public function datetime()                                      : Column; 

    // public function uuid()                                          : Column; 

    // public function primary_serial()                                : Column; 
    // public function primary_uuid()                                  : Column; 

    // TODO:  Arrays? 

    //TODO: Relationships
}

type TableCreatorBlock = (function(table_creator): void); 
type TableChangerBlock = (function(table_changer): void); 