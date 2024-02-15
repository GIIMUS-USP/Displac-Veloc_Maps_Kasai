function pw_map = GenerateMapKasai(PE_daq_das, Type)

    PE_daq_das = double(PE_daq_das);

    % Converter para dataRF
    for k = 1:size(PE_daq_das,3)
        handles.dataRF{k} = PE_daq_das(:,:,k);
    end

    % Parâmetros de frequência
    fs = 31.25e+6;
    fc = 7.6e+6;

    % Cálculo do tempo
    t = 0:fs:(size(handles.dataRF{1},1)-1)*fs;

    % Inicialização do buffer IQ
    counter = 1;
    wbar = waitbar(0, 'Calculating IQ Data');
    IQBuffer = zeros(size(handles.dataRF{1},1),size(handles.dataRF{1},2),size(handles.dataRF,2));
    for iq = 1:size(handles.dataRF,2)
        IQBuffer(:,:,counter) = hilbert(handles.dataRF{iq}).*exp(-2j*pi*(fc/4)*t')/sqrt(2);
        counter = counter +1;
        waitbar(iq/size(handles.dataRF,2),wbar)
    end
    close(wbar)

    % Dados IQ
    dataIQ = IQBuffer;
    header.pp = struct('dt', 0, 'inif',0 , 'endf', size(handles.dataRF,2));
    header.mg.velo = Type;

    % Definição dos limites da região de interesse
    xi = 1;
    xf = size(dataIQ,2);
    zi = 1;
    zf = size(dataIQ,1);

    roi = struct("xi",xi,'xf',xf,"zi",zi,"zf",zf);

    % Chamada para gerar o mapa
    [pw_map, header] = framesKasai(dataIQ, header, roi);
end
