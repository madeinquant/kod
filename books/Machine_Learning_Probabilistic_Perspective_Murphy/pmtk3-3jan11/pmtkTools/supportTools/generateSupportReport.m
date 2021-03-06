function generateSupportReport()
%% Generate the html table describing packages in pmtkSupport
% and write it to PMTKlocalSupportPath/docs/authors/packageAuthors.html
% You need to commit this modified file in  svn.
% Creating the report takes a few seconds.
% PMTKneedsMatlab
%% Setup

% This file is from pmtk3.googlecode.com

root      = getConfigValue('PMTKlocalSupportPath');
dest      = fullfile(root, 'docs', 'authors');
pmtkRed   = getConfigValue('PMTKred');

% Read all the meta information from the meta directory

%metadir   = fullfile(root, 'meta');
%metafiles = filelist(metadir, '*-meta.m', false);

% Read all the meta information from each package directory
% We could use scrapePmtkSupport to read package names from the
% svn, but this may fail if things aren't checked in
folders = dirPMTK(root);
folders = setdiff(folders, {'docs', 'meta', 'pmtkSupportRoot.m', 'readme.txt'});
N = numel(folders);
metafiles = cell(1, N);
for fi=1:N
  metafiles{fi} = fullfile(root, folders{fi}, sprintf('%s-readme.txt', folders{fi}));
end

%{
% move old meta files to new readme files
for fi=1:N
  src = fullfile(root, 'meta', sprintf('%s-meta.m', folders{fi}));
  destn = fullfile(root, folders{fi}, sprintf('%s-readme.txt', folders{fi}))
  cmd = sprintf('cp %s %s', src, destn)
  system(cmd)
end
%}

%{
% add all readme files
for fi=1:N
  destn = fullfile(root, folders{fi}, sprintf('%s-readme.txt', folders{fi}))
  cmd = sprintf('svn add %s', destn)
  system(cmd)
end
%}


fname     = fullfile(dest, 'packageAuthors.html');
colNames  = {'PACKAGE NAME', 'AUTHOR(S)', 'SOURCE URL', 'DATE', 'DIRECTORY'};
%% Gather data
%packageNames = cellfuncell(@(c)c(1:end-5), filenames(metafiles)); % removes -meta
packageNames = cellfuncell(@(c)c(1:end-7), filenames(metafiles)); % removes -readme
npackages = numel(metafiles);
data      = repmat({'&nbsp;'}, npackages, length(colNames));
for j=1:npackages
    metafile = metafiles{j};
    [tags, lines] = tagfinder(metafile);
    tagmap = createStruct(tags, lines);
    if isfield(tagmap, 'PMTKtitle')
        data{j, 1} = tagmap.PMTKtitle;
    end
    if isfield(tagmap, 'PMTKauthor')
        data{j, 2} = tagmap.PMTKauthor;
    end
    if isfield(tagmap, 'PMTKurl')
        data{j, 3} = sprintf(' <a href="%s"> website ', strtrim(tagmap.PMTKurl));
    end
    if isfield(tagmap, 'PMTKdate')
        data{j, 4} = tagmap.PMTKdate;
    end
    data{j, 5} = ...
        sprintf('<a href = "http://pmtksupport.googlecode.com/svn/trunk/%s/">/%s</a>', ...
        packageNames{j}, packageNames{j}); 
end
%% Sort data by title
data = data(sortidx(lower(data(:, 1))), :); 
%% Create html table
header = [...
    sprintf('<font align="left" style="color:%s"><h2>Packages in pmtkSupport</h2></font>\n', pmtkRed),...
    sprintf('<br>Revision Date: %s<br>\n', date()),...
    sprintf('<br>Auto-generated by generateSupportReport.m<br>\n'),...
    sprintf('<br>\n')...
         ];
htmlTable(...
    'data'          , data                                  , ...
    'colNames'      , colNames                              , ...
    'doSave'        , true                                  , ...
    'filename'      , fname                                 , ...
    'colNameColors' , repmat({pmtkRed}, 1, numel(colNames)) , ...
    'header'        , header                                , ...
    'dataAlign'     , 'left'                                , ...
    'caption'       , '<br> <br>'                           , ...
    'captionLoc'    , 'bottom'                              , ...
    'doshow'        , false);
%%
