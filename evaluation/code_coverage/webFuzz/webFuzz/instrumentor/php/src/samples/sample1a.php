<?php
class SampleClass1
{
    private $var1;
    public $var2;
    function __construct($var1, $var2)
    {
        $this->var1 = $var1;
        $this->var2 = $var2;
    }
    function add12()
    {
        if (is_int($this->var1) || is_float($this->var1)) {
            $this->var1 += 12;
        } else {
            if (is_String($this->var1)) {
                $this->var1 .= '12';
            }
        }
        return $this;
    }
    
    function getVar1()
    {
        return $this->var1;
    }
    function setVar1($var1)
    {
        $this->var1 = $var1;
    }
}
function factorial($n)
{
    if ($n == 0) {
        return 1;
    }
    return $n * factorial($n - 1);
}
$x = new SampleClass(1, 234);
echo $x->add12()->getVar1(), "\n";
echo factorial($x->getVar1()), "\n";
$y = new SampleClass('1', '234');
echo $y->add12()->getVar1(), "\n";
$y->var2 = '567';
echo $y->var2;
