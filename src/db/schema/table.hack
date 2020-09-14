namespace catarini\db\schema;

use catarini\db\Type;
use catarini\db\schema\Column; 
use HH\Lib\{ Vec, Str };

class Table { 
    private string $name;
    private vec<Column> $columns;
    private string $primary;

    public function getName() : string { return $this->name; }
    public function getColumns() : vec<Column> { return $this->columns; }
    public function getPrimaryKey() : string { return $this->primary; }

    <<__Memoize>>
    public function getPrimaryColumn() : Column { 
        return Vec\first_key($this->columns,   $x ==> $x->getName() === $this->primary   ) |> $this->columns[$$];
    }

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



    public function __construct(string $name, vec<Column> $columns, ?string $primary_key = NULL) {
        $this->name = $name;  
 
        if($primary_key is null) { 
            // the $primary_key default null should probably be removed.  this is dev laziness to migrate existing tests 
            $primary_key = 'id';
            $this->primary = $primary_key;
            $this->columns = Vec\concat(vec[new Column(Type::INT, $primary_key)], $columns);
        }
        else {
            $this->primary = $primary_key;
            $this->columns = $columns;
        }

    }
}