namespace catarini\db\backend\mysql; 


use catarini\db; 
use catarini\db\{ Schema };

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

function entity_out(Schema $schema, string $dir, ?string $namespace = NULL) : void { 

    \catarini\util\ensure_dir($dir); 

    $tables = $schema; // migratable
    
    $hack_config = new HackCodegenConfig();
    $hack = new HackCodegenFactory($hack_config); 

    foreach($tables as $table) 
    { 
        $name = $table->getName();
        $path = "$dir/$name.php";
        $file = $hack->codegenFile($path); 

        if($namespace is nonnull) $file->setNamespace($namespace); 

        $classname = $name; 



        //
        // Things we do now to simplify the file output below
        //

        $columns = $table->getColumns(); 
        $col_names = Vec\map($columns, $x ==> $x->getName()); 


        // Generating constructor assignments - doing this programmatically to avoid hassle.  probably a bad idea?
        $constructor_body = $hack->codegenHackBuilder();
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
        $from_sql->addf("return new %s(%s);",    $classname,       Vec\map($col_names, $x ==> '$'.$x)  |>  Str\join($$, ', ')       );
        $from_sql = $from_sql->getCode();
        // uh change this to make it call constructor not set loool 


        //
        // Main file output
        //


        $file
            ->useNamespace('catarini\db')
            ->useType('catarini\db\Table')
            ->useType('catarini\db\Column')
            ->useType('catarini\db\Type')
            ->useType('catarini\db\querying\Entity')
            ->useType('catarini\db\querying\EntityQuery')

            ->useFunction('catarini\db\type\__sql_val')
            ->useFunction('catarini\db\type\__sql_val_opt')

            ->addClass(

                $hack->codegenClass($classname)


                    /*  __sql_cols

                        Array of column names 
                     */
                    ->addProperty(  
                        (new CodegenProperty($hack_config,  '__sql_cols'))
                        ->setType('vec<string>')
                        ->setValue(  Vec\map($columns, $col ==> $col->getName())   ,  HackBuilderValues::vec(HackBuilderValues::export())  )
                        ->setPublic()
                    )


                    // Columns, rendered as instance properties 
                    ->addProperties($table->getColumns() |> Vec\map($$, $col ==> {
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
                            ->setReturnType($classname)

                            ->addParameter($from_sql_arg) 


                            ->setBody($from_sql)

                    )

            )

        
            ->save();
    }

}