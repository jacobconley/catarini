namespace catarini\db\backend\mysql; 

use catarini\db\schema;
use catarini\db\schema\{ Column, ColumnFactory, Type };

use AsyncMysqlConnection;

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