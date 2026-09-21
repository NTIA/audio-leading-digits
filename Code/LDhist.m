function [valHistNorm, valHistRaw] = LDhist(x,base)
%Usage: [histNorm, histRaw] = LDhist(x,base)
%
%x is a vector of data represented using base 10.
%
%base is an integer (3 <= base) that defines the numerical base system
%(or radix) to use for finding and counting up the leading digits.
%(base = 2 gives a trivial result because there is only one possible value
%for the leading digit.)
%
%histRaw is a row vector that holds the raw histogram (counts) for the
%leading digits in x under the specified base.
%
%histNorm is histRaw scaled to give relative frequency (values add to 1.0)
%Both outputs have size 1 by base-1.  histRaw(1) is the number of 
%elements of x where the leading digit is "1." histRaw(base-1) is the
%number of elements of x where the leading digit is "base-1." 
%
%The signs of the elements in x are ignored.
%Zeros, nans, and infs have no leading digit. If x has only these
%entries, both outputs will be all nans
%
%September 19, 2026 by S. Voran at Institute for Telecommunication Sciences
%in Boulder, Colorado, USA 

if mod(base, 1) ~= 0 || base < 3
    error('base must be an integer that is 3 or greater')
end

x = abs(x);
x = x( x~=0 & ~isnan(x) & ~isinf(x) );

places = floor(log2(x)/log2(base));
d=floor(x./(base.^places)); %leading digit of x
for i=1:base-1
    valHistRaw(i) = sum(d==i);
end
valHistNorm = valHistRaw/length(d);

%This alternate approach works for base = 2 through 36
%and it only works when elements of x are integers
% x = dec2base(x,base);
% for i=1:length(x)
%     temp = x(i,:);
%     p = 1;
%     while strcmp(temp(p),'0')
%         p=p+1;
%     end
%     d1(i) = temp(p);
% end
% 
% symbs = ['1':'9','A':'Z'];
% for i=1:base-1
%     histRaw1(i) = sum(d1==symbs(i));
% end