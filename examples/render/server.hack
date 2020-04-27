


<<__EntryPoint>>
function main() : noreturn { 

    $C = Catarini::GET(); 

    $C->route()
        ->get('/home')      ->xhp( () ==>   <p>Hi!</p>                 ) 
        ->get('/page')      ->xhp( () ==>   example_render__test()     )
        ->get('/test/$id')  ->xhp( () ==>   example_render__id()       );
        
        // -> get('test:') - automatic IDs feature 

    exit(0); 

}

function example_render__test() : XHPRoot { 
    return <p>Yep!</p>;
}

function example_render__id() : XHPRoot { 
    return <p>ID: </p>; 
}