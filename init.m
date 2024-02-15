% Def Parameters
Type = 0; % 0 = Displac, 1 = Veloc

Freq = ["40Hz", "60Hz", "80Hz", "100Hz", "120Hz", "140Hz", "160Hz", "180Hz"];

data = struct();

AquicFreq = 4000; 
dt = 1/AquicFreq;
dx = 0.3;
dz = 0.0252;

if Type == 0
    TypeName = "Disp";
elseif Type == 1
    TypeName = "Veloc";
end

% Usando uigetdir para selecionar o diretório
dir_path = uigetdir(title = 'Selecione um diretório para importar');

dir_save = uigetdir(title = 'Selecione um diretório para salvar');

% Checando se o usuário cancelou a seleção do diretório
if dir_path == 0
    disp('Seleção de diretório cancelada.');
    return;
end

% Obtendo a lista de arquivos no diretório
files = dir(fullfile(dir_path, 'das*.mat'));

% Checando se há arquivos correspondentes
if isempty(files)
    disp('Nenhum arquivo correspondente encontrado.');
    return;

else

    Map = cell(size(files,1), 1);
    % Criando a barra de progresso
    wbar1 = waitbar(0, 'Processing File', 'Name', 'Progresso de Processamento');

    for i = 1:size(files,1)

        waitbar(i / size(files, 1), wbar1, sprintf('Processing File %d/%d', i, size(files, 1)));

        auxload = load(files(i).folder + "\" + files(i).name);
        
        auxname = whos('-file',files(i).folder + "\" + files(i).name);
        
        PE_daq_das = auxload.(auxname.name);

        Map{i} = GenerateMapKasai(PE_daq_das, Type);

        filename = TypeName + Freq(i) + ".mat";

        fullfile_path = fullfile(dir_save, filename);

        disp_map = Map{i};

        save(fullfile_path,'disp_map','dx','dz','dt');

    end
    close(wbar1);

end
