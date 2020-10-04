namespace catarini\db\codegen\entities; 


use catarini\db; 
use catarini\db\schema\{ Schema, Table };
use catarini\db\codegen\Codegen;
use catarini\log; 

use function catarini\util\{ HackCodegenFile };

use HH\Lib\{ Vec, Str }; 

use Facebook\HackCodegen\{
    CodegenFileType,
    HackCodegenConfig,
    HackCodegenFactory,
    HackBuilderValues,
    HackBuilder,
    CodegenProperty
};


// Invoked by the CLI to generate entity files 



/*
   Uhh.  Uuuuufh hrng
   this function takes names and returns better, more ~acceptable~ names
   I didn't want to do this but then I made a test schema with a table named "class".... yeeeesh 
   The original plan was to just make stuff like that invalid but I'd have to migrate my tests.  maybe I will idfk 
 */

/**
 * Don't call this directly!  Use Table->getEntityName() !
 * This will be removed [Issue #43]
 */
function entity_name(string $name) : string { 
    $name = Str\capitalize($name); 

    //TODO:  Prefixing options?  

    switch($name) { 
        case "Class":   return "DB$name"; 
        default:        return $name;
    } 
}







function writeEntityQuery(Codegen $parent, Table $table, string $pub_dir, ?string $pub_ns, string $priv_dir, string $priv_ns) : void { 
    $name = $table->getEntityName();
    $dir = "$priv_dir/query";

    $hack_config = new HackCodegenConfig();
    $hack = new HackCodegenFactory($hack_config); 
    $path = HackCodegenFile($dir, "Query_$name");
    $file = $hack->codegenFile($path);


    //
    // Main output
    //

    $file

        ->setNamespace($parent->getEntityQueryNamespace())

        ->useNamespace('catarini\db')
        ->useNamespace('catarini\db\backend\mysql')
        ->useType('catarini\db\{ Database, Type }')
        ->useType('catarini\db\schema\Table')
        ->useType('catarini\db\schema\Column')
        ->useType('catarini\db\querying\{ Entity,  EntityQueryTarget, joinlist }')

        ->useFunction('catarini\db\type\__sql_val')
        ->useFunction('catarini\db\type\__sql_val_opt')

        ->useType('catarini\db\backend\mysql\EntityQuery', 'MysqlQuery')
        ->useType($parent->getEntityUserland($table), 'USERLAND')


        ->addClass( 
            $hack->codegenClass(  $parent->getEntityQueryName($table)  ) 
            ->setExtends('MysqlQuery<USERLAND>')


            ->addMethod($hack->codegenMethod('from_row')
                ->setProtected()
                ->setIsOverride(TRUE)
                ->setReturnType('USERLAND')

                ->addParameter('Map<string, ?string> $row')

                ->setBody('return USERLAND::from_sql($this->DB(), dict($row));')
            )
        )

        ->save();    
}






//
// Base entity class
//



