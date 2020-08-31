namespace catarini\db\schema;


//TODO: How to handle primary keys?
// This shit is getting out of hand fast
// I reckon we'll have to restrict the schema classes to the active record model
// or we just have Entities be a separate deal.  what a pain in the ass 


class Table { 
    private vec<Column> $columns;
    private string $name;

    public function getColumns() : vec<Column> { return $this->columns; }
    public function getName() : string { return $this->name; }

    public function __construct(string $name, vec<Column> $columns) {
        $this->name = $name;  
        $this->columns = $columns;
    }
}