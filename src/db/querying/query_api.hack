namespace catarini\db; 

use Facebook\TypeAssert\TypeAssert;


// Tm - entity sublcass
// Tcol - column enum (this should be as string) 

class EntityQuery<Tm, Tcol> { 


    protected Tm $parent; 
    protected DatabaseInstance $DB; 
    public function __construct(DatabaseInstance $DB, Tm $parent) { 
        $this->parent = $parent; 
        $this->DB = $DB; 
    }

    /*
     * WHERE
     * ORDER BY
     * LIMIT, OFFSET
     */


    /*
     * first, last
     * sample
     * all
     * for each (+async) 
     */


    protected ?string $condition;
    public function where(string $condition) : this { 
        $this->condition = $condition;
        return $this; 

    }

    /*
     * Type safety for these stuffs?
     * We could use an enum, but
     * - that would be inconvenient
     * - it would (probably?) require separate subclasses for each entity
     * - - unless we used generics for this?????? oowoowahwoh
     * - - - then how to get column name back from enumm...
     * - - - AS STRING??? ENUM AS STRING? this is allowed
     */

    // So, I think we are doing this 

    protected vec<(Tcol, bool)> $orderings = vec[]; 
    public function order_by(Tcol $column, bool $ascending = TRUE) : this { 
        $this->orderings[] = tuple($column, $ascending); 
        return $this; 
    }




    // Accessors
    // These return resULTS 
    // public async function first() : Awaitable<Tm> { return $this->DB->queryFirst<Tm, Tcol>($this);  } 
}


// Questions:
/*
 * Aggregates? (Group by) Returns the above object.  Or maybe a part of the above object just like the other functions
 */