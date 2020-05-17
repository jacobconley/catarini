namespace catarini\db\backend\mysql; 

use catarini\db\schema;
use catarini\db\schema\{ TableCreator, TableChanger, TableCreatorBlock, TableChangerBlock };

use HH\Lib\{ Str, Vec }; 
use HH\Asio;

use AsyncMysqlConnection;


class Database implements schema\Database { 

    private AsyncMysqlConnection $conn; 
    private function __construct(AsyncMysqlConnection $conn) {
        $this->conn = $conn; 
     }
    
    public static async function PoolConnect(
        string  $host, 
        int     $port, 
        string  $dbname, 
        string  $user, 
        string  $password, 
        int     $timeout_micros = -1, 
    ): Awaitable<Database>
    { 
        $pool = new \AsyncMysqlConnectionPool(darray[]); 
        return new Database(await $pool->connect($host, $port, $dbname, $user, $password, $timeout_micros));
    }



    // Tables in the model
    // For references in relationships
    // TODO: Model here

    //TODO: Query logging?


    public function addTable(string $name, TableCreatorBlock $block) : this { 

        $thing = new TableCreator(); 
        $block($thing); 
        $cols = $thing->getColumns();
        //TODO: Validate columns

        $query = "CREATE TABLE ".$this->conn->escapeString($name).' ';

        $types = Vec\map($cols,  $x ==> (new ColumnRender($this->conn, $x))->definition()  );
        $query .= Str\join($types, ', '); 

        Asio\join($this->conn->query($query));
        return $this; 
    }

    public function changeTable(string $name, TableChangerBlock $block) : this { 
        // this one will be fun 
        return $this; 
    }

    public function delTable(string $name) : this { 
        $query = "DELETE TABLE $name;";
        Asio\join($this->conn->query($query)); 
        return $this; 
    }

}