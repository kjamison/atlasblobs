%add path to toolbox if needed
if(isempty(which('display_atlas_blobs')))
    addpath('~/Source/atlasblobs');
end

%% display FS86 lh+rh in 3D

roidata=rand(86,1);

cmap=hot(256);
clim=[0 2];

%for non-render, returns the figure handle
hfig=display_atlas_blobs(roidata,'fs86','hemi','both','colormap',cmap,'clim',clim,'backgroundimage','none','view',[-135 0]);

%add colorbar
colorbar(gca);
set(gca,'colormap',cmap,'clim',clim);
set(gca,'fontsize',16);

saveas(hfig,'~/Source/atlasblobs/mybrain_example_3d.png');

%% render FS86 lh+rh, medial+lateral views using white background

roidata=rand(86,1);

cmap=hot(256);
clim=[0 2];

%for rendered view, returns the [HxWx3] RGB image
img=display_atlas_blobs(roidata,'fs86','render','true','backgroundimage','white','colormap',cmap,'clim',clim);

imwrite(img,'~/Source/atlasblobs/mybrain_example_whitebg.png'); %save rendered image to file

%or display image and add colorbar
hfig=figure;
imshow(img);

%add colorbar
set(gca,'colormap',cmap,'clim',clim);
colorbar(gca);

set(gca,'fontsize',16);
set(hfig,'color',[1 1 1]); %set figure background to white to match

%% render FS86 lh+rh, medial+lateral views using black background

roidata=rand(86,1);

cmap=hot(256);
clim=[0 2];

%for rendered view, returns the [HxWx3] RGB image
img=display_atlas_blobs(roidata,'fs86','render','true','backgroundimage','black','colormap',cmap,'clim',clim);

%imwrite(img,'~/Source/atlasblobs/mybrain_example_blackbg.png'); %save rendered image to file

%or display image and add colorbar
hfig=figure;
imshow(img);

%add colorbar
set(gca,'colormap',cmap,'clim',clim);
hcb=colorbar(gca);

set(gca,'fontsize',16);
set(hfig,'color',[0 0 0]); %set figure background to black to match
set(hcb,'color','w'); %set colorbar outline and text to white for black bg

set(hfig,'InvertHardcopy','off'); %need this so saveas doesn't flip bg
saveas(hfig,'~/Source/atlasblobs/mybrain_example_blackbg_withcolorbar.png'); %save rendered image to file
