namespace catarini\db; 

use HH\Lib\Vec; 

class table_creator { 

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

    public function add(string $name) : column_changer{
        return new column_changer($this, $name);
    }


    public function del(string $name) : void { 
        $this->deleted[] = $name; 
    }
}

class table_changer extends table_creator { 

    public function change(string $name) : column_changer { 
        $this->delColumn($name);
        return new column_changer($this, $name);
    }

}


class column_changer { 

    private table_creator $parent;
    private string $name;
    public function __construct(table_creator $parent, string $name) { 
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

type TableCreatorBlock = (function(table_creator): void); 
type TableChangerBlock = (function(table_changer): void); 