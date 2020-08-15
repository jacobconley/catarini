require_once __DIR__.'/../vendor/hh_autoload.hh'; 

use catarini\db\{ Table, Column, Type, Schema }; 
use catarini\db\migration\SchemaWriter;

<<__EntryPoint>>
function _test_codegen_main() : void { 

    /*                          *
     *     SchemaOutputTest     *
     *                          */



    // (testBasic) 

    $dir = _test_dir().'/output/';

    $schema = vec[
        new Table('tibble', vec[
            new Column(Type::INT, 'test')
        ])
    ];

    $writer = new SchemaWriter($schema, $dir);

    $writer->writeHack(_test_namespace());


}