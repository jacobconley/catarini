namespace catarini\db;

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
