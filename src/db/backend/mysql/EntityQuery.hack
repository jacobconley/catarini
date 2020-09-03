namespace catarini\db\backend\mysql; 

use catarini\db\querying;
use catarini\db\querying\{ Entity };

use HH\Lib\{ Vec, Str };
use Facebook\{ TypeAssert, TypeCoerce };

enum ACTION : int { 
    SELECT = 0;
};



function prefix(string $prefix, vec<string> $cols) : string { 
    return Vec\map($cols, $x ==> "$prefix.$x") |> Str\join($$, ', '); 
}


class Condition extends querying\Condition { 

    // Query format placeholder for escaped strings
    private ?string $placeholder; 
    public function getPlaceholder() : ?string { return $this->placeholder; }

    private function isNullQuery() : bool { 
        return ($this->getOperation() == '=' && $this->getValue() is null); 
    }


    public function __construct(querying\Condition $condition) { 
        parent::__construct($condition->getColumn(), $condition->getValue(), $condition->getOperation()); 

        // This is, as of now, the only situation which doesn't require a placeholder
        // we must take special care not to return one if it's not necessary, since that would
        //  throw the order of parameters out of whack 
        if(! $this->isNullQuery()) {
            $this->placeholder = type_sql_placeholder($condition->getColumn()->getType()); 
        }
    }

    // can override getOperation here
    // this could allow us to implement things like CONTAINS on platforms that dont have it

    public function sql(?string $prefix = NULL) : string { 
        $op_str     = $this->getOperation(); // may change 
        $col        = $this->getColumn()->getName();
        if($prefix is nonnull) $col = "$prefix.$col"; 

        if($op_str == '=' && $this->getValue() is null) return "$col IS NULL"; 

        $placeholder = $this->placeholder;
        return "$col $op_str $placeholder";
    }

    public function sql_value() : string { 
        return type_sql_literal($this->getColumn()->getType(),  $this->getValue());
    }
}




final class EntityQueryInfo { 

    private string $table;
    private string $table_key; 
    private vec<string> $table_cols; 

    public function table() : string { return $this->table_key; }
    public function table_key() : string { return $this->table_key; }
    public function table_cols() : vec<string> { return $this->table_cols; }


    private ?string $join_table; 
    private ?string $join_key;

    public function isJoined()      : bool { return $this->join_table is nonnull; }
    public function join_table()    : string { return TypeAssert\not_null($this->join_table); }
    public function join_key()      : string { return TypeAssert\not_null($this->join_key); }

    private ?EntityQueryInfo $intermediate;
    public function getIntermediate() : ?EntityQueryInfo { return $this->intermediate; }


    // JOIN table ON table.table_key = join_table.join_key
    public function __construct(string $table, string $table_key, vec<string> $table_cols, ?string $join_table, ?string $join_key, ?EntityQueryInfo $intermediate) { 
        $this->table        = $table;
        $this->table_key    = $table_key;
        $this->table_cols   = $table_cols;
        $this->join_table   = $join_table;
        $this->join_key     = $join_key;
        $this->intermediate = $intermediate; 
    }    
}




type joinlist = vec<EntityQuery<Entity>>;


class EntityQuery<Tm as Entity> extends querying\EntityQuery<Tm> 
{ 

    private EntityQueryInfo $info;
    protected joinlist $preceding;

    public function __construct(Tm $parent, EntityQueryInfo $info, joinlist $previous = vec[]) { 
        parent::__construct($parent); 
        $this->preceding = $previous; 
        $this->info = $info; 
    }


    //
    // The main query building logic is here (whew!) 
    //

    // Reference: https://dev.mysql.com/doc/refman/8.0/en/select.html
    //  https://en.wikipedia.org/wiki/SQL_syntax
    private function genquery(ACTION $action) : string {

        $queries        = $this->preceding;
        $queries[]      = $this; 

        $tables         = vec<EntityQueryInfo>[]; 
        $table_names    = vec<string>[]; 
        foreach($this->preceding as $tbl) { 
            $info = $tbl->info;
            $name = $info->table();
            $intermediate = $info->getIntermediate();

            // This will probably be replaced by aliasing logic 
            if(\in_array($name, $table_names)) { 
                throw new \InvalidOperationException("Recursive queries are not currently supported"); 
            }
            $table_names[] = $name;


            $tables[] = $info;
            if($intermediate is nonnull) $tables[] = $intermediate;
        }
        $this_table = $tables[ \count($tables) - 1 ];




        //
        // FROM clause
        //

        // assuming $tables always contains at least one
        $FROM = Str\format("FROM %s\n", $this_table->table());
        for($i = 1; $i < \count($tables); $i++) { 
            $tbl = $tables[$i];
            $cur_table      = $tbl->table();
            $cur_key        = $tbl->table_key();
            $join_table     = $tbl->join_table();
            $join_key       = $tbl->join_key();

            // Aliasing could eventually be implemented here 
            $FROM .= "JOIN $cur_table ON $cur_table.$cur_key = $join_table.$join_key\n";
        }
        


        //
        // WHERE clause
        //



        $WHERE          = NULL; 

        $conditions =  Vec\map($queries,            $x ==> $x->getConditions()  ) 
                    |> Vec\flatten($$) 
                    |> Vec\map(  $$,                $x ==> new Condition($x)    ); // Converting to this namespace's `Condition` class

        // [!] If parameters show up anywhere else, we'll have to rethink how we use this array 
        // Also, how will it be used downstream.... 
        $PARAMETERS =  Vec\filter(  $conditions,    $x ==> ($x->getPlaceholder() is nonnull)    )
                    |> Vec\map(     $$,             $x ==> $x->sql_value()                      );

        if(\count($conditions) > 0) { 
            $first = $conditions[0]->sql();
            $WHERE = "\nWHERE $first\n";
            $WHERE .= Vec\slice($conditions, 1) 
                    |> Vec\map($$,  $x ==> $x->sql()    ) 
                    |> Vec\map($$,  $x ==> "AND $x\n"   )
                    |> Str\join($$, '');
        }


        //TODO: All the other shit in EntityQuery 

        switch($action) { 
            case ACTION::SELECT:
                $sel = prefix($this_table->table(), $this_table->table_cols()); 
                $query = "SELECT $sel\nFROM $FROM";

                if($WHERE) $query .= $WHERE;

                return $query; 

        }
    }



    // public async function first() : Awaitable<Tm> { 
    //     // Execute and log query here 
    // }
}