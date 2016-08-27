%floating_point_scalar is a class that accurately reflects storage and
%common operations on floating point numbers for observation by students.
%Numbers can be stored in any integer base, with any number of digits
%(properly significant figures, since the base is not necessarily 10).  
%Min and Max exponents are supported.
%You may choose to store an existing numeric value or a symbolic value as a
%floating point.  +,-,*,/ are supported. 
%Overflow and underflow are not yet implemented, and denormalized numbers
%are not supported. 
%
%Usefully, a floating point number has a next() method that returns the
%next representable floating point number in the storage format. 


classdef floating_point
    properties
        base=10;
        num_digits=-1;
        exponent=0;
        min_exp=-5;
        max_exp=5;
        digits=-1;
        value=sym(-Inf);
        sign=0;
    end
    
    methods
        function obj=floating_point(x,base,num_digits,min_exp,max_exp)
            if nargin==0
                x=0;
            end
            if ~exist('base','var') || isempty(base)
                obj.base=sym(10);
            else
                obj.base=sym(base);
            end
            if ~exist('num_digits','var') || isempty(num_digits)
                obj.num_digits=5;
            else
                obj.num_digits=num_digits;
            end
            if ~exist('min_exp','var') || isempty(min_exp)
                obj.min_exp=sym(-5);
            else
                obj.min_exp=sym(min_exp);
            end
            if ~exist('max_exp','var') || isempty(max_exp)
                obj.max_exp=sym(5);
            else
                obj.max_exp=sym(max_exp);
            end
            
            if isempty(x)
                x=0;
            end
                
            
            %If x is a string that represents a number in decimal form,
            %convert it to rational form.  Gets much better results out of
            %sym
            if isstr(x) && sum(x=='.')==1 && sum(isstrprop(x,'digit'))==(length(x)-1)
                dec_idx=find(x=='.');
                tmp_sym=sym(x(x~='.'));
                tmp_sym=tmp_sym/10^(length(x)-dec_idx);
                x=tmp_sym;
            else
                x=sym(x);
            end
            if x==0
                obj.digits=zeros(1,obj.num_digits);
                obj.sign=1;
                obj.exponent=obj.min_exp;
                obj.value=sym(0);
            else
                if x>0
                    obj.sign=1;
                else
                    obj.sign=-1;
                    x=-x;
                end
                obj.exponent=floor(log(x)/log(obj.base));
                min_exp=obj.exponent-obj.num_digits+1;
                
                %Round here
                if (abs(x-floor(x/obj.base^min_exp)*obj.base^min_exp)>abs(x-ceil(x/obj.base^min_exp)*obj.base^min_exp))
                    x=x+obj.base^min_exp;
                end
                %You rounded, re-evaluate the exponent 
                obj.exponent=floor(log(x)/log(obj.base));
                min_exp=obj.exponent-obj.num_digits+1;
                
                obj.digits(1)=floor(x/obj.base^min_exp);
                obj.value=floor(x/obj.base^min_exp)*obj.base^min_exp;
                for i=1:obj.num_digits
                    if (obj.digits(i)>=obj.base)
                        obj.digits(i+1)=floor(obj.digits(i)/obj.base);
                        obj.digits(i)=rem(obj.digits(i),obj.base);
                    end
                end
                
                
                
                
            end
            %I like the digits to read from left to right. 
            obj.digits=obj.digits(end:-1:1);
            
         %   obj.value=compute_value(obj);
         
                
        end
        
        %Get the exact (symbolic) value represented by the fp number. 
        %This works ONLY on scalar floating_point numbers. 
        function x=compute_value(obj)
            x=sym(0);
            for i=obj.exponent:-1:obj.exponent-obj.num_digits+1
                x=x+obj.base^(i)*obj.digits(obj.exponent-i+1);
            end
            
            x=x*obj.sign;
            
            
        end
        
        %display a floating_point
        function disp(x)
            if (numel(x)>0)
                fprintf('(base %d)\n',x(1,1).base);
            end
            
            fmt_spec=['%c%d.'];
            if x(1,1).base>10
                fmt_spec=[fmt_spec repmat('%d ',1,x(1,1).num_digits-1)];
            else
                fmt_spec=[fmt_spec repmat('%d',1,x(1,1).num_digits-1)];
            end
            fmt_spec=[fmt_spec ' x %d^%d (APPROX: %g) '];
            for i=1:size(x,1)
                for j=1:size(x,2)
                    z=x(i,j);
                    if z.sign==1
                        s='+';
                    else
                        s='-';
                    end
                    fprintf(fmt_spec,s,z.digits, z.base, z.exponent,double(z.value));
                end
                fprintf('\n');
            end
        end
        
        %add two floating points, or a floating point to a sym or double. 
        function obj=plus(A,B)
            if ~all(size(A)==size(B))
                fprintf(2,'Addition of %d x %d with %d x %d is not defined.\n',size(A,1),size(A,2),size(B,1),size(B,2));
                return;
            end
            for i=1:size(A,1)
                for j=1:size(A,2)
                    [a,b]=coerce_operands(A(i,j),B(i,j),'+');
                    obj(i,j)=floating_point(a.value+b.value,a.base,b.num_digits);
                end
            end
        end
        
        %subtract. 
        function obj=minus(A,B)
            if ~all(size(A)==size(B))
                fprintf(2,'Subtraction of %d x %d with %d x %d is not defined.\n',size(A,1),size(A,2),size(B,1),size(B,2));
                return;
            end
            for i=1:size(A,1)
                for j=1:size(A,2)
                   [a,b]=coerce_operands(A(i,j),B(i,j),'-');
                    obj(i,j)=floating_point(a.value-b.value,a.base,a.num_digits);
                end
            end
        end
        
        %Multiply.  Scalar or matrix multiplication. 
        function obj=mtimes(A,B)
            
            %Make it so that if anyone is a singleton then it is A. 
            if (numel(B)==1)
                tmp=A;
                A=B;
                B=tmp;
            end
            
            %Do scalar multiplication if A is scalar, otherwise do matrix
            %multiplication.
            if numel(A)==1
                for i=1:size(B,1)
                    for j=1:size(B,2)
                        [a,b]=coerce_operands(A,B(i,j),'*');
                        obj(i,j)=floating_point(a.value*b.value,a.base,a.num_digits);
                    end
                end
            else
              if size(A,2) ~= size(B,1)
                  fprintf(2,'Inner dimensions must agree\n.');
                  return;
              end
               for i=1:size(A,1)
                   for j=1:size(B,2)
                       %A(i,k) and B(k,j) are floating_points, but they are
                       %scalars so their multiplication is already defined.
                       %Super slow, but super convenient. 
                       obj(i,j)=A(i,1)*B(1,j);
                       for k=2:size(A,2)
                           obj(i,j)=obj(i,j)+A(i,k)*A(k,j);
                       end
                   end
               end
                
            end
            
        end
        
        %Matrix power
        function obj=mpower(A,p)
            fprintf(2,'Stub\n');
            return;
            obj=floating_point(A.value^p,A.base);
        end
        
        %Unary minus
        function obj=uminus(A)
            obj=A;
            for i=1:size(A,1)
                for j=1:size(A,2)
                    obj(i,j)=A(i,j);
                    obj(i,j).value=-obj(i,j).value;
                    obj(i,j).sign=-obj(i,j).sign;
                end
            end
            
        end
        
        %unary plus
        function obj=uplus(A)
            obj=A;
        end
        
        %convert to double
        function d=double(obj)
            for i=1:size(obj,1)
                for j=1:size(obj,2)
                    d(i,j)=double(obj(i,j).value);
                end
            end
        end
        
        %absolute value
        function a=abs(obj)
            a=obj;
            for i=1:size(obj,1)
                for j=1:size(obj,2)
                    a(i,j).value=abs(a(i,j).value);
                    a(i,j).sign=1;
                end
            end
        end
        
        
        function N=next(obj)
            for i=1:size(obj,1)
                for j=1:size(obj,2)
                    delta=obj(i,j).base^(obj(i,j).exponent-obj(i,j).num_digits+1);
                    N(i,j)=obj(i,j)+delta;
                end
            end
        end
        
        
        
        %Coerce A and B to be the same type of floating point number if
        %possible.  In particular, if one of them is a double it will
        %coerce to a floating_point with the same format as the other
        %argument.  Symbol is the operation that is the reason we are
        %coercing.  For instance, if you are coerceing to add then symbol
        %is +.  
        function [A,B]=coerce_operands(A,B,symbol)
            if ~isa(A,'floating_point')
                A=floating_point(A,B.base,B.num_digits);
            end
            if ~isa(B,'floating_point')
                B=floating_point(B,A.base,A.num_digits);
            end
            if A.base~=B.base
                fprintf(2,['The left hand operatand to ' symbol ' has base %d, while the rand hand operand has base %d. These must match.\n'],A.base,B.base);
                return;
            end
            if A.num_digits ~= B.num_digits
                fprintf(2,'The left hand operatand to * has %d significant digits, while the right hand operand has %d significant digits.  These must match\n',A.num_digits,B.num_digits);
                return;
            end

        end
        
        function OBJ=subsasgn(obj,S,b)
        
          %A matrix should only store things in one storage format. 
          %We take care to check that here.
          %RULES:
          %  - if obj is empty then we go ahead and assign, filling in with
          %zeros if need be. 
          %  - if obj is non-empty and b is zero then we convert b to the
          %  storage format of obj (1,1), since all non-empty matrices are
          %  of same type. 
          %  - if obj is non-empty and b is non-zero then make sure storage
          %  formats of obj(1,1) and b match and throw an error. 
          
          r=S.subs{1};
          c=S.subs{2};
          
          if numel(obj)==1 && r==1 && c==1 && isa(b,'floating_point')
              OBJ(1,1)=b;
              return;
          end
          
          if isempty(obj)
              if ~isa(b,'floating_point')
                  b=floating_point(b);
              end
          else
              if ~isa(b,'floating_point')
                  b=floating_point(b,obj(1,1).base,obj(1,1).num_digits,obj(1,1).min_exp,obj(1,1).max_exp);
              elseif b.value == 0
                  b=floating_point(0,obj(1,1).base,obj(1,1).num_digits,obj(1,1).min_exp,obj(1,1).max_exp);
              else
                  if b.base ~= obj(1,1).base || b.num_digits ~= obj(1,1).num_digits || b.min_exp ~= obj(1,1).min_exp || b.max_exp ~= obj(1,1).max_exp
                      fprintf(2,'You may not store numbers of multiple types in one matrix\n');
                      return;
                  end
              end
          end
          
          %At this point either b matches obj(1,1) in type, or obj is
          %empty.  Either way, b has the right type.  Fill in
          OBJ=obj;
          for i=size(OBJ,1)+1:r
              for j=size(OBJ,2)+1:c
                  OBJ(i,j)=floating_point(2,b.base,b.num_digits,b.min_exp,b.max_exp);
              end
          end
          OBJ(r,c)=b;
          
                      
 

        end
    end
    
end
        
        