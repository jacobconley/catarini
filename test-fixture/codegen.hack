require_once __DIR__.'/../vendor/hh_autoload.hh'; 

use catarini\db\{ Type };
use catarini\db\schema\{ Table, Column, Schema, Reference, ReferenceAction, Relationship, RelationshipEnd, Cardinality }; 
use catarini\db\backend\mysql; 
use catarini\db\migration\SchemaWriter;
use catarini\db\codegen\Codegen; 



<<__EntryPoint>>
function _test_codegen_main() : void 
{
    $dir    = _test_dir().'/output';
    $ns_pvt = _test_namespace_private();
    $ns_pub = _test_namespace_public();

    $schema = TestSchema::GET()->schema;


    $codegen = new Codegen(NULL, $ns_pub, "$dir/public/", $ns_pvt, "$dir/private/");
    $codegen->genSchema($schema);
    $codegen->genEntities($schema);
}