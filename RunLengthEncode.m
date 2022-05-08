% Bernard Gonzales
% JPEG Data Compression
% EE652
% Description: 

function ret = RunLengthEncode(numCode)
    J=find(diff([numCode(1)-1, numCode]));
    ret=[numCode(J); diff([J, numel(numCode)+1])];
end