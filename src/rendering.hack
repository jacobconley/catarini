namespace catarini\render; 

use catarini\exception;

// Error handling


class ErrorHandler { 

    // Callbacks - take an HTTP status?  Not sure how else to do it 

    private ?(function(int): \XHPRoot) $xhp; 
    public function xhp((function(int): \XHPRoot) $lambda) : ErrorHandler { 
        $this->xhp = $lambda; 
        return $this; 
    }

    // Private API 

    public function _invoke_xhp(int $status) : \XHPRoot { 
        $x = $this->xhp; 
        if($x is nonnull) return $x($status);
        else return \_CatariniXHP::http_error($status); 
    }
}



//
// "Main methods"
// 

function xhp(\XHPRoot $body) : noreturn { 
    $C = \Catarini::GET(); 

    //TODO: Asset pipeline stuff! 

    $html = $C->html();

    $html->append($body); 
    $html->render(); 

    \exit(); 
}


function xhp_exception(exception\Renderable $cex) : noreturn { 
   \http_response_code($cex->getHttpStatus());
    \catarini\render\xhp($cex->xhp());
}

function xhp_lambda((function(): \XHPRoot) $lambda) : noreturn { 
    $C = \Catarini::GET(); 


    try { 
        \catarini\render\xhp($lambda());
    }   
    catch(\catarini\exception\Renderable $cex) { 
        xhp_exception($cex); 
    }
    catch(\Exception $ex) { 
        \http_response_code(500); 
        \catarini\render\xhp($C->errors()->_invoke_xhp(500));
    }
}