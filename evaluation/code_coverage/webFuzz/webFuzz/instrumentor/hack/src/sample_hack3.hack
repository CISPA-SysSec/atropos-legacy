namespace srec\modules;

function myfun1() : \xhp_span {
   return <span><script>{$_GET['var'] ?? "none"}</script></span>;
}
