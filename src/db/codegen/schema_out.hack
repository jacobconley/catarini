namespace catarini\db\codegen\schema;

use Facebook\HackCodegen\{
    CodegenFileType,
    HackCodegenConfig,
    HackCodegenFactory,
    HackBuilderValues,
    HackBuilder
};

use HH\Lib\{ Vec, Str};

use catarini\db\schema\{ Schema, Table, Column, Reference, Cardinality, RelationshipEnd, Relationship, RelationshipThrough }; 
use function catarini\db\typeToString;
use catarini\log; 



//
// Render tables
//


function hack_Reference(HackBuilder $cb, ?Reference $ref, vec<Table> $tables) : void { 
    if($ref is null) { 
        $cb->add('NULL');
        return; 
    }

    $t_i /* u can have whatever u like */ = Vec\first_key($tables,  $x ==> $x->getName() === $ref->getReferencedTable()->getName());
    $table = "\$tables[$t_i]";

    $cb->indent();
    $cb->ensureNewLine();
    $cb->addf("(new Reference(%s, ReferenceAction::%s, ReferenceAction::%s))", $table, $ref->getUpdateAction() as string, $ref->getDeleteAction() as string);
    $cb->addIf($ref->isNullable(), "->nullable()");

    $cb->unindent();
    $cb->ensureNewLine();
}


function hack_Column(HackBuilder $cb, Column $col, vec<Table> $tables) : void { 
    $type = $col->getType();

    $def = $col->_str_default();
    $con = $col->_str_condition();

    $cb->addf('(new Column(%s, "%s", ', 'Type::'.typeToString($type), $col->getName());
    hack_Reference($cb, $col->getReference(), $tables); 
    $cb->addf(', %s))',   $col->isPrimary() ? 'TRUE' : 'FALSE');

    if(! $col->isNullable())    $cb->addf('->nonnull()');
    if($col->isUnique())        $cb->addf('->unique()');
    if($def is nonnull)         $cb->addf('->default(%s)', $def); 
    if($con is nonnull)         $cb->addf('->check(%s)', $con); 

    $cb->add(',');
    $cb->ensureNewLine();
}

// Currently these functions depend on the ordering of the tables vec to establish references to each other
// This gives rise to some limitations we need to address [Issue #41]

function hack_Table(HackBuilder $cb, Table $table, vec<Table> $previous) : void { 
    $cb->addf('$tables[] = new Table("%s", vec[', $table->getName());
    $cb->ensureNewLine();
    $cb->indent();

    foreach($table->getColumns() as $col) hack_Column($cb, $col, $previous);

    $cb->unindent();
    $cb->addf(']);');
    $cb->ensureEmptyLine();
}



//
// Render relationshps
// 

function hack_tblIndex(vec<Table> $tables, string $name) : string { 
    return Str\format('$tables[%d]', Vec\first_key($tables,  $x ==>    $x->getName() == $name   ));
}
function hack_RelationshipEnd(vec<Table> $tables, RelationshipEnd $end) : string { 
    return Str\format('new RelationshipEnd(%s, Cardinality::%s, \'%s\')',  hack_tblIndex($tables, $end->table->getName()),  $end->cardinality as string,  $end->getName());
}


function hack_Relationship(HackBuilder $cb, Relationship $relationship, vec<Table> $tables) : void { 

    $left       = $relationship->getLeft();
    $right      = $relationship->getRight();
    $left_end   = hack_RelationshipEnd($tables, $left);
    $right_end  = hack_RelationshipEnd($tables, $right); 

    if($relationship is RelationshipThrough) { 
        $tbl_mid    = hack_tblIndex($tables, $relationship->getIntermediate()->getName());

        $cb->addLine('$relationships[] = new RelationshipThrough($schema,');
        $cb->indent();
        $cb->addLine("$left_end,");
        $cb->addLine("$tbl_mid,");
        $cb->addLine("$right_end,");
        $cb->addLine("'".$relationship->getID()."'");

    } else { 

        $cb->addLine('$relationships[] = new Relationship($schema,');
        $cb->indent();
        $cb->addLine("$left_end,");
        $cb->addLine("$right_end,");
        $cb->addLine("'".$relationship->getID()."'");
    }

    $cb->unindent();
    $cb->addLine(');');
    $cb->ensureNewLine();
}






// 
// Here it is!  Rendering!
//



function writeHack(Schema $schema, string $dir, ?string $namespace) : void { 
    \catarini\util\ensure_dir($dir); 
    $path = $dir.'/schema.php';  //TODO: Change to .hack when updating codegen version?
                                // This oughtta be logged..

    log\write_file($path); 

    $hack = new HackCodegenFactory(new HackCodegenConfig()); 
    $cg = $hack->codegenFile($path);
    if($namespace is nonnull) $cg->setNamespace($namespace); 


    $tables = $schema->getTables(); 
    $tbc = $hack->codegenHackBuilder();
    foreach($tables as $table) { 
        hack_Table($tbc, $table, $tables);
    }

    $relationships = $schema->getRelationships();
    $hack_rel = $hack->codegenHackBuilder();
    foreach ($relationships as $rel) { 
        hack_Relationship($hack_rel, $rel, $tables);
    }


    //
    // Here it is!  Here's the codegen!!
    //

    
    $cg->useNamespace('catarini\db')
        ->useType('catarini\db\Type')
        ->useType('catarini\db\schema\{ Table, Column, Schema, Reference, ReferenceAction, Relationship, RelationshipEnd, RelationshipThrough, Cardinality }')

        ->addFunction(
            $hack->codegenFunction('_db_schema')
                ->setReturnType('Schema')
                ->setBody(

                    $hack->codegenHackBuilder()


                        ->add('$tables = vec[];')
                        ->ensureEmptyLine()
                        ->add($tbc->getCode())

                        ->ensureEmptyLine()
                        ->addLine('$schema = new Schema($tables);')
                        ->addLine('$relationships = vec[];')

                        ->ensureEmptyLine()
                        ->addLine($hack_rel->getCode())

                        //TODO: Relationships ! 

                        // ->ensureNewLine()
                        // ->add('];')



                        ->ensureEmptyLine()
                        ->addLine('$schema->setRelationships($relationships);')
                        ->addLine('return $schema;')
                        ->getCode()
                )
    );

    $cg->save();
}
