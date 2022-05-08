% Bernard Gonzales
% JPEG Data Compression
% EE652
% Description: 

function [arithDecodedCell] = ArithmeticDecode(source, counts, seq, arithEncodedCell)
    decodedY = {};
    dseq = {};
    for i = 1 : size(arithEncodedCell,2)
        temp = cell2mat(arithEncodedCell(i));
        dseq{i} = {arithdeco(temp, cell2mat(counts(i)), length(seq{i}))};
        decodedY{i} = dseq{i};
    end
    
    arithDecodedCell = {};
    for row = 1 : size(decodedY,2)
        temp = cell2mat(decodedY{row});
        sizeRow = size(temp,2);
        for i = 1 : sizeRow
            index = temp(1,i);
            temp (i) = source{row}(1,index);
        end
         arithDecodedCell(row) = {temp};
    end
end



