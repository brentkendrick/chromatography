% ------------------------------------------------------------------------
% Method      : Centroid
% Description : Centroid mass spectrometer data
% ------------------------------------------------------------------------
%
% ------------------------------------------------------------------------
% Syntax
% ------------------------------------------------------------------------
%   [mz, y] = Centroid(mz, y)
%
% ------------------------------------------------------------------------
% Input (Required)
% ------------------------------------------------------------------------
%   mz -- mass values
%       array (size = 1 x n)
%
%   y -- intensity values
%       array | matrix (size = m x n)
%
% ------------------------------------------------------------------------
% Input (Name, Value)
% ------------------------------------------------------------------------
%   'iterations' -- number of iterations to perform centroiding
%       50 (default) | number
%
%   'blocksize' -- maximum number of bytes to process at a single time
%       5E6 (default) | number
%
% ------------------------------------------------------------------------
% Examples
% ------------------------------------------------------------------------
%   [mz, y] = Centroid(mz, y)

function varargout = Centroid(varargin)

varargout{2} = [];

% ---------------------------------------
% Default
% ---------------------------------------
default.iterations = 10;
default.blocksize  = 5E6;

% ---------------------------------------
% Input
% ---------------------------------------
p = inputParser;

addRequired(p, 'mz',...
    @(x) validateattributes(x, {'numeric'}, {'nonnan', 'nonempty'}));

addRequired(p, 'y',...
    @(x) validateattributes(x, {'numeric'}, {'nonnan', 'nonempty'}));

addParameter(p, 'iterations',...
    default.iterations,...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));

addParameter(p, 'blocksize',...
    default.blocksize,...
    @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));

parse(p, varargin{:});

% ---------------------------------------
% Parse
% ---------------------------------------
mz = p.Results.mz;
y  = p.Results.y;

iterations = p.Results.iterations;
blocksize  = p.Results.blocksize;

% ---------------------------------------
% Validate
% ---------------------------------------
if length(mz(1,:)) ~= length(y(1,:))
    return
end

% ---------------------------------------
% Variables
% ---------------------------------------
[m, n] = size(y);

index = 1:floor(blocksize/(m*8)):n;
    
if index(end) ~= n
    index(end+1) = n + 1;
end
    
% ---------------------------------------
% Centroid
% ---------------------------------------
for i = 1:length(index)-1

    block.mz = mz(index(i):index(i+1)-1);
    block.y  = y(:, index(i):index(i+1)-1);
    
    if issparse(y)
        [block.mz, block.y] = centroid(block.mz, full(block.y), iterations);
        varargout{1} = [varargout{1}, block.mz];
        varargout{2} = [varargout{2}, sparse(block.y)];
    else
        [block.mz, block.y] = centroid(block.mz, block.y, iterations);
        varargout{1} = [varargout{1}, block.mz];
        varargout{2} = [varargout{2}, block.y];
    end

end

end

function [mz, y] = centroid(mz, y, rounds)

% ---------------------------------------
% Variables
% ---------------------------------------
counter    = 1;
iterations = 0;

% ---------------------------------------
% Centroid
% ---------------------------------------
while counter ~= 0 && iterations <= rounds
    
    for i = 2:length(y(1,:))-1
        
        if all(~y(:,i))
            continue
        end
        
        % Find zeros in column
        middle = ~y(:,i);
        
        % Find zeros in adjacent columns
        upper = ~y(:,i+1);
        lower = ~y(:,i-1);
        
        % Consolidate if next column has more zeros
        if nnz(middle) < nnz(upper)
            
            % Find zeros adjacent to nonzeros
            index = xor(middle, upper);
            
            % Shift nonzeros in adjacent column to middle column
            y(index,i) = y(index,i) + y(index,i+1);
            y(index,i+1) = 0;
        end
        
        % Consolidate if previous column has more zero elements
        if nnz(middle) < nnz(lower)
            
            % Find zeros adjacent to nonzeros
            index = xor(middle, lower);
            
            % Shift nonzeros in adjacent column to middle column
            y(index, i) = y(index, i) + y(index, i-1);
            y(index, i-1) = 0;
            
        end
    end
    
    counter = length(y(1,:));
    
    % Remove columns with all zeros
    remove = all(~y);
    
    mz(:, remove) = [];
    y(:, remove)  = [];
    
    counter = counter - length(y(1,:));
    iterations = iterations + 1;
    
end

end