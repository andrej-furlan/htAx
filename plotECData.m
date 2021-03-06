function plotECData(ternHandles, specHandles, ECHandles)
%PLOTECDATA plots the EC data for the user-selected region

    figTern = ternHandles.fTernDiagram;
    ternInfo = figTern.UserData;
    
    fSpecPlot = specHandles.fSpecPlot;
    specInfo = fSpecPlot.UserData;
    
    fECPlot = ECHandles.fECPlot;
    ECInfo = fECPlot.UserData;
    
    constType = ternInfo.constType;
    compA = ternInfo.valsCompA;
    compB = ternInfo.valsCompB;
    compC = ternInfo.valsCompC;
    hEditConst = ternHandles.editConst;
    hEditWidth = ternHandles.editWidth;
    constPercent = hEditConst.UserData;
    width = hEditWidth.UserData;
    ECData = ECInfo.ECData;
    ECPlotInfo = ECInfo.ECPlotInfo;
    numTernPoints = ternInfo.numPoints;
    xTernCoord = ternInfo.xCoords;
    yTernCoord = ternInfo.yCoords;
    xPoly = ternInfo.xPoly;
    yPoly = ternInfo.yPoly;
    ids = 0;
    
    % get the correct set of composition data
    if ternInfo.polySelected == 1
        found = 0;
        ids = 0;
        for i = 1:numTernPoints
            if inpolygon(xTernCoord(i), yTernCoord(i), xPoly, yPoly) == 1
                found = found + 1;
                ids(found) = i;
            end
        end
        spreads(1) = range(compA(ids));
        spreads(2) = range(compB(ids));
        spreads(3) = range(compC(ids));
        [~, indexMaxSpread] = max(spreads);
        if indexMaxSpread == 1
            specInfo.selectedComp = compA(ids);
            specInfo.selectedCompPartner = compC(ids);
            ternInfo.constType = 2;
        elseif indexMaxSpread == 2
            specInfo.selectedComp = compB(ids);
            specInfo.selectedCompPartner = compA(ids);
            ternInfo.constType = 0;
        else
            specInfo.selectedComp = compC(ids);
            specInfo.selectedCompPartner = compB(ids);
            ternInfo.constType = 1;
        end
    else
    
        if constType == 0
            ids = find(abs(compA - constPercent) < width);
            specInfo.selectedComp = compB(ids);
            specInfo.selectedCompPartner = compA(ids);
        elseif constType == 1
            ids = find(abs(compB - constPercent) < width);
            specInfo.selectedComp = compC(ids);
            specInfo.selectedCompPartner = compB(ids);
        else
            ids = find(abs(compC - constPercent) < width);
            specInfo.selectedComp = compA(ids);
            specInfo.selectedCompPartner = compC(ids);
        end
    end
    
    fSpecPlot.UserData = specInfo;
    figTern.UserData = ternInfo;
    fECPlot.UserData = ECInfo;
    
    if isempty(ids) == 1
        errordlg('No points selected');
        
    else
        idsOrig = ids;
        ids = ids .* 2;
        plotECWaterfall(ECData(:, ids - 1), ECData(:, ids), ...
            specInfo.selectedComp, ECPlotInfo(idsOrig, 4), ...
            ternHandles, specHandles, ECHandles);
    end
    
    if ECInfo.dataReal == 0
        fECPlot.Visible = 'off';
    end

end

