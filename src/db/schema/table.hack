namespace catarini\db\schema;

use catarini\db\Type;
use catarini\db\schema\Column; 
use HH\Lib\{ Vec, Str };

class Table { 
    private string $name;
    private vec<Column> $columns;

    public function getName() : string { return $this->name; }
    public function getColumns() : vec<Column> { return $this->columns; }

    public function getColumn(string $name) : Column { 
        return Vec\first_where($this->columns, $x ==> $x->getName() === $name); 
    }

    /**
     * Returns the unique column referencing the given table, if exactly one such column exists.  Otherwise, returns NULL. 
     * Used to find the default column for the Schema API when it creates relationships. 
     * @return See above
     */
    public function getColumnReferencing(Table $table) : ?Column { 
        
        $refs = Vec\filter($this->columns, $x ==> { 
            $ref  = $x->getReference();
            return ($ref is nonnull && $ref->getReferencedTable()->getName() === $table->getName());
        });

        return \count($refs) == 1 ? $refs[0] : NULL; // Only returns nonnull if unambiguous 
    }



    public function getPrimaryColumns() : vec<Column> { return Vec\filter($this->columns,  $x ==> $x->isPrimary()  ); }
    public function getUniquePrimary() : ?Column { 
        $primaries = $this->getPrimaryColumns();
        return \count($primaries) == 1 ? $primaries[0] : NULL; 
    }

    public function __forcePrimaryCol() : Column { 
        $col = $this->getUniquePrimary();
        if($col is null) throw new \catarini\exceptions\InvalidOperation("Table $this->name does not have a unique primary key"); 
        return $col;
    }
    public function __forcePrimaryKey() : string { 
        return $this->__forcePrimaryCol()->getName();
    }


    public function __construct(string $name, vec<Column> $columns) {
        $this->name = $name;  
        $this->columns = $columns;
    }
}