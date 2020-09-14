namespace catarini\db\schema;

use HH\Lib\{ Vec, Str };
use function Facebook\TypeAssert\not_null;


/*
    This will need to be expanded - it'll need to contain information about
        record associations at least.  
    This is also where we can include information like differences in table names
        vs entity class names, stuff like that for backwards compatibility
 */


final class Schema { 

    // public static function VALIDATE(string $name) { 

    // }

    public function __construct(vec<Table> $tables = vec[], vec<Relationship> $relationships = vec[]) { 
        $this->tables = $tables;
        $this->relationships = $relationships;
    }


    private vec<Table> $tables; 

    public function getTables() : vec<Table> { return $this->tables; }

    public function hasTable(string $name) : bool { 
        return (Vec\find_first_key($this->tables, $x ==> $x->getName() === $name) is nonnull); 
    }
    public function getTable(string $name) : Table { 
        return Vec\first_where($this->tables,  $x ==> $x->getName() === $name); 
    }



    private vec<Relationship> $relationships; 



    //
    // API Functions
    //


    public function associate(string $table_name, ?string $alias = NULL) : Relationship { 
        return Relationship::API($this, $table_name, $alias); 
    }


}