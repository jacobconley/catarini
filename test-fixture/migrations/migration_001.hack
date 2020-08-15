namespace catarini_migrations;

function migration_001(\catarini\db\Database $DB) : void { 

    $DB->addTable('test', $t ==> {

        $t->add('id')->int();
        
    });

}