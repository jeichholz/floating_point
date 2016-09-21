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
        value=sym(-Inf);
    end
    
    methods
        function obj=floating_point(base,num_digits,min_exp,max_exp,x)
            
            global fp_disp_repr; 
            if isempty(fp_disp_repr)
                fp_disp_repr=1;
            end
            global fp_disp_val;
            if isempty(fp_disp_val)
                fp_disp_val=1;
            end
            global fp_disp_base;
            if isempty(fp_disp_base)
                fp_disp_base=1;
            end
            
            if ~exist('base','var') || isempty(base)
                base=sym(10);
            else
                base=sym(base);
            end
            if ~exist('num_digits','var') || isempty(num_digits)
                num_digits=5;
            end
            if ~exist('min_exp','var') || isempty(min_exp)
                min_exp=sym(-5);
            else
                min_exp=sym(min_exp);
            end
            if ~exist('max_exp','var') || isempty(max_exp)
                max_exp=sym(5);
            else
                max_exp=sym(max_exp);
            end
            
            
            if ~exist('x','var') || isempty(x)
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
            
            for i=1:size(x,1)
                for j=1:size(x,2)
                    y=x(i,j);
                    obj(i,j).base=base;
                    obj(i,j).num_digits=num_digits;
                    obj(i,j).min_exp=min_exp;
                    obj(i,j).max_exp=max_exp;
                    if y==0
                        obj(i,j).exponent=obj(i,j).min_exp;
                        obj(i,j).value=sym(0);
                    else


                        
                        was_y_neg=0;
                        if y<0
                            y=-y;
                            was_y_neg=1;
                        end
                        
                        obj(i,j).exponent=floor(log(y)/log(obj(i,j).base));
                        sme=obj(i,j).exponent-obj(i,j).num_digits+1;
                        
                        %Round here
                        %if (abs(x(i,j)-floor(x(i,j)/obj(i,j).base^sme)*obj(i,j).base^sme)>abs(x(i,j)-ceil(x(i,j)/obj(i,j).base^sme)*obj(i,j).base^sme))
                        base_to_smallest_pow=obj(i,j).base^sme;
                        if y-floor(y/base_to_smallest_pow)*base_to_smallest_pow>=1/2*base_to_smallest_pow
                            y=y+obj(i,j).base^sme;
                        end
                        %You rounded, re-evaluate the exponent
                        obj(i,j).exponent=floor(log(y)/log(obj(i,j).base));
                        sme=obj(i,j).exponent-obj(i,j).num_digits+1;                        
                        obj(i,j).value=floor(y/obj(i,j).base^sme)*obj(i,j).base^sme;  
                        
                        if was_y_neg
                            obj(i,j).value=-obj(i,j).value;
                        end
                        
                        %Overflow or underflow here
                        if obj(i,j).exponent>obj(i,j).max_exp
                            if obj(i,j).value>0
                                obj(i,j).value=Inf;
                            else
                                obj(i,j).value=-Inf;
                            end
                            obj(i,j).exponent=Inf;
                        end
                        if obj(i,j).exponent<obj(i,j).min_exp
                            obj(i,j).exponent=obj(i,j).min_exp;
                            obj(i,j).value=0;
                        end
                    end
                end
            end
            
        end
