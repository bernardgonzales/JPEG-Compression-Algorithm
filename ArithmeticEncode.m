% Bernard Gonzales
% JPEG Data Compression
% EE652
% Description: 

function [source, seq, counts, arithEncodedCell] = ArithmeticEncode(input, compName)
    seq = {};
    counts = {};
    arithEncodedCell = {};
    tempCell = {};
    source = {};
    counterFun1 = 1;
    numRows = size(input,1);

    f = waitbar(0, 'Starting');

    for cell = 1 : size(input,1)
        waitbar(cell/size(input,1), f, sprintf('Arithmetic Encoding %s component. Progress: %d %% ', compName, floor(cell/size(input,1)*100) ));

        for row = 1: size(input{cell},1)
            rlEncodedRow = input{cell}(row,:);
        
            % source holds the unique values
            % counts is how many times each value occured in the message
            source(counterFun1,:) = {unique(rlEncodedRow)};
            
            for i=1:length(source{counterFun1})  
                temp(i) = length(strfind(rlEncodedRow,source{counterFun1}(1,i)));
            end
    
            counts = [counts, mat2cell(temp, size(temp,1), size(temp,2))];
            temp = [];
        
            for i=1:length(rlEncodedRow)
                temp(i) = strfind(source{counterFun1} ,rlEncodedRow(i));
            end
    
            seq = [seq, mat2cell(temp, size(temp,1), size(temp,2))];
            temp = [];
    
            % Get arithmetic code for the block
            countTemp = cell2mat(counts(counterFun1));
            code = arithenco(cell2mat(seq(1,counterFun1)), countTemp);
    
            % Store the block's code
            tempCell = mat2cell(code, size(code,1), size(code,2));
            arithEncodedCell = [arithEncodedCell,tempCell];
            tempCell = {};
            counterFun1 = counterFun1 + 1;
        end
    end
    close(f);
end