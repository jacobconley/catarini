use \simian\framework\WebFramework; 
use \simian\framework\FrameworkException; 

abstract class :framework:template extends :x:element 
{
	category %FRAMEWORK;

	attribute ?WebFramework FRAMEWORK;
	protected function FRAMEWORK() : WebFramework {
		$x = $this->getContext('FRAMEWORK') as ?WebFramework;
		if($x !== null) {
			/* HH_IGNORE_ERROR[4110] */
			return $x; 
		}
		throw new FrameworkException("No framework supplied to XHP framework template");
	}

	public function PrepareForRender() : void { 
		// 
	} 
}


function sxhp_meta_charset() : XHPRoot { return <meta charset="UTF-8" />; }
function sxhp_css(string $url) : XHPRoot { return <link rel="stylesheet" type="text/css" href={ $url } />; }
function sxhp_js(string $url)  : XHPRoot { return <script type="text/javascript" src={ $url }></script>; } 
function sxhp_nav() : XHPRoot { return <nav id="LOCALES" aria-label="Change Language"></nav>; }
function sxhp_link(string $href, string $text) : XHPRoot { return <a href={$href}>{$text}</a>; }


function sxhp_render(?XHPRoot $operand, simian\framework\WebFramework $FRAMEWORK) : void { 
	if($operand is :framework:template) {
		$operand->setAttribute('FRAMEWORK', $FRAMEWORK); 
		$operand->setContext('FRAMEWORK', $FRAMEWORK); 
		$operand->PrepareForRender(); 
	}

	$titleStr = $FRAMEWORK->getHtmlTitle();
	$title = $titleStr == NULL ? NULL : <title>{$titleStr}</title>;

	echo <html>
		<head>
			{ $title }
			{ $FRAMEWORK->getHtmlHead() }
		</head>
		<body>
			{ $FRAMEWORK->getHtmlBody() }
			{ $operand }
		</body>
	</html>;
}

use namespace HH\Lib\Str;

class sxhp_unsafe_text implements XHPUnsafeRenderable { 
	private string $content;

	public function __construct(string $content) { 
		$this->content = $content;
	}

	public function toHTMLString() : string { return $this->content; }

}

class sxhp_unsafe_file implements XHPUnsafeRenderable {
	private string $content;

	public function __construct(string $file, simian\framework\BaseFramework $FRAMEWORK) { 
		$path = $FRAMEWORK->PATH($file);
		$content = file_get_contents($path); 

		if($content === FALSE) throw new FrameworkException("Couldn't open file $path");

		// Strip leading xml tag if present
		if(Str\starts_with_ci($content, "<?xml")) {
			$start = Str\search($content, "?>");
			if($start != NULL && $start + 2 < strlen($content)) $content = Str\slice($content, $start + 2);
			else {
				$content = "<!-- INVALID XML: ".$file." -->";
				error_log("Invalid XML at $file: Expected ?> tag");
			}
		}

		$this->content = $content;
	}

	public function toHTMLString() : string { return $this->content; }
}