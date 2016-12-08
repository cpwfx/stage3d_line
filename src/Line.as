package
{
import com.adobe.utils.AGALMiniAssembler;

import flash.display.Bitmap;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.display3D.textures.Texture;
import flash.geom.Matrix3D;
import flash.geom.Point;

public class Line
{
    [Embed(source="../imgs/cat.png")]
    private const TextureBitmap:Class;
    private var texture:Texture;

    private var _context:Context3D;
    private var _points:Vector.<Point>;
    private var _vertexBuffer:VertexBuffer3D;
    private var _indexBuffer:IndexBuffer3D;
    private var _program:Program3D;

    public function Line(context:Context3D, points:Vector.<Point>)
    {
        _context = context;
        _points = points;

        var coordsConverter:CoordsConverter = new CoordsConverter(800, 600);

        var vertices:Vector.<Number> = new Vector.<Number>();

        var n:int = points.length;
        for (var i:int = 0; i < n - 1; i++)
        {
            vertices = vertices.concat(Quad.getVertices(coordsConverter.getPoint(points[ i ]), coordsConverter.getPoint(points[ i + 1 ]), 0.2));
        }

        var numPerVertex:int = 4;
        var numVertices:int = vertices.length / numPerVertex;

        _vertexBuffer = context.createVertexBuffer(numVertices, numPerVertex, "staticDraw");
        _vertexBuffer.uploadFromVector(vertices, 0, numVertices);

        var indices:Vector.<uint> = Vector.<uint>([ 0, 1, 2, 1, 2, 3 ]);

        var m:int = numVertices / 4;
        n = indices.length;
        for (var j:int = 1; j < m; j++)
        {
            for (i = 0; i < n; i++)
            {
                indices.push(indices[ i ] + 4 * j);
            }
        }

        _indexBuffer = context.createIndexBuffer(indices.length, "staticDraw");
        _indexBuffer.uploadFromVector(indices, 0, indices.length);

        var bitmap:Bitmap = new TextureBitmap();
        texture = context.createTexture(bitmap.bitmapData.width, bitmap.bitmapData.height, Context3DTextureFormat.BGRA,
                                        false);
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

        _program = context.createProgram();
        _program.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
    }

    public function draw():void
    {
        var m:Matrix3D = new Matrix3D();
        m.identity();

        _context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
        _context.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
        _context.setTextureAt(0, texture);
        _context.setProgram(_program);
        _context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
        _context.drawTriangles(_indexBuffer);
    }
}
}
