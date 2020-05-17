namespace catarini\db\schema;

use HH\Lib\Vec; 

enum Type : int { 
    INT         = 0;
    NUMERIC     = 1;
    REAL        = 2; 

    STRING      = 10;
    TEXT        = 12;

    TIMESTAMP   = 20;
    DATETIME    = 21; 

    UUID        = 30; 
}

class Column 
{ 
    protected string $name;
    protected Type $type;
    public function __construct(Type $type, string $name) { 
        $this->name = $name;
        $this->type = $type; 
    }


    protected   bool         $nullable           = TRUE; 
    protected   bool         $unique             = FALSE; 
    protected  ?string       $condition; 

    private     bool         $hasDefault         = FALSE;
    protected   mixed        $default; 

    public function getName() : string { return $this->name; }
    public function getType() : Type { return $this->type; }

    public function isNullable() : bool { return $this->nullable; }
    public function isUnique() : bool { return $this->unique; }

    public function hasDefault() : bool { return $this->hasDefault; }

    //
    // API 
    //

    public function nonnull() : this { $this->nullable = FALSE; return $this; }
    public function unique() : this { $this->unique = TRUE; return $this; }

    public function default(mixed $def) : this { 
        $this->hasDefault = TRUE; 
        $this->default = $def; 
        return $this; 
    }

    //TODO:  Generalize these

    public function check(string $condition) : this { 
        $this->condition = $condition;
        return $this; 
    }

    //
    // Core
    // 

    /**
     * This should be called before any render
     * ?????????/
     */ 
    protected function validate() : void { 
        if(!($this->nullable) && $this->hasDefault && $this->default is null) throw new \LogicException("Non-nullable column has null default"); 
    }

}


class TableCreator { 

    protected vec<string> $names = vec[]; 
    protected vec<Column> $cols = vec[];
    protected vec<string> $deleted = vec[]; 
        // We'll need this for migration API schtuf
        // so that 

    public function getColumns() : vec<Column> { return $this->cols; }

    protected function getColumn(string $name) : Column { 
        return Vec\filter($this->cols, $x ==> $x->getName() === $name)[0];
    }

    protected function delColumn(string $name) : void { 
        $this->cols = Vec\filter($this->cols, $x ==> $x->getName() !== $name);
    }

    public function _reg<T as Column>(string $name, T $col) : T { 
        if(\in_array($name, $this->names)) throw new \catarini\Exception("Defining a duplicate column"); 
        $this->names[] = $name; 
        $this->cols[] = $col; 
        return $col; 
    }




    // These functions add columns and shit 

    public function add(string $name) : ColumnChanger{
        return new ColumnChanger($this, $name);
    }


    public function del(string $name) : void { 
        $this->deleted[] = $name; 
    }
}

class TableChanger extends TableCreator { 

    public function change(string $name) : ColumnChanger { 
        $this->delColumn($name);
        return new ColumnChanger($this, $name);
    }

}


class ColumnChanger { 

    private TableCreator $parent;
    private string $name;
    public function __construct(TableCreator $parent, string $name) { 
        $this->parent   = $parent;
        $this->name     = $name; 
    }

    // Schema API 
    public function int()  : Column { 
        return $this->parent->_reg($this->name, new Column(Type::INT, $this->name));
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

type TableCreatorBlock = (function(TableCreator): void); 
type TableChangerBlock = (function(TableChanger): void); 