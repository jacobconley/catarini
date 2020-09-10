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

    public function __construct(string $name, vec<Column> $columns, ?string $primary_key = NULL) {
        $this->name = $name;  

        $columns = $columns; 
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