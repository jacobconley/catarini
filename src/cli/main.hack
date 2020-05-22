namespace catarini\cli;

use HH\Lib\{ Str };

function bad_command(string $command) : noreturn { 
    echo "[!] Unknown command '$command'.\n";
    echo "[?] Use `catarini help` for a list of commands\n";
    \exit(1);
}

function bad_subcommand(string $subcommand, string $main) : noreturn { 
    echo "[!] Unknown argument '$subcommand' for '$main'.\n";
    echo "[?] Use `catarini help:$main` for more information.\n";
    \exit(1);
}

function no_subcommand(string $command) : noreturn { 
    echo "[!] This command needs an argument\n";
    echo "[?] Use `catarini help:$command` for more information.\n";
    \exit(1); 
}

function bad_option(string $option) : noreturn { 
    echo "[!] Unknown option '$option'.\n";
    echo "[?] use `catarini help` for a list of commands.\n";
    \exit(1);
}


class CLI {

    private ?string $root;

    //TODO: Help command
    //TODO: Lists of commands in above
    public function main(array<string> $argv) : noreturn { 
        $argc = \count($argv);

        if($argc == 1) { 
            echo "[!] No command given\n";
            echo "[?] Use `catarini help` for a list of commands\n";
            \exit(1); 
        }

        for($i = 1; $i < $argc; $i++) { 
            $arg = $argv[$i];


            //
            // Command line args
            //
            if(Str\starts_with($arg, '--root=')) { 
                $root = \explode('=', $arg)[1];
                $this->root = $root; // Is this necessary? 
                \catarini\meta\CONFIG::_forceRoot($root);
                continue;
            }

            if(Str\starts_with($arg, '--')) { 
                bad_option(  \explode('=',  Str\slice($arg, 2)  )[0]  );
            }


            // 
            // Actual commands
            //


            $split = \explode(':', $arg); 
            $splitc = \count($split); 

            switch($split[0]) { 

                case 'help':
                    help($split[1] ?? NULL); 


                case 'generate':
                case 'g':
                if($splitc < 2) no_subcommand($split[1]); 
                switch($split[1]){

                    case 'migration':
                    case 'project': 

                        break; 


                    default: bad_subcommand($split[1], $split[0]); 
                }
                break;


                case 'db':
                if($splitc < 2) no_subcommand($split[1]); 
                switch($split[1]){

                    case 'drop':

                    case 'seed':
                    case 'reseed':

                    case 'migrate':
                    case 'rollback': 

                        break; 


                    default: bad_subcommand($split[1], $split[0]); 
                }
                break;

                default: bad_command($split[0]);    
            }

        }

        exit(0); 
    }

}

function help(?string $command = NULL) : noreturn { 

    switch($command) { 
        case NULL:
            echo "List of commands (or alias):\n";
            echo "- `generate:<type>` (or `g`) - Generate project files\n";
            echo "- `db:<command>` - Database commands\n";
            echo "[?] Use `catarini help:<command>` for more information about the above commands.\n";
            break;

        default: 
            echo "[!] Unknown help topic '$command'.\n";
            echo "[?] Use `catarini help` for a list of topics\n";
    }

    \exit(0); 
}