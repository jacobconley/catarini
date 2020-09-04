namespace catarini\db\querying;

use catarini\db\{ Database };

abstract class Entity 
{
    public abstract function save()     : void; 
    public abstract function del()      : void; 


    protected Database  $DB;
    protected function __construct(Database $DB) { 
        $this->DB = $DB;
    }


    //TODO: Initializers (create with or without save) 
    //TODO: EntityQuery<this, T> / 


    // protected vec<Column> $columns = vec[]; 

    // public function _sql_column_names(?string $prefix = NULL) : string { 

    //     $cols = Vec\map($this->columns, $x ==> {
    //         $name = $x->getName();
    //         return $prefix is nonnull ? "$prefix.$name" : $name; 
    //     });

    //     return Str\join($cols, ', ');

    // }


    // private string $table;
    // public function __table() : string { return $this->table; }

}