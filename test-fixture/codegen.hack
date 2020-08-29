require_once __DIR__.'/../vendor/hh_autoload.hh'; 

use catarini\db\{ Table, Column, Type, Schema }; 
use catarini\db\migration\SchemaWriter;
use catarini\db\backend\mysql; 

<<__EntryPoint>>
function _test_codegen_main() : void { 


    // This is where all of our test cases are defined for codegen stuff
    //  maybe theres a better way idk


    /*                          *
     *     SchemaOutputTest     *
     *                          */



    $dir = _test_dir().'/output/';

    $schema = vec[
        new Table('tibble', vec[
            new Column(Type::INT, 'test')
        ])
    ];




    // (testBasic) 

    $writer = new SchemaWriter($schema, $dir);

    $writer->writeHack(_test_namespace());


    /*
     * These are MySQL tests only 
     */


    // (testEntities) 

    mysql\entity_out($schema, $dir, _test_namespace());

}