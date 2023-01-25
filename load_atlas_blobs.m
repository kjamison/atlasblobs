function atlasblobs = load_atlas_blobs(atlasblobname)

atlasblobs=[];
[sourcedir,~,~]=fileparts(mfilename('fullpath'));

if(strcmpi(atlasblobname,'list'))
    atlasblobfiles=dir(sprintf('%s/atlases/*.mat',sourcedir));
    atlasblobs=reshape({atlasblobfiles.name},[],1);
    return;
end

atlasblobfile_searchlist={atlasblobname,...
    sprintf('%s/atlases/%s',sourcedir,atlasblobname),...
    sprintf('%s/atlases/%s.mat',sourcedir,atlasblobname),...
    sprintf('%s/atlases/atlasblobs_%s.mat',sourcedir,atlasblobname)};

for i = 1:numel(atlasblobfile_searchlist)
    if(exist(atlasblobfile_searchlist{i},'file'))
        atlasblobs=load(atlasblobfile_searchlist{i});
    end
end

if(isempty(atlasblobs))
    error('No atlasblob file found for input: %s. Try %s(''list'') for list of available files',atlasblobname,mfilename);
end