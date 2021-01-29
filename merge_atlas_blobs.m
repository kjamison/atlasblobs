function atlasblobs_merged = merge_atlas_blobs(atlasblobs1,atlasblobs2,varargin)

atlasblobs_list=[atlasblobs1,atlasblobs2,varargin{:}];

atlasblobs_merged=atlasblobs_list(1);
atlasblobs_merged.FV=cat(2,atlasblobs_list.FV);
atlasblobs_merged.roilabels=cat(1,atlasblobs_list.roilabels);
atlasblobs_merged.roicenters=cat(1,atlasblobs_list.roicenters);
atlasblobs_merged.hemisphere=cat(2,atlasblobs_list.hemisphere);
if(any(arrayfun(@(x)isempty(x.roinames),atlasblobs_list)))
    atlasblobs_merged.roinames={};
else
    atlasblobs_merged.roinames=cat(2,atlasblobs_list.roinames);
end
