package
{
import flash.display.Sprite;

public class Main extends Sprite
{
    public function Main()
    {
        var interpolation:Interpolation = new Interpolation();
        var x:Vector.<Number> = new <Number>[ 0, 20, 45, 53, 57, 62, 74, 89, 95, 100 ];
        var y:Vector.<Number> = new <Number>[ 0, 0, -47, 335, 26, 387, 104, 0, 100, 0 ];
        var xi:Vector.<Number> = new Vector.<Number>();
        var n:int = 100 / 0.5;
        for (var i:int = 0; i <= n; i++)
        {
            xi.push(i * 0.5);
        }
        interpolation.akima(x, y, xi);
    }
}
}
