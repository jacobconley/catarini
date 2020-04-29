namespace catarini\cli;

function bad_command(string $command) : noreturn { 
    echo "Unknown command '$command'.";
    \exit(1);
}

function bad_subcommand(string $subcommand, string $main) : noreturn { 
    echo "Unknown command '$subcommand' in '$main'.";
    \exit(1);
}

//TODO: Help command
//TODO: Lists of commands in above

function main(array<string> $argv) : noreturn { 

    foreach($argv as $arg) { 

        $split = \explode(':', $arg); 
        switch($split[0]) { 

            case 'generate':
            case 'g':
            switch($split[1]){

                case 'migration':
                case 'project': 

                    break; 


                default: bad_subcommand($split[1], $split[0]); 
            }
            break;


            case 'db':
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