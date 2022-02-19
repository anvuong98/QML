function [result] = generatefilename(filename, extension)
% Generates a unique filename for a file
done = false;
version = 1;
while ~done
    result = strcat(filename, num2str(version), extension);
    if ~exist(result)
        done = true;
    else 
        version = version + 1;
    end
end
% result = strcat(filename, num2str(version), extension); %Comment this out
                                                        %if saving multiple
                                                        %files
end

