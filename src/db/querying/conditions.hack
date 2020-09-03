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

    // maybe this shouldnt be Column... unless we're commited to having a statically-available schema instance
    private     Column                      $col;
    private     mixed                       $val; 
    private     ConditionalOperator         $op; 

    //TODO: Conjunctions and disjunctions (ANDs and ORs)?


    public function getColumn() : Column { return $this->col; }
    public function getValue() : mixed { return $this->val; } 
    public function getOperation() : ConditionalOperator { return $this->op; }


    public function __construct(Column $col, mixed $val, string $op) { 
        $this->col  = $col; 
        $this->val  = $val;
        $this->op   = $op; 

    }
}