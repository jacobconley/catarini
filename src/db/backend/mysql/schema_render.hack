namespace catarini\db\backend\mysql; 

use catarini\db;
use catarini\db\{ Column, ColumnFactory, Type };

use AsyncMysqlConnection;

/*
    Instead of making Column subclasses for each DB type implementation, we use this class as an intermediary
    We do this because the schema must be defined abstractly in the migrations
    However, we can make implementation-specific subclasses for generated code 
 */

class ColumnRender { 
    private AsyncMysqlConnection $conn;
    private Column $col; 
    public function __construct(AsyncMysqlConnection $conn, Column $col) { 
        $this->conn = $conn; 
        $this->col = $col; 
    }


    public function type() : string { 

        switch($this->col->getType()) { 
            case Type::INT:
                return 'INT';

            default:
                throw new \Exception("Bad type"); 
        }

    }

    public function definition() : string { 
        return $this->conn->escapeString($this->col->getName()).' '.$this->type();
    }

}