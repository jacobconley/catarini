use function Facebook\FBExpect\expect;
use function Facebook\TypeAssert\not_null;
use function count; 

use catarini\db\{ Type };
use catarini\db\schema\{ Schema,  Table, Column, Reference, ReferenceAction, Relationship, RelationshipEnd, Cardinality }; 

class SchemaOutputTest extends Facebook\HackTest\HackTest { 



    //
    // Testing the output of the codegen schema, defined in `codegen/special-test-cases.hack`, generated in `test-fixture/codegen.hack`
    // Essentially testing for deep equality between the generated schema and the source, which is `TestSchema::GET()->schema`
    //
    public function testSchemaOutput() : void { 
        $schema                 = \_catarini_test\_db_schema();
        $tables                 = $schema->getTables();
        $relationships          = $schema->getRelationships();

        $expected_schema        = TestSchema::GET()->schema;
        $expected_tables        = $expected_schema->getTables();
        $expected_relationships = $expected_schema->getRelationships();


        expect(count($tables))->toEqual(count($expected_tables), "Number of tables in output schema");
        //TODO: Relationships 

        for($x = 0; $x < count($tables); $x++) { 

            // Table 

            $table      = $tables[$x]; 
            $ex_table   = $expected_tables[$x]; // lol $ex table 

            expect($table->getName())->toBeSame($ex_table->getName());

            // Columns

            $cols       = $table->getColumns();
            $ex_cols    = $ex_table->getColumns(); 
            expect(count($cols))->toBeSame(count($ex_cols), "Number of columns in ".$table->getName());

            for($j = 0; $j < count($cols); $j++) { 
                $col    = $cols[$j];
                $ex_col = $ex_cols[$j];
                $name   = $col->getName();

                expect($col->getName())     ->toBeSame($ex_col->getName());
                expect($col->getType())     ->toBeSame($ex_col->getType(),      "Type of column $name"); 
                expect($col->isNullable())  ->toBeSame($ex_col->isNullable(),   "Nullability of column $name"); 
                expect($col->isPrimary())   ->toBeSame($ex_col->isPrimary(),    "Primarity of column $name"); 
            }
        }
    }



    // public function testEntities() : void { 

    // }

}