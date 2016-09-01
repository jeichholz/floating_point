# floating_point
A simple MATLAB class to for storing numbers in any floating point format.  Good for illustrating issues with floating point arithmetic.

##Usage
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
'''

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

'''
>> A=floating_point(10,20)

A = 

(base 10)
+0.0000000000000000000 x 10^-5 (APPROX: 0.000000) 
>> A(1)=.000365

A = 

(base 10)
+3.6499999999999998158 x 10^-4 (APPROX: 0.000365)
'''

This has incurred some roundoff error, despite the number .000365 being perfectly representable in the intended format.  To correct,
assign via a string or a sym.

'''
>> A(1)='.000365'

A = 

(base 10)
+3.6500000000000000001 x 10^-4 (APPROX: 0.000365)
'''

'''
>> A(1)=sym('365/1000000')

A = 

(base 10)
+3.6500000000000000000 x 10^-4 (APPROX: 0.000365)
'''


