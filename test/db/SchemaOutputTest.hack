use function Facebook\FBExpect\expect;

use Facebook\HackCodegen\{
    CodegenFileType,
    HackCodegenConfig,
    HackCodegenFactory,
    HackBuilderValues,
    HackBuilder
};

use catarini\db\{ Table, Column, Type }; 

use catarini\db\migration\SchemaWriter; 

const string TESTNS = 'testcat';

class SchemaOutputTest extends Facebook\HackTest\HackTest { 

    public function testBasic() : void { 

        $dir = _test_dir().'output/';

        $schema = vec[
            new Table('tibble', vec[
                new Column(Type::INT, 'test')
            ])
        ];

        $writer = new SchemaWriter($schema, $dir);

        $writer->writeHack(TESTNS);

    }

}