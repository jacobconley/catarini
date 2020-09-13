/*

    This file does all of the SQL rendering for Entity queries 


*/

namespace catarini\db\backend\mysql; 

use catarini\db\querying;
use catarini\db\querying\{ Entity, EntityQueryTarget };
use catarini\db\schema\Table;
use catarini\log; 

use HH\Lib\{ Vec, Str };
use Facebook\{ TypeAssert, TypeCoerce };

use AsyncMysqlConnection; 


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
        parent::__construct($condition->getTable(), $condition->getColumn(), $condition->getValue(), $condition->getOperation()); 

        // This is, as of now, the only situation which doesn't require a placeholder
        // we must take special care not to return one if it's not necessary, since that would
        //  throw the order of parameters out of whack 
        if(! $this->isNullQuery()) {
            $this->placeholder = type_sql_placeholder($condition->getColumn()->getType()); 
        }
    }

    // can override getOperation here
    // this could allow us to implement things like CONTAINS on platforms that dont have it

    /**
     * Renders this condition to MySQL.  
     * Funky behavior:  Uses placeholders if the Async connection isn't given.  This is for ease of testing, but it's stupid as shit and 
     *  needs to be either greatly clarified or changed altogether.
     *
     * @param $conn An `AsyncMysqlConnection` object, used to escape a string value if needed.  SQL will be rendered with placeholders if this is left NULL. 
     * @return The rendered SQL string, with no whitespace on either end.  
     */
    public function sql(?AsyncMysqlConnection $conn = NULL) : string { 
        $op_str     = $this->getOperation(); // may change 
        $col        = $this->getColumn()->getName();
        // $prefix     = $prefix ?? $this->getTable()->getName();
        // if($prefix is nonnull) $col = "$prefix.$col"; 
        $prefix     = $this->getTable()->getName();
        $col        = "$prefix.$col";

        if($op_str == '=' && $this->getValue() is null) return "$col IS NULL"; 
        
        $placeholder = $this->placeholder;
        $operand    = $conn is null ? $placeholder : type_sql_literal($this->getColumn()->getType(), $this->getValue(), $conn);
        return "$col $op_str $placeholder";
    }

}







class EntityQuery<Tm as Entity> extends querying\EntityQuery<Tm> 
{ 





    //
    //
    // The main query building logic is here (whew!) 
    //
    //





    // SELECT clause

    /**
     * @return The SELECT clause, ending with \n 
     */
    public function __SELECT() : string { 
        $tbl = $this->getTarget();
        $cols = Vec\map($tbl->getColumns(),  $x ==> $x->getName())
                |> prefix($tbl->getName(), $$);

        return "SELECT $cols\n";
    }



    //
    // FROM clause
    //


    // Maybe this will have to be tested eventually? 
    private function __FROM_steps() : vec<EntityQueryTarget> { 
        $targets        = vec<EntityQueryTarget>[]; 
        $table_names    = vec<string>[]; 
        foreach(Vec\concat($this->preceding, vec[$this]) as $tbl) { 
            $info = $tbl->info;
            $int    = $info->intermediate;
            
            foreach(vec[ $info, $int ] as $q) { 
                if($q is null) continue; 


                // This will probably be replaced by aliasing logic 
                $name = $q->getTarget()->getName();
                if(\in_array($name, $table_names)) { 
                    throw new \InvalidOperationException("Recursive queries are not currently supported"); 
                }
                $table_names[] = $name;

                
                $targets[] = $q; 
            }

        }


        return $targets;         
    }

    private function join_clause(EntityQueryTarget $target) : string { 
        $j          = $target->getJoin();
        $join_table = $j[1]->getName();
        $join_key   = $j[2]; 

        $tbl        = $target->getTable();
        $cur_key    = $j[0];
        $cur_table  = $tbl->getName();

        return "JOIN $join_table ON $cur_table.$cur_key = $join_table.$join_key\n";
    }

    /**
     * @return The FROM clause, beginning and ending with \n
     */
    public function __FROM() : string { 

        // assuming $tables always contains at least one
        $tables = $this->__FROM_steps();
        assert(\count($tables) > 0);


        // Aliasing could eventually be implemented here 

        $this_step = $tables[0];
        $FROM = Str\format("\nFROM %s\n", $this_step->getTable()->getName());
        if($this_step->isJoined()) $FROM .= $this->join_clause($this_step); 

        for($i = 1; $i < \count($tables); $i++) { 
            $step       = $tables[$i];
            assert($step->isJoined());
            $FROM .= $this->join_clause($step); 
        }

        return $FROM; 
    }





    //
    // WHERE clause
    //
    /**
     * @param  
     * @return the WHERE clause, beginning and ending with \n 
     */
    public function __WHERE(?AsyncMysqlConnection $conn = NULL) : ?string { 
        $queries        = $this->preceding;
        $queries[]      = $this; 


        $WHERE          = NULL; 

        $conditions =  Vec\map($queries,            $x ==> $x->getConditions()  ) 
                    |> Vec\flatten($$) 
                    |> Vec\map(  $$,                $x ==> new Condition($x)    ); // Converting to backend\mysql\Condition

        if(\count($conditions) > 0) {    
            $first = $conditions[0]->sql($conn);
            $WHERE = "\nWHERE $first\n";
            $WHERE .= Vec\slice($conditions, 1) 
                    |> Vec\map($$,  $x ==> $x->sql()    ) 
                    |> Vec\map($$,  $x ==> "AND $x\n"   )
                    |> Str\join($$, '');
        }

        return $WHERE; 
    }



    // Reference: https://dev.mysql.com/doc/refman/8.0/en/select.html
    //  https://en.wikipedia.org/wiki/SQL_syntax


    //
    //
    // API
    //
    //

    private function db() : AsyncMysqlConnection { 
        $db = \Catarini::GET()->db(); 
        if($db is /* backend\mysql */ Database) return $db->getMySQL(); 
        else throw new \catarini\exceptions\InvalidEnvironment("Current database is not MySQL");
        // In the future, the above error will likely be due to a change of database without regenerating code - 
        //  the error message should be changed to reflect that 
    }




    // public async function first() : Awaitable<Tm> { 
    //     $SELECT     = $this->__SELECT();
    //     $FROM       = $this->__FROM();
    //     $WHERE      = $this->__WHERE(); 

    //     $query      = $SELECT.$FROM.$WHERE."LIMIT 1";
    //     log\query($query); 

    //     // $this->db()->queryf($query, $this->)
    // }
}