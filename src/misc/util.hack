namespace catarini\util;

use catarini\log; 

function ensure_dir(string $dir) : void 
{ 
        if(!\is_dir($dir)) {
            if(\file_exists($dir)) { 
                throw new \Exception("Trying to create directory`$dir`, but there exists a file of the same name"); 
            }
            else { 
                log\create_dir($dir); 
                \mkdir($dir); 
            }
        }
}

// Maybe make this with file? 