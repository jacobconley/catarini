namespace catarini\db\querying;

use catarini\db\{ DatabaseInstance };
use catarini\db\schema\{ Schema, Table };

use HH\Lib\{ Vec }; 



type joinlist = vec<EntityQuery<Entity>>;

// Tm - entity sublcass
// Tcol - column enum (this should be as string) - Scrapped for now
abstract class EntityQuery<Tm as Entity> { 


    public function __construct(Tm $parent) { 

    }


    // Previous queries that have been joined with this one
    // Modifiers from these queries will need to apply to the rendered result as well

    // There will also need to be some sort of "prefix" attribute to disambiguate tables - or maybe the renderer can deal with all that 
    // also: 
        /* Table name
         * Identifier name
         * If there is an intermediate join - 
         */

    // maybe we can make it type unsafe here and then just force convert it since it's all codegen anyways 


    //TODO: Rename this shit 




    // Ok here's all the things we gotta implement 


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


    private vec<Condition> $conditions = vec[]; 
    protected function getConditions() : vec<Condition> { return $this->conditions; }
    protected function addCondition(Condition $c) : void  { $this->conditions[] = $c; }
    // Currently: 
    /* 
        - We codegen where_x...() methods into each generated query subtype 
        - Assumed to be all conjunctive
        - Eventually we add a where_unsafe() method to write literal SQL code maybe?
        - Or a more complex method taking a lambda of an API type, similar to the schema API 
     */


    /*
     * Type safety for these stuffs?
     * We could use an enum, but
     * - that would be inconvenient
     * - it would (probably?) require separate subclasses for each entity
     * - - unless we used generics for this?????? oowoowahwoh
     * - - - then how to get column name back from enumm...
     * - - - AS STRING??? ENUM AS STRING? this is allowed
     */

    // Or, codegen the individual orderings into that shit 
    // but then it's hard to control what order since the call has to be in the middle...,,,

    // Seems like ORDER BY comes after anyways 

    // protected vec<(Tcol, bool)> $orderings = vec[]; 
    // public function order_by(Tcol $column, bool $ascending = TRUE) : this { 
    //     $this->orderings[] = tuple($column, $ascending); 
    //     return $this; 
    // }



 //TODO: Separate interface for "finalizing" queries ? that doesn't have modifiers like "where" 








    // TODO: Iterator 

    //TODO: Selecting multiple tables?  
    // Since each entity has a generated from_sql function, if the user needs to select multiple 
    //  tables and do a full outer join, the user can use ::from_sql() to get each individual row 


    // public abstract function first() : Awaitable<Tm>;


    // Accessors
    // These return resULTS 
    // public async function first() : Awaitable<Tm> { return $this->DB->queryFirst<Tm, Tcol>($this);  } 
}


// Questions:
/*
 * Aggregates? (Group by) Returns the above object.  Or maybe a part of the above object just like the other functions
 */

