# floating_point
A simple MATLAB class to for storing numbers in any floating point format.  Good for illustrating issues with floating point arithmetic.

# Usage
Declare a floating point with default options (base 10, 5 sig figs, min exponent -5, max exponent 5)
```
>> A=floating_point()

A = 

(base 10)
+0.0000 x 10^-5 (APPROX: 0.000000)
```
Alternatively, specify a base, number of sig figs, smallest allowable exponent and maximum allowable exponent.  floating_point numbers will overflow or underflow if they require an exponent under the minumum allowable or an exponent over the maximum to represent.

```
>> A=floating_point(2,5,-3,3)

A = 

(base 2)
+0.0000 x 2^-3 (APPROX: 0.000000)
```

Once you have a floating point number defined, you may assign into it as long as you use the indexing notation.

```
>> A=floating_point()

A = 

(base 10)
+0.0000 x 10^-5 (APPROX: 0.000000) 
>> A(1)=pi

A = 

(base 10)
+3.1416 x 10^0 (APPROX: 3.141600)
```

The value of pi is properly represented in A(1) as a floating point number in base 10 with 5 digits and exponent between -5 and 5.

Matrix indexing works properly,

```
>> A(2,2)=exp(1)

A = 

(base 10)
+3.1416 x 10^0 (APPROX: 3.141600) +0.0000 x 10^-5 (APPROX: 0.000000) 
+0.0000 x 10^-5 (APPROX: 0.000000) +2.7183 x 10^0 (APPROX: 2.718300) 
>>
```

However, if we try to assign `A=5` MATLAB will replace the floating_point A with the double 5.

```
>> A=5

A =

     5
```

floating points display everything in the base specified.

```
>> A=floating_point(3)

A = 

(base 3)
+0.0000 x 3^-5 (APPROX: 0.000000) 
>> B=floating_point(10)

B = 

(base 10)
+0.0000 x 10^-5 (APPROX: 0.000000) 
>> A(1)=1/3

A = 

(base 3)
+1.0000 x 3^-1 (APPROX: 0.333333) 
>> B(1)=1/3

B = 

(base 10)
+3.3333 x 10^-1 (APPROX: 0.333330) 
>>
```

## Representations
If you assign a regular matlab double to a floating point via matlab, of course any roundoff error incurred by storing in a double will propogate into floating_point storage.  However, you may also assign a string or sym into a floating_point to avoid this inital roundoff error.  For example:

```
>> A=floating_point(10,20)

A = 

(base 10)
+0.0000000000000000000 x 10^-5 (APPROX: 0.000000) 
>> A(1)=.000365

A = 

(base 10)
+3.6499999999999998158 x 10^-4 (APPROX: 0.000365)
```

This has incurred some roundoff error, despite the number .000365 being perfectly representable in the intended format.  To correct,
assign via a string or a sym.

```
>> A(1)='.000365'

A = 

(base 10)
+3.6500000000000000001 x 10^-4 (APPROX: 0.000365)
```

```
>> A(1)=sym('365/1000000')

A = 

(base 10)
+3.6500000000000000000 x 10^-4 (APPROX: 0.000365)
```

# Assignments and operators

Assignments work the way they should, use of the `:` operator is supported.

There are only two odd bits here.

* You can only redefine a floating_point if it is a scalar.
  - floating_point matrices must consist of exactly one storage format.
Attempting to insert a floating point with a different storage format is an error.  For instance:

```
>> A=floating_point(10,2)

A = 

(base 10)
+0.0 x 10^-5 (APPROX: 0.000000) 
>> A(1,2)=floating_point(10,3)
An array of floating_point must all have the same storage format.
Output argument "OBJ" (and maybe others) not assigned during call to "floating_point/subsasgn".
```

This was an attempt to insert a floating point in base 10 with 3 sig figs into a matrix of floating points with 2 sig figs.

We may, however, redefine the storage type if `A` is 1 x 1

```
>> A(1,1)=floating_point(2,5)

A = 

(base 2)
+0.0000 x 2^-5 (APPROX: 0.000000)
```

  - Using the `A(:,:)=B` notation will always suceed.  It will simply ensure that A is a pure copy of B, with the storage format of A applied.  For example:

