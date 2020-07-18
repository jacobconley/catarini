use catarini\db\migration;
use catarini\db\migration\actions; 
use catarini\db\{ table_creator, table_changer, Column, Type };

use function Facebook\FBExpect\expect;



class _migration_auto_1 extends migration\AutomaticMigration { 

    public function load() : void { 

        $this->addTable('test', $t ==> {
            $t->add('integer')->int();

            //TODO: Other data types 
            //TODO: Nullability and what not (ought to be a separate test)
        });

        $this->changeTable('changer', $t ==> {
            $t->change('col')->int();
            $t->del('deleter');
        });

        $this->delTable('deleter');

    }


    public static function changer() : table_changer { 
        return new table_changer('_migration_auto_1', vec[
            new Column(Type::INT, 'deleter'),
            new Column(Type::STRING, 'col')
        ]);
    }

}



class MigrationAutomaticTest extends Facebook\HackTest\HackTest { 

    public function testLoad() : void 
    {
        $x = new _migration_auto_1(_test_db(), '_migration_auto_1'); 
        $x->load();
        $actions = $x->_getActions();

        expect(\count($actions))->toBeSame(3); 

        expect($actions[0])->toBeInstanceOf(actions\addTable::class); 
        expect($actions[1])->toBeInstanceOf(actions\changeTable::class); 
        expect($actions[2])->toBeInstanceOf(actions\delTable::class); 


        // Creator test

        $creator = new table_creator('testLoad_create');
        ($actions[0] as actions\addTable)->_apply($creator); 
        
        $cols = $creator->getColumns();
        expect(\count($cols))->toBeSame(1); 
        $c1 = $cols[0]; 
        expect($c1->getType())->toBeSame(Type::INT); 
        expect($c1->getName())->toBeSame('integer'); 


        // Changer test 

        $changer = _migration_auto_1::changer();
        $chact = $actions[1] as actions\changeTable;
        $chact->_apply($changer); 

        $cols = $changer->getColumns();
        $changed = $changer->_getChanged();
        $deleted = $changer->_getDeleted();
        expect(\count($changed))->toBeSame(1);
        expect(\count($deleted))->toBeSame(1);
        expect($changed[0])->toBeSame('col');
        expect($deleted[0])->toBeSame('deleter');

        expect(\count($cols))->toBeSame(1);
        expect($cols[0]->getName())->toBeSame('col', 'The previous column should have been deleted'); 
        expect($cols[0]->getType())->toBeSame(Type::INT, 'This should have been changed to int'); 
    }

}