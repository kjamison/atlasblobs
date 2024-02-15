function img = display_atlas_blobs_lookup(roivals,atlasblobs_lookup,varargin)
% img or fig = display_atlas_blobs_lookup(roivals,atlasblobs_lookup or name,'param',value,...)
% 
% Required inputs:
% roivals = Rx1 vector with 1 value per ROI in atlasblobs 
% atlasblobs = struct (or struct array) generated from make_atlas_blobs()
%   (or name of atlas or file in <sourcedir>/atlases)
% 
% Optional inputs:
% colormap = colormap name or Cx3 [r g b] colormap matrix
% clim = [min max] value range
% backgroundimage = 'white','black','none' (or true/false to show slice from atlasblob file)
%    (selected during make_atlas_blobs())
% backgroundcolor = [r g b] background color for figure
% crop = true/false to automatically crop rendered images
%
% Output:
% HxWx3 RGB image

args = inputParser;
args.addParameter('colormap',[]);
args.addParameter('clim',[]);
args.addParameter('backgroundimage',false);
args.addParameter('backgroundcolor',[1 1 1]);
args.addParameter('crop',true);
args.addParameter('noshading',false);

args.parse(varargin{:});
args = args.Results;

[sourcedir,~,~]=fileparts(mfilename('fullpath'));

if(ischar(atlasblobs_lookup))
    atlasblobs_lookup=load_atlas_blobs_lookup(atlasblobs_lookup);
end

if(isempty(args.colormap))
    args.colormap=get(0,'defaultfigurecolormap');
elseif(ischar(args.colormap))
    args.colormap=evalin('caller',sprintf('%s(256)',args.colormap));
end

if(isempty(args.clim))
    args.clim=[nanmin(roivals(:)) nanmax(roivals(:))];
end

img_val=roivals(atlasblobs_lookup.index);

img=val2rgb(img_val,args.colormap,args.clim);
bg_rgb=val2rgb(ones(size(img_val)),args.backgroundcolor,[0 1]);


if(~isempty(args.backgroundimage) && (isnumeric(args.backgroundimage) || islogical(args.backgroundimage)))
    if(args.backgroundimage>0)
        bg_rgb=atlasblobs_lookup.background;
    end
elseif(ischar(args.backgroundimage) && ~strcmpi(args.backgroundimage,'none'))
    bg_rgb=atlasblobs_lookup.background;
end

img=bsxfun(@times,img,atlasblobs_lookup.mask)+bsxfun(@times,bg_rgb,1-atlasblobs_lookup.mask);
if(~args.noshading)
    img=bsxfun(@times,img,atlasblobs_lookup.shading);
end

if(args.crop)
    numviews=max(atlasblobs_lookup.viewnumber(:));
    imglist={};
    croprect={};
    viewrect={};
    %split into a rectangle for each view, find the largest crop rectangle
    %within those views, then apply that crop to all views
    for i = 1:numviews
        m=atlasblobs_lookup.viewnumber~=i;
        [fgx, fgy] = ind2sub(size(m),find(~m));
        mrect = [min(fgx) min(fgy) max(fgx) max(fgy)];
        viewrect{i}=mrect;
        imglist{i}=img(mrect(1):mrect(3),mrect(2):mrect(4),:);
        [~,croprect{i}]=CropBGColor(imglist{i},imglist{i}(1,1,:));
    end
    croprect=cat(1,croprect{:});
    croprect=[min(croprect(:,1:2),[],1) max(croprect(:,3:4),[],1)];
    imgnew=nan(size(img));
    %for this purpose, cropping = setting outside crop to nan
    for i = 1:numviews
        mrect=viewrect{i};
        imglist{i}(1:croprect(1),:,:)=nan;
        imglist{i}(:,1:croprect(2),:,:)=nan;
        imglist{i}(croprect(3)+1:end,:,:)=nan;
        imglist{i}(:,croprect(4)+1:end,:,:)=nan;
        imgnew(mrect(1):mrect(3),mrect(2):mrect(4),:)=imglist{i};
    end
    %now remove nan rows/columns
    nancols=all(isnan(imgnew(:,:,1)),1);
    imgnew=imgnew(:,~nancols,:);
    nanrows=all(isnan(imgnew(:,:,1)),2);
    imgnew=imgnew(~nanrows,:,:);
    
    img=imgnew;
end