function writeEntityBase(Codegen $parent, Table $table, string $pub_dir, ?string $pub_ns, string $priv_dir, string $priv_ns) : void {
    $name = $table->getEntityName();
    $dir = "$priv_dir/entity";

    $hack_config = new HackCodegenConfig();
    $hack = new HackCodegenFactory($hack_config); 
    $path = HackCodegenFile($dir, $name);
    $file = $hack->codegenFile($path);


    $file->setNamespace($parent->getEntityBaseNamespace());

    $classname = $name; // migration


    //
    // 
    //

    $columns = $table->getColumns(); 
    $col_names = Vec\map($columns, $x ==> $x->getName()); 


    // Generating constructor assignments - doing this programmatically to avoid hassle.  probably a bad idea?
    $constructor_body = $hack->codegenHackBuilder();
    $constructor_body->addLine('parent::__construct($DB);');
    foreach($columns as $col) { 
        $name = $col->getName();
        $constructor_body->addf('$this->%s = $%s;', $name, $name); 
        $constructor_body->ensureNewLine();
    }
    $constructor_body = $constructor_body->getCode();

    //TODO: Prefixing here 
    $from_sql_arg = 'dict<string, ?string> $row';

    $from_sql = $hack->codegenHackBuilder();
    foreach($columns as $col) { 
        $name = $col->getName(); 
        $from_sql->addf('$%s = %s;', $name, $col->__sql_val_call("\$row['$name']"));
        $from_sql->ensureNewLine();
    }
    $from_sql->addf("return new %s(\$DB, %s);",    'USERLAND',       Vec\map($col_names, $x ==> '$'.$x)  |>  Str\join($$, ', ')       );
    $from_sql = $from_sql->getCode();
    // uh change this to make it call constructor not set loool 


    //
    // Main file output
    //


    $file
        ->useNamespace('catarini\db')
        ->useNamespace('catarini\db\backend\mysql')
        ->useType('catarini\db\{ DatabaseInstance, Type }')
        ->useType('catarini\db\schema\Table')
        ->useType('catarini\db\schema\Column')
        ->useType('catarini\db\querying\{ Entity, EntityQuery, EntityQueryTarget }')

        ->useFunction('catarini\db\type\__sql_val')
        ->useFunction('catarini\db\type\__sql_val_opt')

        ->useType($parent->getEntityUserland($table), 'USERLAND')
        ->useType($parent->getEntityQuery($table), 'EQUERY')

        ->addClass(

            $hack->codegenClass($classname)
                ->setExtends('Entity')


                /*  __sql_cols

                    Array of column names 
                    */
                ->addProperty(  
                    (new CodegenProperty($hack_config,  '__sql_cols'))
                    ->setType('vec<string>')
                    ->setValue(  Vec\map($columns, $col ==> $col->getName())   ,  HackBuilderValues::vec(HackBuilderValues::export())  )
                    ->setPublic()
                )

                /*
                    __sql_tbl 
                    Table object
                    */
                // ->addProperty(
                //     (new CodegenProperty($hack_config, '__sql_tbl'))
                //     ->setType('Table')
                //     ->setValue(    )
                //     ->setProtected()
                // )
                // ->addMethod(
                //     ($hack->codegenMethod('__sql_tbl'))
                //     ->setProtected()
                //     ->setIsStatic(TRUE)
                //     ->setReturnType('Table')
                //     ->setBody("return _db_schema()->getTable('$name');")
                // )


                // Columns, rendered as instance properties 
                ->addProperties(  $table->getColumns() |> Vec\map($$, $col ==> {
                    $prop = new CodegenProperty($hack_config, $col->getName());
                    $prop->setType($col->_str_HackType());

                    $str_default = $col->_str_default();
                    if($col->hasDefault() && $str_default is nonnull) $prop->setValue($str_default, $col->__column_renderer());

                    return $prop; 
                }))


                //TODO: Constructor, from_sql, to_sql 
                // This depends on how async mysql interprets values
                // 
                // maybe we shd make all class variables nullable, and just enforce optionality with an auto-generated function

                /*  constructor
                    */
                ->addMethod(
                    ($hack->codegenMethod('__construct'))

                    ->addParameter('DatabaseInstance $DB')
                    ->addParameters( Vec\map($columns, $col ==>  {  
                        $type = $col->_str_HackType();  
                        $name = $col->getName();
                        return "$type \$$name"; 
                    }) )

                    // Assignments generated programmatically above 
                    ->setBody($constructor_body)
                )


                /*  from_sql                  
                    */
                ->addMethod(

                    $hack->codegenMethod('from_sql')
                        ->setIsStatic(TRUE)
                        ->setReturnType('USERLAND')

                        ->addParameter('DatabaseInstance $DB')
                        ->addParameter($from_sql_arg) 


                        ->setBody($from_sql)

                )



                //TODO: 
                /*
                    * ->__cols($prefix) ? Or is that not helpful in codegen  
                    */





                    /* ::query
                    */
                ->addMethod($hack->codegenMethod('q')
                    ->setReturnType("EntityQuery<USERLAND>")
                    ->setBody(
                        $hack->codegenHackBuilder()
                        ->addLinef("\$tgt = new EntityQueryTarget(%s);",  $parent->__table_obj($table->getName()))
                        ->addLine('return new EQUERY($this->DB, $tgt);')
                        ->getCode()
                    )
                )

        )

    
        ->save();
}







//
// Userland entity class
//


/**
 * Writes the userland entity subclass, IF the file does not already exist
 * @return TRUE if the file was created, FALSE If skipped because it already exists
 */
function writeEntityUserland(Codegen $parent, Table $table, string $pub_dir, ?string $pub_ns, string $priv_dir, string $priv_ns) : bool {
    $name = $table->getEntityName();
    $hack_config = new HackCodegenConfig();
    $hack = new HackCodegenFactory($hack_config); 
    $path = HackCodegenFile($pub_dir, $name);

    if(\file_exists($path)) return FALSE;
    $file = $hack->codegenFile($path);

    if($pub_ns is nonnull) $file->setNamespace($pub_ns); 


    $file->addClass(

        $hack->codegenClass($name)
            ->setExtends('\\'.$parent->getEntityBase($table))
            ->setIsFinal(TRUE)

    )
    ->setIsSignedFile(FALSE)
    ->save();

    return TRUE;
}




/**
 * Writes all entity-related code for a given schema.
 * This function invokes all of the writeEntity* functions for each Entity table. 
 */
function writeAll(Codegen $parent,Schema $schema, string $pub_dir, ?string $pub_ns, string $priv_dir, string $priv_ns) : void { 
    $tables = $schema->getTables(); 

    foreach($tables as $table) 
    { 
        //TODO: Skip non-entity tables? 
        
        writeEntityBase     ($parent, $table, $pub_dir, $pub_ns, $priv_dir, $priv_ns);
        writeEntityUserland ($parent, $table, $pub_dir, $pub_ns, $priv_dir, $priv_ns);
        writeEntityQuery    ($parent, $table, $pub_dir, $pub_ns, $priv_dir, $priv_ns);
    }
}