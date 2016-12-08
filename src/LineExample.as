package
{
import flash.display.Sprite;
import flash.display3D.Context3D;
import flash.events.Event;
import flash.geom.Point;

[SWF(width="800", height="600", frameRate="60", backgroundColor="#333333")]
public class LineExample extends Sprite
{
    private var context3D:Context3D;
    private var _line:Line;

    public function LineExample()
    {
        stage.stage3Ds[ 0 ].addEventListener(Event.CONTEXT3D_CREATE, initMolehill);
        stage.stage3Ds[ 0 ].requestContext3D();

        addEventListener(Event.ENTER_FRAME, onRender);
    }

    private function initMolehill(event:Event):void
    {
        context3D = stage.stage3Ds[ 0 ].context3D;
        context3D.configureBackBuffer(800, 600, 1, true);

        var pts:Vector.<Point> = new Vector.<Point>();
        pts.push(new Point(200, 200));
        pts.push(new Point(300, 200));
        pts.push(new Point(400, 300));
        pts.push(new Point(200, 500));
        _line = new Line(context3D,  pts);
    }

    protected function onRender(e:Event):void
    {
        if (!context3D)
            return;

        context3D.clear(0, 0, 0, 1);
        _line.draw();
        context3D.present();
    }
}
}
