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
        sign=0;
    end
    
    methods
        function obj=floating_point(base,num_digits,min_exp,max_exp,x)
            
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
                    obj(i,j).base=base;
                    obj(i,j).num_digits=num_digits;
                    obj(i,j).min_exp=min_exp;
                    obj(i,j).max_exp=max_exp;
                    if x(i,j)==0
                        obj(i,j).sign=1;
                        obj(i,j).exponent=obj(i,j).min_exp;
                        obj(i,j).value=sym(0);
                    else
                        if x(i,j)>0
                            obj(i,j).sign=1;
                        else
                            obj(i,j).sign=-1;
                            x(i,j)=-x(i,j);
                        end
                        obj(i,j).exponent=floor(log(x(i,j))/log(obj(i,j).base));
                        sme=obj(i,j).exponent-obj(i,j).num_digits+1;
                        
                        %Round here
                        %if (abs(x(i,j)-floor(x(i,j)/obj(i,j).base^sme)*obj(i,j).base^sme)>abs(x(i,j)-ceil(x(i,j)/obj(i,j).base^sme)*obj(i,j).base^sme))
                        if x(i,j)-floor(x(i,j)/obj(i,j).base^sme)*obj(i,j).base^sme>=1/2*obj(i,j).base^sme
                            x(i,j)=x(i,j)+obj(i,j).base^sme;
                        end
                        %You rounded, re-evaluate the exponent
                        obj(i,j).exponent=floor(log(x(i,j))/log(obj(i,j).base));
                        sme=obj(i,j).exponent-obj(i,j).num_digits+1;                        
                        obj(i,j).value=floor(x(i,j)/obj(i,j).base^sme)*obj(i,j).base^sme;  
                        
                        %Overflow or underflow here
                        if obj(i,j).exponent>obj(i,j).max_exp
                            if obj(i,j).sign==1
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
        
        %Perform B.\A.  Only supports B a scalar
        function obj=ldivide(B,A)
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

        
        
        %Perform A./B.  Only supports B a scalar
        function obj=rdivide(A,B)
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
                    N(i,j)=floating_point(obj(i,j).base,obj(i,j).num_digits,obj(i,j).min_exp,obj(i,j).max_exp,obj(i,j).value+delta);
                end
            end
        end
        
        function N=prev(obj)
            for i=1:size(obj,1)
                for j=1:size(obj,2)
                    delta=obj(i,j).base^(obj(i,j).exponent-obj(i,j).num_digits+1);
                    N(i,j)=floating_point(obj(i,j).base,obj(i,j).num_digits,obj(i,j).min_exp,obj(i,j).max_exp,obj(i,j).value-delta);
                end
            end
        end
        
        function D=delta(obj)
            D=obj.next().value()-obj.value();
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
            %We take care to check that here.
            %RULES:
            %  - if obj is empty then we go ahead and assign, filling in with
            %zeros if need be.
            %  - if obj is non-empty and b is zero then we convert b to the
            %  storage format of obj (1,1), since all non-empty matrices are
            %  of same type.
            %  - if obj is non-empty and b is non-zero then make sure storage
            %  formats of obj(1,1) and b match and throw an error.
            
            
            %It is OK to change the type of the matrix if there is exactly one
            %element in it to start with.
            
            
            do_size_check=1;
            
            if numel(obj)==1 && S.subs{1}==1 && isa(b,'floating_point')
                OBJ(1,1)=b;
                return;

            
            %Otherwise, first figure out what indices we are assigning into.
            %THIS DIFFERS FROM TRADITIONAL MATLAB INDEXING. 
            %INDEXING with A(:,:)=B will completely reshape A to be the size of B.
            %Typically, if A is not already the correct shape then this
            %will fail.
            elseif length(S.subs)==2 && ischar(S.subs{1}) && strcmp(S.subs{1},':')... 
                                     && ischar(S.subs{2}) && strcmp(S.subs{2},':')
               OBJ=floating_point(obj(1,1).base,obj(1,1).num_digits,obj(1,1).min_exp,obj(1,1).max_exp);
               R=1:size(b,1);
               C=1:size(b,2);
               do_size_check=0;
               
            %In this case just normal 2D indexing.
            elseif length(S.subs)==2
                OBJ=obj;
                if ischar(S.subs{1}) && strcmp(S.subs{1},':')
                    R=1:size(OBJ,1);
                else
                    R=S.subs{1};
                end
                if ischar(S.subs{2}) && strcmp(S.subs{2},':')
                    C=1:size(OBJ,2);
                else
                    C=S.subs{2};
                end
            elseif length(S.subs)==1
                OBJ=obj;
                if ischar(S.subs{1}) && strcmp(S.subs{1},':')
                    [R,C]=ind2sub(size(OBJ),1:numel(OBJ));
                else
                    [R,C]=ind2sub(size(OBJ),S.subs{1});
                end
            else
                fprintf(2,'Only one- and two-dimensional subscripting is supported.');
            end
            
            if numel(b)==1
                b=repmat(b,length(R),length(C));
            end
            
            if length(R)*length(C) ~= numel(b)
                fprintf(2,'Trying to assign %d elements into %d spots.\n',numel(b),length(R)*length(C));
                return;
            end
            
            
            ASSIGNEE=0;
            for ridx=1:length(R)
                for cidx=1:length(C)
                    r=R(ridx);
                    c=C(cidx);
                    if isempty(obj)
                        fprintf(2,'I did not expect it was possible to have an empty floating point.\n');
                        return;
                    else
                        if ~isa(b(ridx,cidx),'floating_point')
                            ASSIGNEE=floating_point(obj(1,1).base,obj(1,1).num_digits,obj(1,1).min_exp,obj(1,1).max_exp,b(ridx,cidx));
                        elseif b(ridx,cidx).value == 0
                            ASSIGNEE=floating_point(obj(1,1).base,obj(1,1).num_digits,obj(1,1).min_exp,obj(1,1).max_exp,0);
                        else
                            if b(ridx,cidx).base ~= obj(1,1).base || b(ridx,cidx).num_digits ~= obj(1,1).num_digits || b(ridx,cidx).min_exp ~= obj(1,1).min_exp || b(ridx,cidx).max_exp ~= obj(1,1).max_exp
                                fprintf(2,'You may not store numbers of multiple types in one matrix\n');
                                return;
                            else
                                ASSIGNEE=b(ridx,cidx);
                            end
                        end
                    end
                    
                    %At this point either ASSIGNEE matches obj(1,1) in type, or obj is
                    %empty.  Either way, b has the right type.  Fill in
                    oldOBJsize=size(OBJ);
                    for i=oldOBJsize(1)+1:r
                        for j=1:c
                            OBJ(i,j)=floating_point(ASSIGNEE.base,ASSIGNEE.num_digits,...
                                     ASSIGNEE.min_exp,ASSIGNEE.max_exp,0);
                        end
                    end
                    for j=oldOBJsize(2)+1:c
                        for i=1:r
                            OBJ(i,j)=floating_point(ASSIGNEE.base,ASSIGNEE.num_digits,...
                                ASSIGNEE.min_exp,ASSIGNEE.max_exp,0);
                        end
                    end
                    
                    OBJ(r,c)=ASSIGNEE;
                    
                end
            end
            
            
            
        end
    end
    
end
        
        