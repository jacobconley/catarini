namespace catarini\db\backend\mysql; 

use catarini\db; 
use catarini\db\{ table_creator, table_changer, TableCreatorBlock, TableChangerBlock, Table, Schema };
use catarini\db\migration\{ MigrationVersion, SchemaWriter };

use HH\Lib\{ Str, Vec, Regex }; 
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


    //TODO: Query logging?

    //TODO: Gotta maintain the model here (list of tables, etc) (will need entity relationships later)
    // Since we're doing everything using strings, not type safe, we'll have to make sure that no duplicates get in here
    private vec<Table> $tables = vec[]; 

    public function getSchemaWriter(string $dir) : SchemaWriter { 
        return new SchemaWriter($this->tables, $dir);
    }


    public function addTable(string $name, TableCreatorBlock $block) : this { 
        $name = Str\lowercase($name); 
        if(! Regex\matches($name, re"/[a-zA-Z0-9_]+/")) { 
            throw new db\BadValueException("Invalid table name '$name'");
        }

        // Register table 
        if(Vec\find_first_key($this->tables, $x ==> $x->getName() === $name)) { 
            throw new \catarini\exceptions\InvalidOperation("Duplicate table '$name'"); 
        }

        $thing = new table_creator($name); 
        $block($thing); 
        $cols = $thing->getColumns();
        //TODO: Validate columns (or, do this in the renderer)
        // Maybe this should be a catchall thing 

        $query = "CREATE TABLE ".$this->conn->escapeString($name).' ';

        $types = Vec\map($cols,  $x ==> (new ColumnRender($this->conn, $x))->definition()  );
        $query .= Str\join($types, ', '); 

        Asio\join($this->conn->query($query));
        $this->tables[] = $thing->getTable();
        return $this; 
    }

    public function changeTable(string $name, TableChangerBlock $block) : this { 
        // this one will be fun 
        return $this; 
    }

    public function delTable(string $name) : this { 
        $key = Vec\find_first_key($this->tables, $x ==> $x->getName() === $name); 
        if($key is null) { 
            // DNE Exception??
        }


        $query = "DELETE TABLE $name;";

        Asio\join($this->conn->query($query)); 
        $this->tables = Vec\filter($this->tables, $x ==> $x->getName() != $name); 
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


    public function entity_out(Schema $schema, string $dir, ?string $namespace = NULL) : void { 
        entity_out($schema, $dir, $namespace); 
    }

}