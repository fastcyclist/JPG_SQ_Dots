%% Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileNameOrigin = 'RDJ.jpg';
fileNameTarget = 'RDJ2.jpg';

% Pixel start, end. Must be odd numbers. I haven't tested it with even
% numbers. ¯\_(?)_/¯
startPixels = 7;    % Group [this many pixels x this may pixels] as a unit
endPixels   = 5;    % Keep [this many pixels x this may pixels] and convert the rest into white rims around it.

% Logistic Function Options. This is to increase contrast of the final image.
% https://en.wikipedia.org/wiki/Logistic_function
L_switch = 1;       % 0: Don't use it, 1: Use it.
L        = 255;     % Max value for the output
k        = 0.035;   % Logistic growth rate or steepness of the curve
x0       = (L+1)/2; % Sigmoid's midpoint


%% Work begins %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the image file and info.
I        = imread(fileNameOrigin);
I_info   = imfinfo(fileNameOrigin);
I_Width  = I_info.Width;
I_Height = I_info.Height;

% Trim the right/bottom according to the startPixels.
% This makes the overall product width and height multiples of startPixels.
newWidth  = I_Width  - rem(I_Width,startPixels);
newHeight = I_Height - rem(I_Height,startPixels);
I = I(1:newHeight, 1:newWidth, :);

% Initialize the output RGB array.
outputI = zeros(size(I));

% Start nested for loops, going through the whole image array
% block-by-block (or tile-by-tile).
for j=[1:startPixels:newWidth]
    for i=[1:startPixels:newHeight]
        %  ---------------------- smallTile
        % |    ______________    |
        % |   |              |   |
        % |   |              |   |
        % |   |              |   |
        % |   | smallTileCtr |   |
        % |   |              |   |
        % |   |              |   |
        % |   |______________|   |
        % |                      |
        %  ----------------------
        
        smallTile    = 255*ones(startPixels,startPixels);
        colorPatch   = I(i:i+startPixels-1, j:j+startPixels-1, :);
        avgColor     = round( sum(sum(sum(colorPatch)))/(startPixels^2*3) );
        
        % Logistic Function
        % https://en.wikipedia.org/wiki/Logistic_function
        if L_switch == 1
            avgColor = round( L/( 1+exp(-k*(avgColor-x0)) ) );
        end
        
        % Create the small tile that goes into the center of the larger
        % small tile.
        smallTileCtr = avgColor*ones(endPixels,endPixels);
        % Start point index within the smallTile.
        smallTileStart = (startPixels-endPixels)/2;
        
        smallTile(smallTileStart+1:smallTileStart+endPixels,...
                  smallTileStart+1:smallTileStart+endPixels) = smallTileCtr;
        
        % Do the same for all 3 RGB. This will make it black and white pic.
        outputI(i:i+startPixels-1,j:j+startPixels-1,1) = smallTile;
        outputI(i:i+startPixels-1,j:j+startPixels-1,2) = smallTile;
        outputI(i:i+startPixels-1,j:j+startPixels-1,3) = smallTile;
    end
end

% Convert outputI array from double to uint8.
% imwrite function doesn't work with double arrays.
outputI = uint8(outputI);

% Save the output.
imwrite(outputI,fileNameTarget,'Quality',100)
