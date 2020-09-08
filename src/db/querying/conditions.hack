namespace catarini\db\querying;

use namespace catarini\db;
use catarini\db\schema\{ Table, Column };


/*
    The idea behind this one was to have a series of classes designed to make
        SQL query conditions more type-safe in Hack 
 */


// /**
//  * Representing a condition (WHERE clause) on a column within the column enum Tc. 
//  * @param Tc The enum containing all the columns 
//  */
// abstract class QueryCondition<Tc as string> { 

//     private Tc $column; 
    

// }

type ConditionalOperator = string; // maybe string-ish enum some day?  if convenient enough


class Condition { 

    private     Table                       $tbl; 
    private     Column                      $col;
    private     mixed                       $val; 
    private     ConditionalOperator         $op; 

    //TODO: Conjunctions and disjunctions (ANDs and ORs)?


    public function getTable() : Table { return $this->tbl; }
    public function getColumn() : Column { return $this->col; }
    public function getValue() : mixed { return $this->val; } 
    public function getOperation() : ConditionalOperator { return $this->op; }


    public function __construct(Table $tbl, Column $col, mixed $val, string $op) { 
        $this->tbl  = $tbl; 
        $this->col  = $col; 
        $this->val  = $val;
        $this->op   = $op; 

    }
}