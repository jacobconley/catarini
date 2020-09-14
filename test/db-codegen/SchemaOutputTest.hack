use function Facebook\FBExpect\expect;
use function count; 

use catarini\db\{ Table, Column, Type }; 

class SchemaOutputTest extends Facebook\HackTest\HackTest { 

    public function testBasic() : void { 
        $schema = \_catarini_test\_db_schema();

        $tables = $schema->getTables();
        expect(count($tables))->toBeSame(1);

        $tibble = $tables[0]; 
        expect($tibble->getName())->toBeSame('tibble');



        $cols = $tibble->getColumns();
        expect(count($cols))->toBeSame(2); 


        expect($cols[0]->getType())->toBeSame(Type::INT);
        expect($cols[0]->getName())->toBeSame('id'); 

        expect($cols[1]->getType())->toBeSame(Type::INT);
        expect($cols[1]->getName())->toBeSame('test'); 
    }



    // public function testEntities() : void { 

    // }

}