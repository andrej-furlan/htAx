function [matches, matchData] = findXRDMatchesPoint(indexPoint, XRDData, XRDDatabase)
%FINDXRDMATCHES identifies peaks in the given XRD pattern using the wavelet
%transform, compares those peaks with peaks in patterns from the XRD
%database folder, and returns any matching peaks

    %XRDTemp = [XRDData(:, indexPoint * 2 - 1) XRDData(:, indexPoint * 2)];
    
    %totalAngles = length(XRDTemp(:, 1));
    %indexAngles = 1;
    %anglesToCheck = zeros(1, 1);
    %numEntered = 0;
    %intensityToCheck = zeros(1, 1);
    %divide = 19;
    
    % find the peaks in the XRD data for this point
    % replace with better algorithm??
    %{
    while (indexAngles + divide) <= totalAngles
        
        % find index of maximum intensity in the given range
        [~, indexMax] = max(XRDTemp((indexAngles:indexAngles + divide), 2));
        
        % save data for this maximum
        numEntered = numEntered + 1;
        anglesToCheck(numEntered) = XRDTemp(indexMax + indexAngles - 1, 1);
        intensityToCheck(numEntered) = XRDTemp(indexMax + indexAngles - 1, 2);
        indexAngles = indexAngles + divide + 1;
    end
    %}
    
    angles = XRDData(:, indexPoint * 2 - 1);
    intensity = XRDData(:, indexPoint * 2);
    
    % denoise

    dnIntensity = wden(intensity, 'sqtwolog', 's', 'mln', 3, 'sym6');

    % wavelet transform

    scales = 10:0.1:20;
    coefs = cwt(dnIntensity, scales, 'mexh');

    % take one plot out of transform and find its peaks

    coefsSet = coefs(50, :);
    [peaks, peakIndex] = findpeaks(coefsSet, angles);

    % choose 10 highest peaks

    peaks = transpose(peaks);
    peakInfo = [peaks peakIndex];
    peakInfo = flipud(sortrows(peakInfo));
    anglesToCheck = peakInfo(1:10, 2);
    intensityToCheck = peakInfo(1:10, 1);

    % plot peak choices on original plot

    %{
    figure
    plot(angles, intensity);
    hold on;
    for i = 1:10
        plot([peakInfo(i, 2) peakInfo(i, 2)], [0 180], 'r');
    end
    %}

    
    numFiles = length(XRDDatabase(1, :)) / 2;
    matches = zeros(1, numFiles);
    matchData = zeros(1, 1);
    numSaved = 0;
    tolerance = 0.1;
    intensityTol = 10;
    numAngles = length(anglesToCheck);
    for indexAngle = 1:numAngles
        for indexDatabase = 1:numFiles
            ids1 = abs(XRDDatabase(:, indexDatabase * 2 - 1) - ...
                anglesToCheck(indexAngle)) < tolerance;
            ids2 = XRDDatabase(:, indexDatabase * 2) > intensityTol;
            ids3 = find(ids1 .* ids2);
            if isempty(ids3) ~= 1
                matches(1, indexDatabase) = 1;
                for indexLines = 1:length(ids3)
                    numSaved = numSaved + 1;
                    matchData(numSaved, 1) = indexDatabase;
                    matchData(numSaved, 2) = anglesToCheck(indexAngle);
                    matchData(numSaved, 3) = intensityToCheck(indexAngle);
                    matchData(numSaved, 4) = XRDDatabase(ids3(indexLines), indexDatabase * 2 - 1);
                    matchData(numSaved, 5) = XRDDatabase(ids3(indexLines), indexDatabase * 2);
                end
            end
        end
    end
    
end
