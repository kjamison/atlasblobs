function atlasblobs = load_atlas_blobs_lookup(atlasblobname)

atlasblobs=[];
[sourcedir,~,~]=fileparts(mfilename('fullpath'));

if(strcmpi(atlasblobname,'list'))
    atlasblobfiles=dir(sprintf('%s/lookups/*.mat',sourcedir));
    atlasblobs=reshape({atlasblobfiles.name},[],1);
    return;
end

atlasblobfile_searchlist={atlasblobname,...
    sprintf('%s/lookups/%s',sourcedir,atlasblobname),...
    sprintf('%s/lookups/%s.mat',sourcedir,atlasblobname),...
    sprintf('%s/lookups/atlasblobs_%s.mat',sourcedir,atlasblobname),...
    sprintf('%s/lookups/%s_lookup',sourcedir,atlasblobname),...
    sprintf('%s/lookups/%s_lookup.mat',sourcedir,atlasblobname),...
    sprintf('%s/lookups/atlasblobs_%s_lookup.mat',sourcedir,atlasblobname)};

for i = 1:numel(atlasblobfile_searchlist)
    if(exist(atlasblobfile_searchlist{i},'file'))
        atlasblobs=load(atlasblobfile_searchlist{i});
    end
end

if(isempty(atlasblobs))
    error('No atlasblob lookup file found for input: %s. Try %s(''list'') for list of available files',atlasblobname,mfilename);
end