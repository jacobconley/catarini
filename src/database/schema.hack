namespace simian\db; 

abstract class Column
{ 
    protected   bool         $nullable           = TRUE; 
    protected   bool         $unique             = FALSE; 
    protected  ?string       $condition; 

    private     bool         $hasDefault         = FALSE;
    protected   mixed        $default; 

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
     */ 
    protected function validate() : void { 
        if(!($this->nullable) && $this->hasDefault && $this->default is null) throw new \LogicException("Non-nullable column has null default"); 
    }

    //
    // Renderer interface 
    //

    abstract public function render_create() : string;
    abstract public function render_select() : string; 
}




interface ColumnFactory { 

    // Schema API 
    public function int()                                           : Column; 
    public function numeric(int $precision, int $scale)             : Column; 
    public function real()                                          : Column; 

    public function string(int $length)                             : Column; 
    public function text()                                          : Column; 

    public function timestamp()                                     : Column; 
    public function datetime()                                      : Column; 

    public function uuid()                                          : Column; 

    public function primary_serial()                                : Column; 
    public function primary_uuid()                                  : Column; 

    // TODO:  Arrays? 
}


class Table { 
    private dict<string, Column> $columns;

    public function __construct(string $name, dict<string, Column> $columns) { 
        $this->columns = $columns;
    }
}

class Database { 
}