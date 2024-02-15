function [pw_map, header] = framesKasai(IQData, header, roi)
%Axial displacement using the Power IQ.
%
% [map, header] = framesPower(IQDATA,HEADER,ROI)
%
% Author(s): J. H. Uliana
% $Revision: 0.0 $  $Date: Dec-2023$
%

nframe = size(IQData,3);
wbar2 = waitbar(0,'Power IQ...');

% frame interval
df = header.pp.dt + 1;
f0 = header.pp.inif;
ff = header.pp.endf;

if (f0 <= 0)
    f0 = 1;
end

if (ff <= f0)
    ff = nframe;
end

% bounds condition and region of interest
idx0    = roi.xi;
idx   = roi.xf;
idz0   = roi.zi;
idz    = roi.zf;

% inicializaton for frame
m = 1;
f = f0;

%calculate displacement
while f + df <= ff-df
    
    waitbar(f/ff,wbar2);
    
    if header.mg.velo == 0
        IQ1 = squeeze(IQData(idz0:idz,idx0:idx,f0));
        IQ2 = squeeze(IQData(idz0:idz,idx0:idx,f+df));
    else
        IQ1 = squeeze(IQData(idz0:idz,idx0:idx,f));
        IQ2 = squeeze(IQData(idz0:idz,idx0:idx,f+df));
    end
    
    ImMean = (imag(IQ1) + imag(IQ2))/2;
    ReMean = (real(IQ1) + real(IQ2))/2;
    Im = (imag(IQ1)-ImMean) .* (real(IQ2)-ReMean) - ...
        (imag(IQ2)-ImMean) .* (real(IQ1)-ReMean);
    Re = (imag(IQ1)-ImMean) .* (imag(IQ2)-ImMean) + ...
        (real(IQ1)-ReMean) .* (real(IQ2)-ReMean);
    pw_map(:,:,m) = ((Im .* Im + Re .* Re).^0.125);
    f = f + df;
    m = m + 1;
end
close(wbar2);




