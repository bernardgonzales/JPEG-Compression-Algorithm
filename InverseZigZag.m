% Bernard Gonzales
% JPEG Data Compression
% EE652
% Description: This script shall perform the Inverse Zigzag 

function out = InverseZigZag(in, rows, cols)

elems = length(in);

% Check if matrix dimensions correspond
if elems ~= rows * cols
	error('Matrix dimensions do not match');
end

% Initialise the output matrix
out = zeros(rows, cols);

row=1;
col=1;
index=1;

% First element

while index <= elems
	if row == 1 && mod(row + col, 2) == 0 && col ~= cols %move right at the top
		out(row, col) = in(index);
		col = col + 1;							
		index = index + 1;        
    elseif col ~= 1 && mod(row + col, 2)~= 0 && row ~= rows %move diagonally left down
		out(row, col) =in (index);
		row = row + 1;
        col = col - 1;	
		index = index + 1;        
    elseif col == 1 && mod(row + col, 2) ~= 0 && row ~= rows %move down at the left
		out(row, col) = in(index);
		row = row + 1;							
		index = index + 1;        
    elseif row ~= 1 && mod(row+col,2) == 0 && col ~= cols %move diagonally right up
		out(row, col) = in(index);
		row = row - 1;
        col = col + 1;	
		index = index + 1;        
    elseif col == cols && mod(row + col, 2) == 0 && row ~= rows %move down at the right
		out(row, col) = in(index);
		row = row + 1;							
		index = index + 1;		
	elseif row == rows && mod(row + col, 2) ~= 0 && col ~= cols %move right at the bottom
		out(row, col) = in(index);
		col = col + 1;							
		index = index + 1;		
	elseif index == elems						%input the bottom right element
        out(end) = in(end);							%end of the operation
		break;										%terminate the operation
    end
end