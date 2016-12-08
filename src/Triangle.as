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

[SWF(width="800", height="600", frameRate="60", backgroundColor="#333333")]
public class Triangle extends Sprite
{
    [Embed(source="../imgs/cat.png")]
    private const TextureBitmap:Class;
    private var texture:Texture;

    private var context3D:Context3D;
    private var program:Program3D;
    private var vertexbuffer:VertexBuffer3D;
    private var indexbuffer:IndexBuffer3D;

    public function Triangle()
    {
        stage.stage3Ds[ 0 ].addEventListener(Event.CONTEXT3D_CREATE, initMolehill);
        stage.stage3Ds[ 0 ].requestContext3D();

        addEventListener(Event.ENTER_FRAME, onRender);
    }

    private function initMolehill(event:Event):void
    {
        context3D = stage.stage3Ds[ 0 ].context3D;
        context3D.configureBackBuffer(800, 600, 1, true);

        var vertices:Vector.<Number> = Vector.<Number>([
                                                           -0.3, -0.3, 0, 1, // x, y, z, u, v
                                                           -0.3,  0.3, 0, 0,
                                                            0.3,  0.3, 1, 0,
                                                            0.3, -0.3, 1, 1
                                                       ]);

        var vertices1:Vector.<Number> = Vector.<Number>([
                                                            -0.3, -0.3, 0, 1, // x, y, z, u, v
                                                            -0.3,  0.3, 0, 0,
                                                            0.3,  0.3, 1, 0,
                                                            0.3, -0.3, 1, 1,
                                                           -0.6, -0.6, 0, 1, // x, y, z, u, v
                                                           -0.6,  0.6, 0, 0,
                                                            0.6,  0.6, 1, 0,
                                                            0.6, -0.6, 1, 1
                                                       ]);

        vertexbuffer = context3D.createVertexBuffer(vertices1.length / 4, 4);
        vertexbuffer.uploadFromVector(vertices1, 0, vertices1.length / 4);

        var indices:Vector.<uint> = Vector.<uint>([ 0, 1, 2, 0, 2, 3 ]);

        var resultIndices:Vector.<uint> = indices.concat();
        var n:int = indices.length;
        for (var i:int = 0; i < n; i++)
        {
              resultIndices.push(indices[i] + 4);
        }

        indexbuffer = context3D.createIndexBuffer(resultIndices.length);
        indexbuffer.uploadFromVector(resultIndices, 0, resultIndices.length);

        var bitmap:Bitmap = new TextureBitmap();
        bitmap.alpha = 0.3;
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
    }

    protected function onRender(e:Event):void
    {
        if (!context3D)
            return;

        context3D.clear(0, 0, 0, 1);

        // vertex position to attribute register 0
        context3D.setVertexBufferAt(0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
        // UV to attribute register 1
        context3D.setVertexBufferAt(1, vertexbuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
        // assign texture to texture sampler 0
        context3D.setTextureAt(0, texture);
        // assign shader program
        context3D.setProgram(program);

        var m:Matrix3D = new Matrix3D();
        m.identity();
        context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);

        context3D.drawTriangles(indexbuffer);

        context3D.present();
    }
}
}
