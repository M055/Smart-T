    function rect = FindMaxSquareInRect(rect)
        %http://docs.psychtoolbox.org/PsychRects
        width = rect(3)-rect(1);
        height = rect(4)-rect(2);
        if width == height
            return;
        elseif width > height
            cutoff = (width-height)/2.0;
            rect(1) = rect(1) + cutoff;
            rect(3) = rect(3) - cutoff;
        elseif height > width
            cutoff = (height-width)/2.0;
            rect(2) = rect(2) + cutoff;
            rect(4) = rect(4) - cutoff;
        end
    end