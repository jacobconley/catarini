namespace catarini\db\querying;

use catarini\db\{ Database, Schema };

abstract class Entity 
{
    public abstract function save()     : void; 
    public abstract function del()      : void; 

    protected mixed     $primary_key; 

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

}