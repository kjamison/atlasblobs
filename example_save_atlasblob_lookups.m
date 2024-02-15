atlaslist={'fs86','shen268','cocommpsuit439'}
for ia = 1:numel(atlaslist)
    atlas=atlaslist{ia};
    blob=load_atlas_blobs(atlas);
    roivals=1:numel(blob.roilabels);

    bloblookup=display_atlas_blobs(roivals,atlas,'backgroundimage','white','render_roi',true);
    save(sprintf('~/Source/atlasblobs/lookups/atlasblobs_%s_lookup.mat',atlas),'-struct','bloblookup');
end

%%%% now try one of them out
roivals=1:268;
cmap=jet(256);
clim=[1 268];
img=display_atlas_blobs_lookup(roivals,'shen268','backgroundimage',false,'backgroundcolor',[1 1 1],'colormap',cmap,'clim',clim,'crop',true);
figure;
imshow(img);
