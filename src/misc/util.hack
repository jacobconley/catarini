namespace catarini\util;

use catarini\log; 


use Facebook\HackCodegen\{
    CodegenFileType,
    HackCodegenConfig,
    HackCodegenFactory,
    HackBuilderValues,
    HackBuilder,
    CodegenProperty
};

function ensure_dir(string $dir, int $mode = 0777) : string 
{ 
    if(!\is_dir($dir)) {
        if(\file_exists($dir)) { 
            throw new \Exception("Trying to create directory`$dir`, but there exists a file of the same name"); 
        }
        else { 
            log\create_dir($dir); 
            \mkdir($dir, $mode, TRUE); 
        }
    }

    return $dir; 
}

// Maybe make this with file? 







/**
 * Creates a hack codegen file in the specified directory
 * @param $dir Directory in which to create file
 * @param $file Name of file WITHOUT EXTENSION (In anticipation of the switch to .hack)
 * @return The whole path of the created file
 */
function HackCodegenFile(string $dir, string $file) : string { 
    ensure_dir($dir); 

    $path = "$dir/$file.php";
    log\write_file($path); 

    return $path; 
}