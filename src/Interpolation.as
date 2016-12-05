package
{
public class Interpolation
{
    public function Interpolation()
    {
    }

    public function akima(x:Vector.<Number>, y:Vector.<Number>, xi:Vector.<Number>):Vector.<Number>
    {
        var n:int = x.length;
        if (n != y.length)
            throw new Error("input x and y arrays must be of same length");
        var dx:Vector.<Number> = diff(x);

        if (any(lessEqual(dx, 0)))
            throw new Error("input x-array must be in strictly ascending order");

        if (any(less(xi, x[ 0 ])) || any(more(xi, x[ n - 1 ])))
            throw new Error("All interpolation points xi must lie between x(1) and x(n)");

        var m:Vector.<Number> = divide(diff(y), dx);
        var mm:Number = 2 * m[ 0 ] - m[ 1 ];
        var mmm:Number = 2 * mm - m[ 0 ];
        var mp:Number = 2 * m[ n - 2 ] - m[ n - 3 ];
        var mpp:Number = 2 * mp - m[ n - 2 ];
        var m1:Vector.<Number> = new Vector.<Number>();
        m1.push(mmm);
        m1.push(mm);

        var n:int = m.length;
        for (var i:int = 0; i < n; i++)
        {
            m1.push(m[ i ]);
        }

        m1.push(mp);
        m1.push(mpp);

        var dm:Vector.<Number> = abs(diff(m1));
        var f1:Vector.<Number> = range(dm, 2, n + 3);
        var f2:Vector.<Number> = range(dm, 0, n + 1);
        var f12:Vector.<Number> = plus(f1, f2);

        var id:Vector.<int> = findMoreThen(f12, 0.00000001 * max(f12));
        var b:Vector.<Number> = range(m1, 1, n + 2);
        b = equal(b, divide(plus(multiply(vect(f1, id), vect(m1, plusScalar(id, 1))),
                                 multiply(vect(f2, id), vect(m1, plusScalar(id, 2)))), vect(f12, id)));
        var c:Vector.<Number> = divide(
                minus(minus(multiplyByScalar(m, 3), multiplyByScalar(range(b, 0, n), 2)), range(b, 1, n + 1)), dx);
        var d:Vector.<Number> = divide(minus(plus(range(b, 0, n), range(b, 1, n + 1)), multiplyByScalar(m, 2)),
                                       sqr(dx));

        var bin:Vector.<int> = histc(xi, x);
        bin = min(bin, n);

        var bb:Vector.<int> = rangeInt(bin, 0, xi.length);
        bb = plusScalar(bb, -1);

        var wj:Vector.<Number> = minus(xi, vect(x, bb));
        var yi:Vector.<Number> = plus(
                multiply(plus(multiply(plus(multiply(wj, vect(d, bb)), vect(c, bb)), wj), vect(b, bb)), wj),
                vect(y, bb));

        return yi;
    }

    private function min(x:Vector.<int>, value:int):Vector.<int>
    {
        var n:int = x.length;
        var result:Vector.<int> = new Vector.<int>(n, true);
        for (var i:int = 0; i < n; i++)
        {
            if (x[ i ] > value)
                result[ i ] = value;
            else
                result[ i ] = x[ i ];
        }
        return result;
    }

    private function histc(x:Vector.<Number>, y:Vector.<Number>):Vector.<int>
    {
        var ind:Vector.<int> = new Vector.<int>(x.length, true);
        var m:int = y.length - 1;
        var n:int = x.length;
        for (var j:int = 0; j < m; j++)
        {
            for (var i:int = 0; i < n; i++)
            {
                if (x[ i ] >= y[ j ] && x[ i ] < y[ j + 1 ])
                    ind[ i ] = j + 1;
            }
        }
        for (i = 0; i < n; i++)
        {
            if (!ind[ i ])
                ind[ i ] = y.length;
        }
        return ind;
    }

    private function sqr(x:Vector.<Number>):Vector.<Number>
    {
        var n:int = x.length;
        var result:Vector.<Number> = new Vector.<Number>(n, true);
        for (var i:int = 0; i < n; i++)
        {
            result[ i ] = x[ i ] * x[ i ];
        }
        return result;
    }

    private function equal(x:Vector.<Number>, y:Vector.<Number>):Vector.<Number>
    {
        var n:int = x.length;
        for (var i:int = 0; i < n; i++)
        {
            x[ i ] = y[ i ];
        }
        return x;
    }

    private function vect(x:Vector.<Number>, indecies:Vector.<int>):Vector.<Number>
    {
        var result:Vector.<Number> = new Vector.<Number>();
        var n:int = indecies.length;
        for (var i:int = 0; i < n; i++)
        {
            result.push(x[ indecies[ i ] ]);
        }
        return result;
    }

    private function findMoreThen(x:Vector.<Number>, value:Number):Vector.<int>
    {
        var indecies:Vector.<int> = new Vector.<int>();
        var n:int = x.length;
        for (var i:int = 0; i < n; i++)
        {
            if (x[ i ] > value)
                indecies.push(i);
        }
        return indecies;
    }

    private function max(x:Vector.<Number>):Number
    {
        var result:Number = x[ 0 ];
        var n:int = x.length;
        for (var i:int = 1; i < n; i++)
        {
            if (result < x[ i ])
                result = x[ i ];
        }
        return result;
    }

    private function range(x:Vector.<Number>, start:int, finish:int):Vector.<Number>
    {
        var result:Vector.<Number> = new Vector.<Number>(finish - start, true);

        for (var i:int = start; i < finish; i++)
        {
            result[ i - start ] = x[ i ];
        }
        return result;
    }

    private function rangeInt(x:Vector.<int>, start:int, finish:int):Vector.<int>
    {
        var result:Vector.<int> = new Vector.<int>(finish - start, true);

        for (var i:int = start; i < finish; i++)
        {
            result[ i - start ] = x[ i ];
        }
        return result;
    }

    private function abs(x:Vector.<Number>):Vector.<Number>
    {
        var result:Vector.<Number> = x.concat();
        var n:int = result.length;
        for (var i:int = 0; i < n; i++)
        {
            result[ i ] = Math.abs(result[ i ]);
        }
        return result;
    }

    private function plusScalar(x:Vector.<int>, value:int):Vector.<int>
    {
        var n:int = x.length;
        var result:Vector.<int> = new Vector.<int>(x.length, true);
        for (var i:int = 0; i < n; i++)
        {
            result[ i ] = x[ i ] + value;
        }
        return result;
    }

    private function plus(x:Vector.<Number>, y:Vector.<Number>):Vector.<Number>
    {
        var result:Vector.<Number> = x.concat();
        var n:int = result.length;
        for (var i:int = 0; i < n; i++)
        {
            result[ i ] += y[ i ];
        }
        return result;
    }

    private function minus(x:Vector.<Number>, y:Vector.<Number>):Vector.<Number>
    {
        var result:Vector.<Number> = x.concat();
        var n:int = result.length;
        for (var i:int = 0; i < n; i++)
        {
            result[ i ] -= y[ i ];
        }
        return result;
    }

    private function divide(x:Vector.<Number>, y:Vector.<Number>):Vector.<Number>
    {
        var result:Vector.<Number> = x.concat();
        var n:int = result.length;
        for (var i:int = 0; i < n; i++)
        {
            result[ i ] /= y[ i ];
        }
        return result;
    }

    private function multiplyByScalar(x:Vector.<Number>, value:Number):Vector.<Number>
    {
        var n:int = x.length;
        var result:Vector.<Number> = new Vector.<Number>(n, true);
        for (var i:int = 0; i < n; i++)
        {
            result[ i ] = x[ i ] * value;
        }
        return result;
    }

    private function multiply(x:Vector.<Number>, y:Vector.<Number>):Vector.<Number>
    {
        var result:Vector.<Number> = x.concat();
        var n:int = result.length;
        for (var i:int = 0; i < n; i++)
        {
            result[ i ] *= y[ i ];
        }
        return result;
    }

    private function any(x:Vector.<Boolean>):Boolean
    {
        var n:int = x.length;
        for (var i:int = 0; i < n; i++)
        {
            if (x[ i ])
                return true;
        }
        return false;
    }

    private function less(x:Vector.<Number>, value:Number):Vector.<Boolean>
    {
        var n:int = x.length;
        var result:Vector.<Boolean> = new Vector.<Boolean>(n, true);

        for (var i:int = 0; i < n; i++)
        {
            result[ i ] = x[ i ] < value;
        }
        return result;
    }

    private function lessEqual(x:Vector.<Number>, value:Number):Vector.<Boolean>
    {
        var n:int = x.length;
        var result:Vector.<Boolean> = new Vector.<Boolean>(n, true);

        for (var i:int = 0; i < n; i++)
        {
            result[ i ] = x[ i ] <= value;
        }
        return result;
    }

    private function more(x:Vector.<Number>, value:Number):Vector.<Boolean>
    {
        var n:int = x.length;
        var result:Vector.<Boolean> = new Vector.<Boolean>(n, true);

        for (var i:int = 0; i < n; i++)
        {
            result[ i ] = x[ i ] > value;
        }
        return result;
    }

    private function moreEqual(x:Vector.<Number>, value:Number):Vector.<Boolean>
    {
        var n:int = x.length;
        var result:Vector.<Boolean> = new Vector.<Boolean>(n, true);

        for (var i:int = 0; i < n; i++)
        {
            result[ i ] = x[ i ] >= value;
        }
        return result;
    }

    private function diff(x:Vector.<Number>):Vector.<Number>
    {
        var n:int = x.length - 1;
        var result:Vector.<Number> = new Vector.<Number>(n, true);
        for (var i:int = 0; i < n; i++)
        {
            result[ i ] = x[ i + 1 ] - x[ i ];
        }
        return result;
    }
}
}
