%floating_point_scalar is a class that accurately reflects storage and
%common operations on floating point numbers for observation by students.
%Numbers can be stored in any integer base, with any number of digits
%(properly significant figures).  Min and Max exponents are supported.
%You may choose to store an existing numeric value or a symbolic value as a
%floating point.  +,-,*,/ are supported. 
%Overflow and underflow are not yet implemented, and denormalized numbers
%are not supported. 
%
%Usefully, a floating point number has a next() method that returns the
%next representable floating point number in the storage format. 


classdef floating_point_scalar
    properties
        base=10;
        num_digits=-1;
        exponent=0;
        min_exp=-5;
        max_exp=5;
        digits=-1;
        value=sym(-Inf);
        sign=0;
        %printbase=10;
    end
    
    methods
        function obj=floating_point_scalar(x,base,num_digits,min_exp,max_exp)

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
            else
                if x>0
                    obj.sign=1;
                else
                    obj.sign=-1;
                    x=-x;
                end
                obj.exponent=floor(log(x)/log(base));
                min_exp=obj.exponent-obj.num_digits+1;
                
                %Round here
                if (abs(x-floor(x/obj.base^min_exp)*obj.base^min_exp)>abs(x-ceil(x/obj.base^min_exp)*obj.base^min_exp))
                    x=x+obj.base^min_exp;
                end
                %You rounded, re-evaluate the exponent 
                obj.exponent=floor(log(x)/log(base));
                min_exp=obj.exponent-obj.num_digits+1;
                
                obj.digits(1)=floor(x/obj.base^min_exp);
                
                for i=1:obj.num_digits
                    if (obj.digits(i)>=obj.base)
                        obj.digits(i+1)=floor(obj.digits(i)/obj.base);
                        obj.digits(i)=rem(obj.digits(i),obj.base);
                    end
                end
                
                
                
                
            end
            %I like the digits to read from left to right. 
            obj.digits=obj.digits(end:-1:1);
            
            obj.value=compute_value(obj);
         
                
        end
        
        %Get the exact (symbolic) value represented by the fp number. 
        function x=compute_value(obj)
            x=sym(0);
            for i=obj.exponent:-1:obj.exponent-obj.num_digits+1
                x=x+obj.base^(i)*obj.digits(obj.exponent-i+1);
            end
            
            x=x*obj.sign;
            
            
        end
        
        function disp(z)
            if z.sign==1
                s='+';
            else
                s='-';
            end
            fmt_spec=['(base %d) ' s '%d. ' repmat('%d ',1,z.num_digits-1)  ' x %d ^ %d (APPROX: %g)\n'];
            fprintf(fmt_spec,z.base,z.digits, z.base, z.exponent,double(z.value));
        end
        
        function obj=plus(A,B)
            [A,B]=coerce_operands(A,B,'+');
            obj=floating_point(A.value+B.value,A.base,A.num_digits);
        end
        
        function obj=minus(A,B)
            [A,B]=coerce_operands(A,B,'-');
            obj=floating_point(A.value-B.value,A.base,A.num_digits);
        end
        
        function obj=mtimes(A,B)
            [A,B]=coerce_operands(A,B,'*');
            obj=floating_point(A.value*B.value,A.base,A.num_digits);
        end
        
        function obj=mpower(A,p)
            obj=floating_point(A.value^p,A.base);
        end
        
        function obj=uminus(A)
            obj=floating_point(-A.value,A.base,A.num_digits);
        end
        
        function obj=uplus(A)
            obj=floating_point(+A.value,A.base,A.num_digits);
        end
        
        function N=next(obj)
            delta=obj.base^(obj.exponent-obj.num_digits+1);
            N=obj+delta;
        end
        
        function d=double(obj)
            d=abs(obj.value);
        end
        
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
    end
    
end
        
        