%Get the digits of a floating_point number for printing.        
        function dig=digits(obj)
            if obj.value==0
                dig=zeros(1,obj.num_digits);
            elseif  isinf(obj.value)
                dig=Inf*ones(1,obj.num_digits);
            else
                min_exp=obj.exponent-obj.num_digits+1;
                if obj.value<0
                    obj.value=-obj.value;
                end
                dig(1)=floor(obj.value/obj.base^min_exp);
                for i=1:obj.num_digits
                    if (dig(i)>=obj.base)
                        dig(i+1)=floor(dig(i)/obj.base);
                        dig(i)=rem(dig(i),obj.base);
                    end
                end
                
                %I like the digits to read from left to right.
                dig=dig(end:-1:1);
        end
            
        end
        
        
        %display a floating_point
        function disp(x)
            global fp_disp_base;
            if (numel(x)>0) && fp_disp_base
                fprintf('(base %d)\n',x(1,1).base);
            end
            
            global fp_disp_repr;
            if fp_disp_repr
                repr_fmt_spec=['%c%1d.'];
                if x(1,1).base>10
                    repr_fmt_spec=[repr_fmt_spec repmat('%d ',1,x(1,1).num_digits-1)];
                else
                    repr_fmt_spec=[repr_fmt_spec repmat('%d',1,x(1,1).num_digits-1)];
                end
                repr_fmt_spec=[repr_fmt_spec ' x %d^%d'];
            end
            global fp_disp_val;
            if fp_disp_val
                if ~fp_disp_repr
                    val_fmt_spec=['%' num2str(x(1,1).num_digits+5) 'g'];
                else
                    val_fmt_spec=' (APPROX: %5f)';
                end
            end
            for i=1:size(x,1)
                for j=1:size(x,2)
                    z=x(i,j);
                    if z.value>=0
                        s='+';
                    else
                        s='-';
                    end
                    if fp_disp_repr
                        fprintf(repr_fmt_spec,s,z.digits(), z.base, z.exponent);
                    end
                    if fp_disp_val
                        fprintf(val_fmt_spec,double(z.value));
                    end
                    fprintf(' ');
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
                    obj(i,j)=floating_point(a.base,a.num_digits,a.min_exp,a.max_exp,a.value+b.value);
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
                    obj(i,j)=floating_point(a.base,a.num_digits,a.min_exp,a.max_exp,a.value-b.value);
                end
            end
        end
        
        
        %Multiply.  Elementwise multiplication
        function obj=times(A,B)
            if ~all(size(A)==size(B))
                fprintf(2,'Operand dimensions must agree.\n');
                return;
            end
            for i=1:size(A,1)
                for j=1:size(B,2)
                    [a,b]=coerce_operands(A(i,j),B(i,j),'*');
                    obj(i,j)=floating_point(a.base,a.num_digits,a.min_exp,a.max_exp,a.value*b.value);
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
                        obj(i,j)=floating_point(a.base,a.num_digits,a.min_exp,a.max_exp,a.value*b.value);
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
                           obj(i,j)=obj(i,j)+A(i,k)*B(k,j);
                       end
                   end
               end
                
            end
            
        end
        
        %Perform B.\A.  
        function obj=ldivide(B,A)
            if numel(B)==1
                obj=B\A;
                return;
            else
                if ~all(size(A)==size(B))
                    fprintf(2,'Elementwise division requires operands of same size.\n');
                    return;
                end
            end
            for i=1:size(A,1)
                for j=1:size(A,2)
                    [a,b]=coerce_operands(A(i,j),B(i,j),'\');
                    obj(i,j)=floating_point(a.base,a.num_digits,a.min_exp,a.max_exp,a.value/b.value);
                end
            end
        end
        
        %Perform B\A.  Only supports B a scalar
        function obj=mldivide(B,A)
            if numel(B)>1
                fprintf('Only division by scalars is supported for floating_points\n');
            end
            if ~isa(B,'floating_point')
                B=floating_point(A(1,1).base,A(1,1).num_digits,A(1,1).min_exp,A(1,1).max_exp,B);
            end
            for i=1:size(A,1)
                for j=1:size(A,2)
                    [a,b]=coerce_operands(A(i,j),B,'\');
                    obj(i,j)=floating_point(a.base,a.num_digits,a.min_exp,a.max_exp,a.value/b.value);
                end
            end
        end

        
        
        %Perform A./B.  
        function obj=rdivide(A,B)
            if numel(B)==1
                obj=A/B;
                return;
            else
                if ~all(size(A)==size(B))
                    fprintf(2,'Elementwise division requires operands of consistent size.\n');
                    return;
                end
                for i=1:size(A,1)
                    for j=1:size(A,2)
                        [a,b]=coerce_operands(A(i,j),B(i,j),'\');
                       obj(i,j)=floating_point(a.base,a.num_digits,a.min_exp,a.max_exp,a.value/b.value);
                    end
                end
            end
        end

        %Perform A/B.  Only supports B a scalar
        function obj=mrdivide(A,B)
            if numel(B)>1
                fprintf('Only division by scalars is supported for floating_points\n');
            end
            if ~isa(B,'floating_point')
                B=floating_point(A(1,1).base,A(1,1).num_digits,A(1,1).min_exp,A(1,1).max_exp,B);
            end
            for i=1:size(A,1)
                for j=1:size(A,2)
                    [a,b]=coerce_operands(A(i,j),B,'\');
                    obj(i,j)=floating_point(a.base,a.num_digits,a.min_exp,a.max_exp,a.value/b.value);
                end
            end
        end

        
        %Matrix power
        function obj=mpower(A,p)
            if size(A,1) ~= size(A,2)
                fprintf(2,'Matrix power is only defined for square matrices\n');
                return;
            end
            if size(A,1)==1
                obj=floating_point(A.base,A.num_digits,A.min_exp,A.max_exp,A.value^p);
            else
                if mod(p,1)~=0 || p < 0
                    fprintf(2,'Matrix power for floating_point matrices is only defined for positive integer powers.\n');
                    return;
                end
                if p==0
                    obj=A;
                    for i= 1:size(A,1)
                        for j=1:size(A,2)
                            if i==j
                                val=1;
                            else
                                val=0;
                            end
                            obj(i,j)=floating_point(A(1,1).base,A(1,1).num_digits,A(1,1).min_exp,A(1,1).max_exp,val);
                        end
                    end
                
                elseif p==1
                    obj=A;
                else
                    obj=A;
                    for i=2:p
                        obj=obj*A;
                    end
                end
            end
        end
        
        %Unary minus
        function obj=uminus(A)
            obj=A;
            for i=1:size(A,1)
                for j=1:size(A,2)
                    obj(i,j)=A(i,j);
                    obj(i,j).value=-obj(i,j).value;
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
        
        %convert to sym.  Sumer useful at times
        function s=sym(obj)
            s=sym(reshape([obj.value],size(obj)));
        end
        
        %absolute value
        function a=abs(obj)
            a=apply_func(@abs,obj);
        end

        %sin
        function a=sin(obj)
            a=apply_func(@sin, obj);
        end

        %cos
        function a=cos(obj)
            a=apply_func(@cos, obj);
        end

        %tan
        function a=tan(obj)
            a=apply_func(@tan, obj);
        end
        

        %csc
        function a=csc(obj)
            a=apply_func(@csc, obj);
        end

        %sec
        function a=sec(obj)
            a=apply_func(@sec, obj);
        end
        
        %acos
        function a=acos(obj)
            a=apply_func(@acos, obj);
        end
        
        %asin
        function a=asin(obj)
            a=apply_func(@asin, obj);
        end
        
        %atan
        function a=atan(obj)
            a=apply_func(@atan, obj);
        end
        
        
        function TF=eq(obj,x)
           [A,B]=coerce_operands(obj,x,'==');
           TF=isequal(A.value,B.value);
        end
        
         function TF=lt(obj,x)
           [A,B]=coerce_operands(obj,x,'<');
           TF=double(sign(A.value-B.value))==-1;
         end   
         
         function TF=le(obj,x)
           [A,B]=coerce_operands(obj,x,'<e');
           TF=double(sign(A.value-B.value))<1;
         end   
         
         
        
         function TF=gt(obj,x)
           [A,B]=coerce_operands(obj,x,'>');
           TF=double(sign(A.value-B.value))==1;
         end       
        
         function TF=ge(obj,x)
           [A,B]=coerce_operands(obj,x,'>=');
           TF=double(sign(A.value-B.value))>-1;
         end       
        
        function A=apply_func(f,obj)
            b=obj(1,1).base;
            n=obj(1,1).num_digits;
            m=obj(1,1).min_exp;
            M=obj(1,1).max_exp;
            for i=1:size(obj,1)
                for j=1:size(obj,2);
                    A(i,j)=floating_point(b,n,m,M,f(obj(i,j).value));
                end
            end
        end
        
       
        
        
        function N=next(obj)
            for i=1:size(obj,1)
                for j=1:size(obj,2)
                    if obj(i,j).value==0
                        delta=obj(i,j).base^obj(i,j).min_exp;
                    else
                        delta=obj(i,j).base^(obj(i,j).exponent-obj(i,j).num_digits+1);
                    end
                    N(i,j)=floating_point(obj(i,j).base,obj(i,j).num_digits,obj(i,j).min_exp,obj(i,j).max_exp,obj(i,j).value+delta);
                end
            end
        end
        
        function N=prev(obj)
            for i=1:size(obj,1)
                for j=1:size(obj,2)
                    if obj(i,j).value==0
                        delta=obj(i,j).base^obj(i,j).min_exp;
                    else
                        delta=obj(i,j).base^(obj(i,j).exponent-obj(i,j).num_digits+1);
                    end
                    N(i,j)=floating_point(obj(i,j).base,obj(i,j).num_digits,obj(i,j).min_exp,obj(i,j).max_exp,obj(i,j).value-delta);
                end
            end
        end
        
        function D=delta(obj)
            D=sym(zeros(size(obj)));
            N=obj.next();
            for i=1:size(obj,1)
                for j=1:size(obj,2)
                    D(i,j)=N(i,j).value()-obj(i,j).value();
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
                A=floating_point(B.base,B.num_digits,B.min_exp,B.max_exp,A);
            end
            if ~isa(B,'floating_point')
                B=floating_point(A.base,A.num_digits,A.min_exp,A.max_exp,B);
            end
            if A.base~=B.base
                fprintf(2,['The left hand operatand to ' symbol ' has base %d, while the rand hand operand has base %d. These must match.\n'],A.base,B.base);
                return;
            end
            if A.num_digits ~= B.num_digits
                fprintf(2,['The left hand operatand to ' symbol ' has %d significant digits, while the right hand operand has %d significant digits.  These must match\n'],A.num_digits,B.num_digits);
                return;
            end
            
            if A.min_exp ~= B.min_exp
                fprintf(2,['The left hand operatand to ' symbol ' has minimum exponent %d, while the right hand operand has minimum exponent %d.  These must match\n'],A.min_exp,B.min_exp);
                return;
            end
            
            if A.num_digits ~= B.num_digits
                fprintf(2,['The left hand operatand to ' symbol ' has maximum exponent %d, while the right hand operand has maximum exponent %d  These must match\n'],A.max_exp,B.max_exp);
                return;
            end


        end
        
        function OBJ=subsasgn(obj,S,b)
            
            %A matrix should only store things in one storage format.

            %Here are the rules we want when doing A(stuff)=b
            %
            %* I don't think it is possible for A to be empty.  If it is
            %then all hell has broken loose and you should quit. 
            %
            %* if A is 1x1 and b is 1x1 floating point, then it is ok 
            %  to just assign b to A.  In this way we can change the
            %  storage format of A.  
            %
            %* if b is sym or floating point or string then the correct
            %coercion should take place to match what is already in A. 
            %
            %* In order to make it easy to instantiate matrices, 
            %  A(:,:)=b should check to make sure that b has the correct
            %  storage format for A, but it will resize A to match the size
            %  of b.  So if A is 1x1 we could do A(:,:)=eye(4).  
            
            %Make sure A is not empty
            if isempty(obj)
                fprintf(2,'I had no idea it was possible for a floating_point to be empty. I quit\n');
                return;
            end
            
            %if this is not an indexing thing then just do the normal
            %stuff. 
            if ~strcmp(S.type,'()')
                OBJ=obj;
                OBJ.(S.subs)=b;
            else
               %If A is 1x1 and b is a floating point, don't try to coerce b, just 
               %do it.
               if numel(obj)==1 && isa(b,'floating_point') && numel(b)==1 ...
                                && S.subs{1}==1 && S.subs{2}==1
                   OBJ=b;
                   return;
               end
                
                %If b is already a floating_point, check to make sure it is
                %in the correct storage format.  If it isn't, throw a hissy
                %fit. 
                if isa(b,'floating_point') && (any([b.base]~=obj(1,1).base) || ...
                                               any([b.num_digits]~=obj(1,1).num_digits) ||...
                                               any([b.min_exp]~=obj(1,1).min_exp)||...
                                               any([b.max_exp]~=obj(1,1).max_exp))
                                           fprintf(2,'An array of floating_point must all have the same storage format.\n');
                                           return;
                end
                
                %Ok, now go ahead and make a matrix of sym's out of b.
                bsym=sym(b);
                
                
                %make a matrix of syms out of A. If it happens that we were
                %using (:,:) notation then just make this the correct size
                %to fit b.
                if (ischar(S.subs{1}) && strcmp(S.subs{1},':') &&...
                    ischar(S.subs{2}) && strcmp(S.subs{2},':'))
                    Asym=sym(zeros(size(b)));
                else
                    Asym=sym(obj);
                end
                
                %do the assignment.  
                Asym=subsasgn(Asym,S,bsym);
                
                %And now take Asym and put it in the original storage
                %format. 
                OBJ=floating_point(obj(1,1).base,obj(1,1).num_digits,...
                                   obj(1,1).min_exp,obj(1,1).max_exp,Asym);
                               
                
            end
            
           
            
        end
    end
    
end
        
        