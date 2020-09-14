use function Facebook\FBExpect\expect;
use function Facebook\TypeAssert\not_null;
use function count; 

use catarini\db\{ Table, Column, Type }; 

class SchemaOutputTest extends Facebook\HackTest\HackTest { 

    public function testBasic() : void { 
        $schema = \_catarini_test\_db_schema();

        $tables = $schema->getTables();
        expect(count($tables))->toBeSame(2);

        $tibble = $tables[0]; 
        expect($tibble->getName())->toBeSame('tibble');


        //
        // `tibble`
        //


        $cols = $tibble->getColumns();
        expect(count($cols))->toBeSame(2); 

        $col = $cols[0];
        expect($col->getType())->toBeSame(Type::INT);
        expect($col->getName())->toBeSame('id'); 
        expect($col->isUnique())->toBeTrue();
        expect($col->isNullable())->toBeFalse();

        $col = $cols[1]; 
        expect($cols[1]->getType())->toBeSame(Type::INT);
        expect($cols[1]->getName())->toBeSame('test'); 
        expect($col->isNullable())->toBeTrue("This column should default nullable");
        expect($col->isUnique())->toBeFalse("This column should default non-unique"); 

        //
        // `other`
        //


        $i      = 1;
        $table  = $tables[$i];
        $cols   = $table->getColumns();
        expect(count($cols))->toBeSame(2); 

        $col = $cols[0];
        expect($col->getType())->toBeSame(Type::INT);
        expect($col->getName())->toBeSame('id'); 

        $col = $cols[1]; 
        $ref = $col->getReference();
        expect($col->getType())->toBeSame(Type::INT);
        expect($col->getName())->toBeSame('tibble_id'); 
        expect($col->isNullable())->toBeFalse();

        expect($ref)->toNotBeNull();  $ref = not_null($ref);
        expect($ref->getReferencedTable()->getName())->toBeSame('tibble');
        expect($ref->getAlias())->toBeSame('tabble');
    }



    // public function testEntities() : void { 

    // }

}