namespace catarini\db\migration;

use Facebook\HackCodegen\{
    CodegenFileType,
    HackCodegenConfig,
    HackCodegenFactory,
    HackBuilderValues,
    HackBuilder
};

use HH\Lib\{ Vec };

use catarini\db\{ Schema, Table, Column }; 
use function catarini\db\typeToString;


class SchemaWriter { 

    private Schema $schema; 
    private string $dir; 

    public function __construct(Schema $schema, string $dir) { 
        $this->schema = $schema;  
        $this->dir = $dir; 
    }    

    private bool $exists = FALSE; 
    private function checkdir() : void { 
        if($this->exists) return;
        $this->exists = TRUE; 

        //TODO: Code from GenerateCommand->migration(), i feel like it should be standardized
    }



    private function hackColumn(HackBuilder $cb, Column $col) : void { 
        $type = $col->getType();

        $def = $col->_str_default();
        $con = $col->_str_condition();

        $cb->addf('new Column(%s, "%s")', 'Type::'.typeToString($type), $col->getName());
        if(! $col->isNullable())    $cb->addf('->nonnull()');
        if($col->isUnique())        $cb->addf('->unique()');
        if($def is nonnull)         $cb->addf('->default(%s)', $def); 
        if($con is nonnull)         $cb->addf('->check(%s)', $con); 

        $cb->add(',');
        $cb->ensureNewLine();
    }

    private function hackTable(HackBuilder $cb, Table $table) : void { 
        $cb->addf('new Table("%s", vec[', $table->getName());
        $cb->ensureNewLine();
        $cb->indent();

        foreach($table->getColumns() as $col) $this->hackColumn($cb, $col);

        $cb->unindent();
        $cb->add(']);');
    }

    public function writeHack(?string $namespace) : void { 

        $path = $this->dir.'/schema.hack'; 

        echo "[-] Creating $path"; 

        $hack = new HackCodegenFactory(new HackCodegenConfig()); 
        $cg = $hack->codegenFile($path);
        if($namespace is nonnull) $cg->setNamespace($namespace); 


        $tables = $this->schema; // Eventually the schema will be wrapped
        
        $tbc = $hack->codegenHackBuilder();
        foreach($tables as $table) $this->hackTable($tbc, $table);

        
        $cg->useNamespace('catarini\db')
            ->useType('Column')
            ->addFunction(
                $hack->codegenFunction('_db_schema()')
                    ->setReturnType('db\Schema')
                    ->setBody(

                        $hack->codegenHackBuilder()
                            ->add('return vec[')
                            ->ensureNewLine()
                            ->indent()
                            ->add($tbc->getCode())
                            ->unindent()
                            ->add('];')
                            ->getCode()
                    )
            );
    }

}