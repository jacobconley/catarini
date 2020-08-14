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


    public function _hackColumn(HackBuilder $cb, Column $col) : void { 
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

    public function _hackTable(HackBuilder $cb, Table $table) : void { 
        $cb->addf('new Table("%s", vec[', $table->getName());
        $cb->ensureNewLine();
        $cb->indent();

        foreach($table->getColumns() as $col) $this->_hackColumn($cb, $col);

        $cb->unindent();
        $cb->add(']),');
        $cb->ensureNewLine();
        $cb->ensureEmptyLine();
    }

    public function writeHack(?string $namespace) : void { 
        $dir = $this->dir; 
        \catarini\util\ensure_dir($dir); 
        $path = $dir.'schema.php';  //TODO: Change to .hack when updating codegen version?
                                    // This oughtta be logged..

        echo "[-] Creating $path"; 

        $hack = new HackCodegenFactory(new HackCodegenConfig()); 
        $cg = $hack->codegenFile($path);
        if($namespace is nonnull) $cg->setNamespace($namespace); 


        $tables = $this->schema; // Eventually the schema will be wrapped
        
        $tbc = $hack->codegenHackBuilder();
        foreach($tables as $table) $this->_hackTable($tbc, $table);

        
        $cg->useNamespace('catarini\db')
            ->useType('catarini\db\Table')
            ->useType('catarini\db\Column')
            ->useType('catarini\db\Type')

            ->addFunction(
                $hack->codegenFunction('_db_schema')
                    ->setReturnType('db\Schema')
                    ->setBody(

                        $hack->codegenHackBuilder()
                            ->add('return vec[')
                            ->ensureNewLine()
                            ->ensureEmptyLine()

                            ->indent()
                            ->add($tbc->getCode())
                            ->unindent()
                            ->ensureNewLine()

                            ->add('];')
                            ->getCode()
                    )
        );

        $cg->save();
    }

}