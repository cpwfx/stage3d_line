package
{
import flash.geom.Point;

public class CoordsConverter
{
    private var _stageW:Number;
    private var _stageH:Number;

    public function CoordsConverter(stageW:Number, stageH:Number)
    {
        _stageW = stageW;
        _stageH = stageH;
    }

    public function getPoint(pt:Point):Point
    {
        var convertedPt:Point = new Point();
        convertedPt.x = getPointX(pt.x);
        convertedPt.y = getPointY(pt.y);
        return convertedPt;
    }

    public function getPointX(x:Number):Number
    {
        return (x - _stageW / 2) / _stageW * 2;
    }

    public function getPointY(y:Number):Number
    {
        return - (y - _stageH / 2) / _stageH * 2;
    }
}
}
