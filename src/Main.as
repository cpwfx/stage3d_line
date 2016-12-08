package
{
import com.adobe.utils.AGALMiniAssembler;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Program3D;
import flash.display3D.textures.Texture;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.utils.getTimer;

[SWF(width="800", height="600")]
public class Main extends Sprite
{
    [Embed(source="../imgs/wood.png")]
    protected const TextureBitmap:Class;

    protected var texture:Texture;
    protected var sceneTexture:Texture;

    protected var context3D:Context3D;
    protected var program:Program3D;

    private var _line:Line;

    public function Main()
    {
        stage.stage3Ds[ 0 ].addEventListener(Event.CONTEXT3D_CREATE, initMolehill);
        stage.stage3Ds[ 0 ].requestContext3D();

        addEventListener(Event.ENTER_FRAME, onRender);
    }

    protected function initMolehill(e:Event):void
    {
        context3D = stage.stage3Ds[ 0 ].context3D;
        context3D.configureBackBuffer(800, 600, 1, true);

        sceneTexture = context3D.createTexture(256, 256, Context3DTextureFormat.BGRA, false);

        var bitmap:Bitmap = new TextureBitmap();
        texture = context3D.createTexture(bitmap.bitmapData.width, bitmap.bitmapData.height, Context3DTextureFormat.BGRA, false);
        texture.uploadFromBitmapData(bitmap.bitmapData);

        var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
        vertexShaderAssembler.assemble(Context3DProgramType.VERTEX,
                                       "m44 op, va0, vc0\n" + // pos to clipspace
                                       "mov v0, va1" // copy UV
        );

        var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
        fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT,
                                         "tex ft1, v0, fs0 <2d>\n" +
                                         "mov oc, ft1"
        );

        program = context3D.createProgram();
        program.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);

        _line = new Line(context3D, texture, program, new <Point>[ new Point(100, 100), new Point(200, 200) ]);
    }

    protected function onRender(e:Event):void
    {
        if (!context3D)
            return;

        context3D.clear(0, 0, 0, 0.5);

        var m:Matrix3D = new Matrix3D();

        context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
        _line.draw();
        context3D.present();
    }
}
}
