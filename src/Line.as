package
{
import flash.display3D.Context3D;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.display3D.textures.Texture;
import flash.geom.Point;

public class Line
{
    private var _context:Context3D;
    private var _points:Vector.<Point>;
    private var _vertexBuffer:VertexBuffer3D;
    private var _indexBuffer:IndexBuffer3D;
    private var _texture:Texture;
    private var _program:Program3D;

    public function Line(context:Context3D, texture:Texture, program:Program3D, points:Vector.<Point>)
    {
        _context = context;
        _texture = texture;
        _points = points;
        _program = program;

        var vertices:Vector.<Number> = new Vector.<Number>();

        var n:int = points.length;
        for (var i:int = 0; i < n - 1; i++)
        {
            vertices = vertices.concat(Quad.getVertices(points[ i ], points[ i + 1 ], 0.3));
        }

        var numPerVertex:int = 4;
        var numVertecies:int = vertices.length / numPerVertex;

        _vertexBuffer = context.createVertexBuffer(numVertecies, numPerVertex, "staticDraw");
        _vertexBuffer.uploadFromVector(vertices, 0, numVertecies);

        var indices:Vector.<uint> = Vector.<uint>([ 0, 1, 2]);

        _indexBuffer = context.createIndexBuffer(indices.length, "staticDraw");
        _indexBuffer.uploadFromVector(indices, 0, indices.length);
    }

    public function draw():void
    {
        _context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
        _context.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
        _context.setTextureAt(0, _texture);
        _context.setProgram(_program);

        _context.drawTriangles(_indexBuffer);
    }
}
}
