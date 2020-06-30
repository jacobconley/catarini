namespace catarini\cli; 

use Facebook\HackCodegen\{
    CodegenFileType,
    HackCodegenConfig,
    HackCodegenFactory,
    HackBuilderValues
};

final class GenerateCommand { 

    private string $root; 

    public function __construct(?string $root = NULL) { 
        $this->root = $root ?? \catarini\meta\CONFIG::getRoot();
    }

    public function migration(?string $name) : void { 
        $name = $name ? "_$name" : ''; 

        $root   = $this->root; 
        $time   = '_'.\strval(\time()); 
        $dbdir  = "$root/db";
        
        if(!\is_dir($dbdir)) {
            if(\file_exists($dbdir)) { 
                throw new \catarini\exceptions\InvalidEnvironment("Trying to create `db` directory, but there exists a file of the same name"); 
            }
            else { 
                echo "[-] Creating directory $dbdir\n"; 
                \mkdir($dbdir); 
            }
        }

        $name = "migration$name$time";
        $filename = "$name.hack"; 
        $filepath = "$dbdir/$filename";
        echo "[-] Creating $filepath\n";

        $cg = new HackCodegenFactory(new HackCodegenConfig()); 
        $cg->codegenFile($filepath)
            ->useNamespace('catarini\db\migration')
            ->addClass(
                $cg->codegenClass($name)
                ->setExtends('migration\AutomaticMigration')
                ->addMethod(
                    $cg->codegenMethod('load')
                    ->setReturnType('void')
                )
            )
            ->setIsSignedFile(FALSE)
            ->save();

    }

}