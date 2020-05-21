namespace catarini\db\backend\mysql; 

use catarini\db;
use catarini\db\{ Table, Column }; 

use HH\Lib\{ Vec, Str };

// The MySQL implementation of the Model<T> class, that will be subclassed by the codegen
// Consider renaming this stuff to "Entity"? something about "Model" just doesn't sit right with me 

class Model<T> extends db\Model<T> { 


    protected vec<Column> $columns = vec[]; 

    public function _sql_column_names(?string $prefix = NULL) : string { 

        $cols = Vec\map($this->columns, $x ==> {
            $name = $x->getName();
            return $prefix is nonnull ? "$prefix.$name" : $name; 
        });

        return Str\join($cols, ', ');

    }

    // public function __construct()

}