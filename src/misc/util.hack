namespace catarini\util;

function ensure_dir(string $dir) : void 
{ 
        if(!\is_dir($dir)) {
            if(\file_exists($dir)) { 
                throw new \Exception("Trying to create directory`$dir`, but there exists a file of the same name"); 
            }
            else { 
                echo "[-] Creating directory $dir\n"; 
                \mkdir($dir); 
            }
        }
}

// Maybe make this with file? 