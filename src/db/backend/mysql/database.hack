namespace catarini\db\backend\mysql; 

use catarini\db; 
use catarini\db\{ table_creator, table_changer, TableCreatorBlock, TableChangerBlock };
use catarini\db\migration\MigrationVersion;

use HH\Lib\{ Str, Vec }; 
use HH\Asio;

use Facebook\TypeAssert; 

use AsyncMysqlConnection;


class Database implements db\DatabaseInstance { 

    private AsyncMysqlConnection $conn; 
    private function __construct(AsyncMysqlConnection $conn) {
        $this->conn = $conn; 
     }
    
    public static function PoolConnect( string  $host, 
                                        int     $port, 
                                        string  $dbname, 
                                        string  $user, 
                                        string  $password, 
                                        int     $timeout_micros = -1  ): Database
    { 
        $pool = new \AsyncMysqlConnectionPool(darray[]); 
        return new Database(Asio\join($pool->connect($host, $port, $dbname, $user, $password, $timeout_micros)));
    }



    // Tables in the model
    // For references in relationships
    // TODO: Model here

    //TODO: Query logging?


    public function addTable(string $name, TableCreatorBlock $block) : this { 

        $thing = new table_creator(); 
        $block($thing); 
        $cols = $thing->getColumns();
        //TODO: Validate columns (or, do this in the renderer)

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




    //
    // Instance / implementation
    //

    public function migrations_enabled() : bool 
    { 
        $query = "SHOW TABLES LIKE '_migrations'"; 

        $res = Asio\join($this->conn->query($query)); 
        $num = $res->numRows();
        
        \HH\invariant($num < 2, "There should only be one table LIKE _migrations"); 
        return $num == 1; 
    }

    public function migrations_enable() : void 
    { 
        $query = "CREATE TABLE _migrations (timestring VARCHAR(32) PRIMARY KEY)";

        Asio\join($this->conn->query($query)); 
    }


    public function migrations_current() : ?MigrationVersion
    {
        // Should we add logic for a DNE _migrations?  Idk it'll throw an error anyways 
        $query = "SELECT timestring FROM _migrations ORDER BY current DESC LIMIT 2"; 

        $res = Asio\join($this->conn->query($query)); 
        if($res->numRows() == 0) return NULL; 
        
        $vec = $res->vectorRows();
        $cur = $vec[0][0];
        $prv = $res->numRows() == 2 ? $vec[1][0] : NULL; 

        return new MigrationVersion(TypeAssert\not_null($cur), $prv);
    }

}