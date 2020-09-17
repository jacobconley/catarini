require_once __DIR__.'/../vendor/hh_autoload.hh'; 

use catarini\db\{ Type };
use catarini\db\schema\{ Table, Column, Schema, Reference, ReferenceAction, Relationship, RelationshipEnd, Cardinality }; 
use catarini\db\backend\mysql; 
use catarini\db\migration\SchemaWriter;





<<__EntryPoint>>
function _test_codegen_main() : void { 

    $dir = _test_dir().'/output';
    $schema = TestSchema::GET()->schema;

    $writer = new SchemaWriter($schema, $dir);
    $writer->writeHack(_test_namespace());


    /*
     * These are MySQL tests only 
     */


    // (testEntities) 

    mysql\entity_out($schema, $dir.'/entities', _test_namespace());

}