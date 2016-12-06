package
{
import com.adobe.utils.AGALMiniAssembler;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.display3D.textures.Texture;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Point;

[SWF(width="800", height="600")]
public class Main extends Sprite
{
    [Embed(source="../imgs/wood.png")]
    protected const TextureBitmap:Class;

    protected var texture:Texture;
    protected var sceneTexture:Texture;

    protected var context3D:Context3D;
    protected var program:Program3D;
    protected var program1:Program3D;
    protected var vertexbuffer:VertexBuffer3D;
    protected var indexbuffer:IndexBuffer3D;

    private var _coordConv:CoordsConverter;
    private var wholeScreenVertices:VertexBuffer3D;

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

        _coordConv = new CoordsConverter(800, 600);

        var A:Point = _coordConv.getPoint(new Point(0, 600));
        var B:Point = _coordConv.getPoint(new Point(800, 600));
        var vertices:Vector.<Number> = Quad.getVertecies(A, B, 1);

        // Create VertexBuffer3D. 4 vertices, of 4 Numbers each
        wholeScreenVertices = context3D.createVertexBuffer(4, 4);
        // Upload VertexBuffer3D to GPU. Offset 0, 4 vertices
        wholeScreenVertices.uploadFromVector(vertices, 0, 4);

        var indices:Vector.<uint> = Vector.<uint>([ 0, 1, 2, 2, 3, 1 ]);

        // Create IndexBuffer3D. Total of 3 indices. 1 triangle of 3 vertices
        indexbuffer = context3D.createIndexBuffer(6);
        // Upload IndexBuffer3D to GPU. Offset 0, count 3
        indexbuffer.uploadFromVector(indices, 0, 6);

        var bitmap:Bitmap = new TextureBitmap();
        texture = context3D.createTexture(bitmap.bitmapData.width, bitmap.bitmapData.height,
                                          Context3DTextureFormat.BGRA, false);
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

        program1 = context3D.createProgram();
        program1.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
    }

    public static function nextPowerOfTwo(v:uint):uint
    {
        v--;
        v |= v >> 1;
        v |= v >> 2;
        v |= v >> 4;
        v |= v >> 8;
        v |= v >> 16;
        v++;
        return v;
    }

    private function drawLine():void
    {
        var A:Point = _coordConv.getPoint(new Point(0, 100));
        var B:Point = _coordConv.getPoint(new Point(700, 100));
        var C:Point = _coordConv.getPoint(new Point(740, 200));

        var angle:Number = Math.atan2(B.y - A.y, B.x - A.x);
        var thickness:Number = 20 / stage.stageHeight;

        var segment1:Vector.<Number> = Quad.getVertecies(A, B, thickness);
        var segment2:Vector.<Number> = Quad.getVertecies(B, C, thickness);

        var vertices:Vector.<Number> = segment1.concat(segment2);
        var n:int = segment2.length;
        for (var i:int = 0; i < n; i++)
        {
            segment1.push(segment2[ i ]);
        }

        // Create VertexBuffer3D. 4 vertices, of 4 Numbers each
        vertexbuffer = context3D.createVertexBuffer(8, 4);
        // Upload VertexBuffer3D to GPU. Offset 0, 4 vertices
        vertexbuffer.uploadFromVector(segment1, 0, 8);
    }

    protected function onRender(e:Event):void
    {
        if (!context3D)
            return;
        //context3D.setRenderToTexture(sceneTexture);
        //context3D.setRenderToBackBuffer();
        context3D.clear(1, 1, 1, 1);
        drawLine();

        // vertex position to attribute register 0
        context3D.setVertexBufferAt(0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
        // UV to attribute register 1
        context3D.setVertexBufferAt(1, vertexbuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
        // assign texture to texture sampler 0
        context3D.setTextureAt(0, texture);
        // assign shader program
        context3D.setProgram(program);

        var m:Matrix3D = new Matrix3D();
        //m.appendRotation(getTimer()/40, Vector3D.Z_AXIS);

        context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
        context3D.drawTriangles(indexbuffer);

        context3D.present();
    }
}
}
