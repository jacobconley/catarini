use catarini\db\{ Database, Type };
use catarini\db\schema\{ Column, table_creator, table_changer }; 
use catarini\db\schema\{ Schema, Table, Reference, ReferenceAction, Cardinality, Relationship, RelationshipEnd };

use function Facebook\FBExpect\expect; 

class SchemaTest extends Facebook\HackTest\HackTest { 

    // public function testCreate() : void { 
    //     $DB = $this->db(); 
    //     $DB->addTable('test', $x ==> {}); 
    // }


    // 
    // TableCreator tests
    // 

    public function testTableCreator() : void 
    { 
        $t = new table_creator('testTableCreator');  
        $t->add('testint')->int()->nonnull(); 
        // Maybe add some more columns here once we get the other types in 


        $cols = $t->getColumns();
        expect(\count($cols))       ->toBeSame(1); 

        $col = $cols[0]; 
        expect($col->getName())     ->toBeSame('testint'); 
        expect($col->getType())     ->toBeSame(Type::INT); 
        expect($col->isNullable())  ->toBeFalse(); 
        expect($col->isUnique())    ->toBeFalse();
        expect($col->hasDefault())  ->toBeFalse(); 
    }

    public function testTableChanger_del() : void 
    {
        $t = new table_changer('testTableChanger_del', vec[]); 
        $t->add('testint')->int();
        $t->add('other')->int();
        $t->add('third')->int();

        $t->del('other');

        $cols = $t->getColumns();
        expect(\count($cols))       ->toBeSame(2);

        expect($cols[0]->getName()) ->toBeSame('testint');
        expect($cols[1]->getName()) ->toBeSame('third'); 
    }

    //TODO: Test change column 
    


    //
    // Relationship tests
    //

    // A nice test case!
}