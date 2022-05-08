% Bernard Gonzales
% JPEG Data Compression
% EE652
% Description: This script shall perform the Zigzag 

function out = Zigzag(in)

[rows, cols] = size(in);

out = zeros(1,rows * cols);

row = 1;
col = 1;
index = 1;

while row <= rows && col <= cols
    % Move right at top
    if row == 1 && mod(row + col, 2) == 0 && col ~= cols 
        out(index) = in(row, col);
        col = col + 1;
        index = index + 1;
    % Move left and down
    elseif col ~= 1 && mod(row + col, 2) ~= 0 && row ~= rows 
        out(index) = in(row, col);
        row = row + 1;
        col = col - 1;
        index = index + 1;
    % Move down at left
    elseif col == 1 && mod(row + col, 2) ~= 0 && row ~= rows 
        out(index) = in(row, col);
        row = row + 1;
        index = index + 1;
    % Move right and up
    elseif row ~= 1 && mod(row + col, 2) == 0  && col ~= cols 
        out(index) = in(row, col);
        row = row - 1;
        col = col + 1;
        index = index + 1;
    % Move right at bottom
    elseif row == rows && mod(row + col, 2) ~= 0 && col ~= cols 
        out(index) = in(row, col);
        col = col + 1;
        index = index + 1;
    % Move down at right
    elseif col == cols && mod(row + col, 2) == 0 && row ~= rows 
        out(index) = in(row, col);
        row = row + 1;
        index = index + 1;
    % Exit condition
    elseif row == rows && col == cols 
        out(end) = in(row, col);
        break;
    end
end
        