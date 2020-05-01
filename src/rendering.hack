namespace catarini\render; 



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

function html((function(): \XHPRoot) $lambda) : noreturn { 
    $C = \Catarini::GET(); 

    //TODO: Asset pipeline stuff! 

    $html = $C->html();
    $body = null;  


    try { 
        $body = $lambda(); 
    }   
    catch(\catarini\exception\Renderable $cex) { 

        \http_response_code($cex->getHttpStatus()); 
        $body = $cex->xhp(); 

    }
    catch(\Exception $ex) { 
        \http_response_code(500); 
        $body = $C->errors()->_invoke_xhp(500); 
    }

    $html->append($body); 
    $html->render(); 
    \exit(0); 
}