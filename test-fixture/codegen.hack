require_once __DIR__.'/../vendor/hh_autoload.hh'; 

use catarini\db\{ Type };
use catarini\db\schema\{ Table, Column, Schema, Reference, ReferenceAction, Relationship, RelationshipEnd, Cardinality }; 
use catarini\db\migration\SchemaWriter;
use catarini\db\backend\mysql; 


// A nice test case, used for static schema tests as well as codegen tests 
function _test_relationship_schema() : Schema { 

    $tables = vec[];
    
    $tables[] = new Table('tibble', vec[
        (new Column(Type::INT, 'id', NULL, TRUE))->nonnull()->unique(),
        (new Column(Type::INT, 'test', NULL, FALSE))
    ]);

    $tables[] = new Table('other', vec[
        (new Column(Type::INT, 'id', NULL, TRUE))->nonnull()->unique(),
        (new Column(Type::INT, 'tibble_id', 
            new Reference($tables[0], ReferenceAction::CASCADE, ReferenceAction::RESTRICT),
        FALSE))->nonnull()
    ]);

    $relationships = vec[]; 

    return new Schema($tables, $relationships); 
}





<<__EntryPoint>>
function _test_codegen_main() : void { 


    // This is where all of our test cases are defined for codegen stuff
    //  maybe theres a better way idk


    /*                          *
     *     SchemaOutputTest     *
     *                          */



    $dir = _test_dir().'/output/';
    $schema = _test_relationship_schema();


    // (testBasic) 

    $writer = new SchemaWriter($schema, $dir);

    $writer->writeHack(_test_namespace());


    /*
     * These are MySQL tests only 
     */


    // (testEntities) 

    mysql\entity_out($schema, $dir, _test_namespace());

}