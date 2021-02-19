function atlasblobs_merged = merge_atlas_blobs(atlasblobs1,atlasblobs2,varargin)

atlasblobs_list=[atlasblobs1,atlasblobs2,varargin{:}];

atlasblobs_merged=atlasblobs_list(1);
atlasblobs_merged.FV=aux_merge_field(atlasblobs_list.FV);
atlasblobs_merged.roilabels=aux_merge_field(atlasblobs_list.roilabels);
atlasblobs_merged.roicenters=aux_merge_field(atlasblobs_list.roicenters);
atlasblobs_merged.hemisphere=aux_merge_field(atlasblobs_list.hemisphere);
if(any(arrayfun(@(x)isempty(x.roinames),atlasblobs_list)))
    atlasblobs_merged.roinames={};
else
    atlasblobs_merged.roinames=aux_merge_field(atlasblobs_list.roinames);
end

function mergedfield = aux_merge_field(varargin)
sz=cellfun(@size,varargin,'uniformoutput',false);
maxdim=[];
for i = 1:numel(sz)
    [~,maxdim(i)]=max(sz{i});
end
if(all(maxdim==maxdim(1)))
    mergedfield=cat(maxdim(1),varargin{:});
else
    mergedfield=varargin(1);
    for i = 2:numel(varargin)
        if(maxdim(i)==maxdim(1))
            mergedfield{i}=varargin{i};
        else
            mergedfield{i}=varargin{i}.';
        end
    end
    mergedfield=cat(maxdim(1),mergedfield{:});
end