```
>> A(:,:)=rand(3,3)

A = 

(base 2)
+1.100001101 x 2^-2 (APPROX: 0.381348) +1.011111101 x 2^-3 (APPROX: 0.186768) +1.010010110 x 2^-1 (APPROX: 0.646484) 
+1.100010000 x 2^-1 (APPROX: 0.765625) +1.111101011 x 2^-2 (APPROX: 0.489746) +1.011010110 x 2^-1 (APPROX: 0.708984) 
+1.100101110 x 2^-1 (APPROX: 0.794922) +1.110010001 x 2^-2 (APPROX: 0.445801) +1.100000101 x 2^-1 (APPROX: 0.754883) 
```

Standard operations are supported, including matrix addition, subtraction, scalar multiplication, matrix multiplication, and power.  Trigonometric functions are supported.  Note thate matrix multiplication is done properly, by representing each intermediate result as a floating point number.

# Conversions
floating_points can be converted to double or sym for use with other functions.  For example,

```
>> A=floating_point(2,10);
>> A(:,:)=rand(3,3)

A = 

(base 2)
+1.100001101 x 2^-2 (APPROX: 0.381348) +1.011111101 x 2^-3 (APPROX: 0.186768) +1.010010110 x 2^-1 (APPROX: 0.646484) 
+1.100010000 x 2^-1 (APPROX: 0.765625) +1.111101011 x 2^-2 (APPROX: 0.489746) +1.011010110 x 2^-1 (APPROX: 0.708984) 
+1.100101110 x 2^-1 (APPROX: 0.794922) +1.110010001 x 2^-2 (APPROX: 0.445801) +1.100000101 x 2^-1 (APPROX: 0.754883) 
>> 
>> 
>> double(A)

ans =

   0.381347656250000   0.186767578125000   0.646484375000000
   0.765625000000000   0.489746093750000   0.708984375000000
   0.794921875000000   0.445800781250000   0.754882812500000
```

or

```
>> sym(A)
 
ans =
 
[ 781/2048,  765/4096,  331/512]
[    49/64, 1003/2048,  363/512]
[  407/512,  913/2048, 773/1024]
```

# Special stuff that is really nice

floating_point numbers can report the next larger and next smaller representable floating_point numbers.  For example,

```
>> A=floating_point(2,5)

A = 

(base 2)
+0.0000 x 2^-5 (APPROX: 0.000000) 
>> next(A)

ans = 

(base 2)
+1.0000 x 2^-5 (APPROX: 0.031250) 
>> next(next(A))

ans = 

(base 2)
+1.0001 x 2^-5 (APPROX: 0.033203) 
>> next(next(next(A)))

ans = 

(base 2)
+1.0010 x 2^-5 (APPROX: 0.035156) 
>> next(next(next(next(A))))

ans = 

(base 2)
+1.0011 x 2^-5 (APPROX: 0.037109) 
>> prev(next(next(next(next(A)))))

ans = 

(base 2)
+1.0010 x 2^-5 (APPROX: 0.035156)
```

** Display
By setting the global variables fp_disp_repr, fp_disp_val, and fp_disp_base we can control the formatting of floating_point variables somewhat.

```
>> M

M = 

(base 10)
+1.00 x 10^0 (APPROX: 1.000000) -2.00 x 10^0 (APPROX: -2.000000) -4.00 x 10^2 (APPROX: -400.000000) +1.00 x 10^0 (APPROX: 1.000000) 
+0.00 x 10^-10 (APPROX: 0.000000) +1.00 x 10^0 (APPROX: 1.000000) +2.68 x 10^4 (APPROX: 26800.000000) +2.67 x 10^2 (APPROX: 267.000000) 
+0.00 x 10^-10 (APPROX: 0.000000) +0.00 x 10^-10 (APPROX: 0.000000) -1.96 x 10^7 (APPROX: -19600000.000000) -1.94 x 10^5 (APPROX: -194000.000000) 
>> global fp_disp_repr
>> fp_disp_repr=0;
>> M

M = 

(base 10)
1 -2 -400 1 
0 1 26800 267 
0 0 -1.96e+07 -194000 
>> global fp_disp_base
>> fp_disp_base=0;
>> M

M = 

1 -2 -400 1 
0 1 26800 267 
0 0 -1.96e+07 -194000 
>> global fp_disp_val
>> fp_disp_val=0;

>> fp_disp_repr=1;
>> M

M = 

+1.00 x 10^0 -2.00 x 10^0 -4.00 x 10^2 +1.00 x 10^0 
+0.00 x 10^-10 +1.00 x 10^0 +2.68 x 10^4 +2.67 x 10^2 
+0.00 x 10^-10 +0.00 x 10^-10 -1.96 x 10^7 -1.94 x 10^5

```