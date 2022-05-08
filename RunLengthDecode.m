% Bernard Gonzales
% JPEG Data Compression
% EE652
% Description: 

function ret = RunLengthDecode(runLengths, values)
    if nargin<2
        values = 1:numel(runLengths);
    end
    ret = repelem(values, runLengths);
end