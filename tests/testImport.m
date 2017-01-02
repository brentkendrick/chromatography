function results = testImport()

% ---------------------------------------
% Variables
% ---------------------------------------
results.name = 'import';
results.pass = 0;
results.fail = 0;

srcPath  = fileparts(fileparts(mfilename('fullpath')));
dataPath = [srcPath, filesep, 'examples', filesep, 'data'];

% ---------------------------------------
% Files
% ---------------------------------------
agilentPath = [dataPath, filesep, 'agilent'];

agilentData = {...
    '002-GC-MS.D',...
    '008-GC-FID.D',...
    '081-GC-FID.D',...
    '179-GC-FID.D',...
    '181-GC-FID.D',...
    '030-LC-DAD.D',...
    '031-LC-DAD.D',...
    '130-LC-DAD.D',...
    '131-LC-DAD.D'
};

agilentFields = {...
    'file_path',...
    'file_name',...
    'file_size',...
    'sample_name',...
    'sample_info',...
    'operator',...
    'datetime',...
    'instrument',....
    'inlet',...
    'detector',...
    'method',...
    'seqindex',...
    'vial',...
    'replicate',...
    'sampling_rate',...
    'time',....
    'intensity',...  
    'channel',....
    'time_units',...
    'intensity_units',...
    'channel_units'....
};

nistPath = [dataPath, filesep, 'nist'];

nistData = {...
    '85-01-8.MSP'
};

nistFields = {...
    'file_path',...
    'file_name',...
    'file_size',...
    'compound_name',...
    'compound_formula',...
    'compound_mw',....
    'cas_id',...
    'nist_id',...
    'db_id',...
    'comments',...
    'num_peaks',...
    'mz',...
    'intensity'...
};

cdfPath = [dataPath, filesep, 'netcdf'];

cdfData = {...
    'agilent-ms.cdf',...
    'finnigan-ms.cdf',...
    'hp-ms.cdf',...
    'kratos-ms.cdf',...
    'sciex-ms.cdf'...
};

cdfFields = {...
    'file_path',...
    'file_name',...
    'file_size',...
    'dataset_completeness',...
    'netcdf_revision',...
    'ms_template_revision',....
    'experiment_date_time_stamp',...
    'netcdf_file_date_time_stamp',...
    'instrument_name',...
    'experiment_type',...
    'raw_data_mass_format',...
    'raw_data_intensity_format',...
    'scan_index',...
    'point_count',...
    'mass_values',...
    'intensity_values',...
    'total_intensity'...
};


% ---------------------------------------
% Intro
% ---------------------------------------
fprintf(['\n', repmat('-',1,50), '\n']);
fprintf('Import Functions');
fprintf(['\n', repmat('-',1,50), '\n']);

% ---------------------------------------
% Functions
% ---------------------------------------
results = testAgilentData(agilentData, agilentPath, agilentFields, results);
results = testNISTData(nistData, nistPath, nistFields, results);
results = testCDFData(cdfData, cdfPath, cdfFields, results);

% ---------------------------------------
% Summary
% ---------------------------------------
fprintf(['\n', '--------------', '\n']);
fprintf(['  <strong>PASS</strong> = ', num2str(results.pass), '\n']);
fprintf(2,'  FAIL ');
fprintf(['= ', num2str(results.fail)]);
fprintf(['\n', '--------------', '\n\n']);

end

% ---------------------------------------
% Agilent
% ---------------------------------------
function results = testAgilentData(filename, filepath, agilentFields, results)

% ---------------------------------------
% Function
% ---------------------------------------
fprintf(['\n', 'Function: ImportAgilent', '\n']);

for i = 1:length(filename)
    
    file = [filepath, filesep, filename{i}];
    data = ImportAgilent('file', {file}, 'verbose', 'off');
    
    switch filename{i}(1:3)
        case {'002'}
            filetype = '.MS';
        case {'008', '081', '179', '181', '030', '130'}
            filetype = '.CH';
        case {'031', '131'}
            filetype = '.UV';
    end
    
    if ~isempty(data.time) && ~isempty(data.intensity)
        fprintf('  <strong>PASS</strong>  ');
        fprintf([filetype, ' (', filename{i}(1:3), ')', '\n']);
        results.pass = results.pass + 1;
    else
        fprintf(2,'  FAIL  ');
        fprintf([filetype, ' (', filename{i}(1:3), ')', '\n']);
        results.fail = results.fail + 1;
    end
    
end

% ---------------------------------------
% Data
% ---------------------------------------
fprintf(['\n', 'Data: ImportAgilent', '\n']);

file = [filepath, filesep, filename{1}];
data = ImportAgilent('file', {file}, 'verbose', 'off');

for i = 1:length(agilentFields)
     
    if isfield(data, agilentFields{i}) && ~isempty(data.(agilentFields{i}))
        fprintf('  <strong>PASS</strong>  ');
        fprintf(['data.', agilentFields{i}, '\n']);
        results.pass = results.pass + 1;
    else
        fprintf(2,'  FAIL  ');
        fprintf(['data.', agilentFields{i}, '\n']);
        results.fail = results.fail + 1;
    end
    
end

end

% ---------------------------------------
% NIST
% ---------------------------------------
function results = testNISTData(filename, filepath, nistFields, results)

file = [filepath, filesep, filename{1}];
data = ImportNIST('file', file, 'verbose', 'off');

% ---------------------------------------
% Function
% ---------------------------------------
fprintf(['\n', 'Function: ImportNIST', '\n']);

if ~isempty(data)
    fprintf('  <strong>PASS</strong>  ');
    fprintf(['.MSP', '\n']);
    results.pass = results.pass + 1;
else
    fprintf(2,'  FAIL  ');
    fprintf(['.MSP', '\n']);
    results.fail = results.fail + 1;
end
    
% ---------------------------------------
% Data
% ---------------------------------------
fprintf(['\n', 'Data: ImportNIST', '\n']);

for i = 1:length(nistFields)
     
    if isfield(data, nistFields{i}) && ~isempty(data.(nistFields{i}))
        fprintf('  <strong>PASS</strong>  ');
        fprintf(['data.', nistFields{i}, '\n']);
        results.pass = results.pass + 1;
    else
        fprintf(2,'  FAIL  ');
        fprintf(['data.', nistFields{i}, '\n']);
        results.fail = results.fail + 1;
    end
    
end

end

% ---------------------------------------
% netCDF
% ---------------------------------------
function results = testCDFData(filename, filepath, cdfFields, results)

data = ImportCDF('file', filepath, 'depth', 2, 'verbose', 'off');

% ---------------------------------------
% Function
% ---------------------------------------
fprintf(['\n', 'Function: ImportCDF', '\n']);

if length(data) == length(filename) && length(fields(data)) > 3
    fprintf('  <strong>PASS</strong>  ');
    fprintf(['.CDF', '\n']);
    results.pass = results.pass + 1;
else
    fprintf(2,'  FAIL  ');
    fprintf(['.CDF', '\n']);
    results.fail = results.fail + 1;
end

% ---------------------------------------
% Data
% ---------------------------------------
fprintf(['\n', 'Data: ImportCDF', '\n']);

for i = 1:length(cdfFields)
    
    if isfield(data, cdfFields{i}) && ~any(cellfun(@isempty,{data.(cdfFields{i})}))
        fprintf('  <strong>PASS</strong>  ');
        fprintf(['data.', cdfFields{i}, '\n']);
        results.pass = results.pass + 1;
    else
        fprintf(2,'  FAIL  ');
        fprintf(['data.', cdfFields{i}, '\n']);
        results.fail = results.fail + 1;
    end
    
end

end
