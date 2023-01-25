function retval = display_atlas_blobs(roivals,atlasblobs,varargin)
% img or fig = display_atlas_blobs(roivals,atlasblobs,'param',value,...)
% 
% Required inputs:
% roivals = Rx1 vector with 1 value per ROI in atlasblobs 
% atlasblobs = struct (or struct array) generated from make_atlas_blobs()
%   (or name of atlas or file in <sourcedir>/atlases)
% 
% Optional inputs:
% atlasname = name of atlas to select if atlasblobs is an array
% colormap = colormap name or Cx3 [r g b] colormap matrix
% clim = [min max] value range
% render = true/false. true = render all views off screen and return final
%    composed image. False = return visible figure for rotation and viewing 
% roimask = Rx1 vector of true/false to exclude some ROIs if needed
% backgroundimage = 'white','black','none' (or true/false to show slice from atlasblob file)
%    (selected during make_atlas_blobs())
% backgroundcolor = [r g b] background color for figure
% surfacesmoothing = iterations of extra surface smoothing if needed
% crop = true/false to automatically crop rendered images
% hemi = 'lh', 'rh', or 'both' (for render=true, defaults to both)
%
% Output:
% HxWx3 RGB image if render=true
% figure handle if render=false

args = inputParser;
args.addParameter('atlasname',[]);
args.addParameter('alpha',[]);
args.addParameter('colormap',[]);
args.addParameter('clim',[]);
args.addParameter('render',false);
args.addParameter('roimask',[]);
args.addParameter('backgroundimage',true);
args.addParameter('backgroundimage_clim',[-inf inf]);
args.addParameter('backgroundimage_alpha',1);
args.addParameter('backgroundcolor',[]);
args.addParameter('surfacesmoothing',0);
args.addParameter('view',[]);
args.addParameter('render_viewnames',{'lateral','medial'});
args.addParameter('crop',true);
args.addParameter('hemi',{'lh','rh'});

args.parse(varargin{:});
args = args.Results;

[sourcedir,~,~]=fileparts(mfilename('fullpath'));

if(ischar(atlasblobs))
    atlasblobs=load_atlas_blobs(atlasblobs);
end

if(~isempty(args.atlasname) && numel(atlasblobs)>1)
    atlasidx=find(strcmpi({atlasblobs.atlasname},args.atlasname));
    if(isempty(atlasidx))
        error('Atlas %d not found: %s\n',args.atlasname);
    end
    
    atlasblobs=atlasblobs(atlasidx);
end

if(isempty(args.colormap))
    args.colormap=get(0,'defaultfigurecolormap');
elseif(ischar(args.colormap))
    args.colormap=evalin('caller',sprintf('%s(256)',args.colormap));
end

if(isempty(args.clim))
    args.clim=[nanmin(roivals(:)) nanmax(roivals(:))];
end


bgslicefile=fullfile(sourcedir,'background_slice.mat');
bgslice_default=[];
if(exist(bgslicefile,'file'))
    bgslice_default=load(bgslicefile);
end

bgcolor_default=[1 1 1];
bgslice=atlasblobs.backgroundslice;
bgslice_alphamap=ones(size(bgslice));

if(~isempty(args.backgroundimage) && (isnumeric(args.backgroundimage) || islogical(args.backgroundimage)))
    args.backgroundimage=args.backgroundimage>0;
    if(args.backgroundimage)
        bgcolor_default=[0 0 0];
    end
elseif(strcmpi(args.backgroundimage,'black') && ~isempty(bgslice_default))
    bgslice=bgslice_default.backgroundslice_blackbg;
    bgslice_alphamap=bgslice_default.backgroundslice_alpha;
    bgcolor_default=[0 0 0];
    args.backgroundimage=true;
elseif(strcmpi(args.backgroundimage,'white') && ~isempty(bgslice_default))
    bgslice=bgslice_default.backgroundslice_whitebg;
    bgslice_alphamap=bgslice_default.backgroundslice_alpha;
    bgcolor_default=[1 1 1];
    args.backgroundimage=true;
else
    args.backgroundimage=false;
end

if(isempty(args.backgroundcolor))
    args.backgroundcolor=bgcolor_default;
end

render_viewnames=args.render_viewnames;
if(~iscell(render_viewnames))
    render_viewnames={render_viewnames};
end

if(isempty(args.alpha))
    alphavals=ones(size(roivals));
elseif(numel(args.alpha)==1)
    alphavals=args.alpha*ones(size(roivals));
else
    alphavals=args.alpha/max(args.alpha);
end

background_nonrender_xposition=0;

roicolors = val2rgb(roivals,args.colormap,args.clim);

if(args.render)
    fig=figure('visible','off','color',args.backgroundcolor);
else
    fig=figure('color',args.backgroundcolor);
end
fig.InvertHardcopy = 'off';
ax=axes(fig);
axis(ax,'vis3d','equal','off');
set(ax,'NextPlot','add');


%[p,t]=BuildSphere(2);
%FVsph=struct('vertices',p,'faces',t);
%roiradius=5*ones(size(roixyz,1),1);


tmpd=tempname;
mkdir(tmpd);

if(isempty(args.hemi) || isequal(args.hemi,'both'))
    hemis={'lh','rh'};
elseif(ischar(args.hemi))
    hemis={args.hemi};
else
    hemis=args.hemi;
end

hcam=[];
hs_bgslice=[];

img_all={};
for h = 1:numel(hemis)
    hemi=hemis{h};
    
    
    
    
    
    if(strcmpi(hemi,'lh'))
        hemimask=ismember(lower(atlasblobs.hemisphere),{'l','lh','left','both',''});
        render_viewpoints=struct();
        render_bgpos=struct();
        
        render_viewpoints.lateral=[-90 0];
        render_bglayerpos.lateral=200;
        
        render_viewpoints.medial=[90 0];
        render_bglayerpos.medial=-200;

    elseif(strcmpi(hemi,'rh'))
        hemimask=ismember(lower(atlasblobs.hemisphere),{'r','rh','right','both',''});
        render_viewpoints=struct();
        render_bgpos=struct();
        
        render_viewpoints.lateral=[90 0];
        render_bglayerpos.lateral=-200;
        
        render_viewpoints.medial=[-90 0];
        render_bglayerpos.medial=200;
    end

    viewpoints={};
    bglayerpos={};
    viewnames={};
    for v = 1:numel(render_viewnames)
        if(~isfield(render_viewpoints,lower(render_viewnames{v})))
            error('Unknown render viewname %s',render_viewnames{v});
        end
        viewnames{v}=lower(render_viewnames{v});
        viewpoints{v}=render_viewpoints.(lower(render_viewnames{v}));
        bglayerpos{v}=render_bglayerpos.(lower(render_viewnames{v}));
    end
    
    
    if(ischar(args.view))
        if(strcmpi(args.view,'medial'))
            args.view=render_viewpoints.medial;
            background_nonrender_xposition=render_bglayerpos.medial;
        elseif(strcmpi(args.view,'lateral'))
            args.view=render_viewpoints.lateral;
            background_nonrender_xposition=render_bglayerpos.lateral;
        end
    end
    
    if(args.render)
        cla(ax);
    end
    for i = 1:numel(roivals)
        roi_idx=find(atlasblobs.roilabels==i);
        
        if(~isempty(args.roimask) && ~args.roimask(i))
            continue;
        end
        if(isnan(roivals(i)))
            continue;
        end
        for ri = 1:numel(roi_idx)
            iroi=roi_idx(ri);
            if(~hemimask(iroi))
                continue;
            end
            FV=atlasblobs.FV{iroi};
            if(args.surfacesmoothing==0)
                verts_new=FV.vertices;
            else
                if(isfield(FV,'conn'))
                    conn=FV.conn;
                else
                    conn = vertex_neighbours(FV);
                end
                verts_new = mesh_smooth_vertices(FV.vertices, conn,[],args.surfacesmoothing);
            end
            hp=patch(ax,struct('vertices',verts_new,'faces',FV.faces),'linestyle','none','facecolor',roicolors(i,:),'facealpha',alphavals(i));
            set(hp,'tag',sprintf('roi%03d',i));
            if(false)
                %incomplete test section for drawing text labels

                %labelx=min(verts_new(:,1));
                labelx=0;
                if(~isempty(atlasblobs.roinames))
                    labelstr=atlasblobs.roinames{i};
                else
                    labelstr=sprintf('%s.%d',atlasblobs.atlasname,i);
                end
                textargs={'verticalalignment','middle','horizontalalignment','center','tag','roilabel'};

                text(ax,labelx,atlasblobs.roicenters(i,2),atlasblobs.roicenters(i,3),labelstr,textargs{:});
            end
            %verts_new=bsxfun(@plus,FVsph.vertices*roiradius(i),roixyz(i,:));
            %patch(struct('vertices',verts_new,'faces',FVsph.faces),...
            %    'linestyle','none','facecolor',roicolors(i,:));
        end
    end
    material(ax,'dull');
    lighting(ax,'phong');
    
    if(~isempty(args.view))
        view(ax,args.view);
    end

    if(args.backgroundimage && (isempty(hs_bgslice) || ~ishandle(hs_bgslice)))
        %hs=surface(ax,zeros(2,2),'facecolor','texturemap','cdata',atlasblobs.backgroundslice,'linestyle','none');
        %set(hs,'xdata',[0 0]);
        %set(hs,'ydata',atlasblobs.backgroundposition([1 2],2)); %[-126 90]);
        %set(hs,'zdata',reshape(atlasblobs.backgroundposition([1 3; 1 3],3),[2 2])); %[-72 108; -72 108]);
        
        %new style to allow interpolating background slice
        
        
        bgsz=size(bgslice);
        bgpos=atlasblobs.backgroundposition;
        bgxpos=background_nonrender_xposition;
        
        cl=args.backgroundimage_clim;
        if(isinf(cl(1)) && cl(1)<0)
            cl(1)=min(bgslice(:));
        end
        if(isinf(cl(2)) && cl(2)>0)
            cl(2)=max(bgslice(:));
        end
        bgimg_rgb=val2rgb(bgslice,gray(256),cl);
        bgimg_alpha=bgslice_alphamap*args.backgroundimage_alpha;
        bgimg_alpha_args={'alphadata',bgimg_alpha,'alphadatamapping','none','facealpha','interp'};
        
        %bgimg_alpha_args={'facealpha',args.backgroundimage_alpha};
        hs_bgslice=surface(ax,zeros(bgsz),'facecolor','interp','cdata',bgimg_rgb,'linestyle','none','tag','backgroundslice',bgimg_alpha_args{:});

        [bgz,bgy]=meshgrid(linspace(bgpos(1,3),bgpos(3,3),bgsz(2)),linspace(bgpos(1,2),bgpos(2,2),bgsz(1)));
        
        set(hs_bgslice,'xdata',bgxpos+zeros(bgsz));
        set(hs_bgslice,'ydata',bgy); %[-126 90]);
        set(hs_bgslice,'zdata',bgz); %[-72 108; -72 108]);
        
        material(hs_bgslice,'dull');
    end
    

    if(~args.render)
        continue;
        %retval=fig;
        %return;
    end

    for i = 1:numel(viewpoints)
        view(ax,viewpoints{i});
        if(~isempty(hs_bgslice) && ishandle(hs_bgslice))
            set(hs_bgslice,'xdata',ones(size(get(hs_bgslice,'xdata')))*bglayerpos{i});
        end
        if(~isempty(hcam))
            delete(hcam);
        end
        hcam=camlight(ax,'headlight');
        
        tmpimgfile=sprintf('%s/atlasblob_%s_%s.png',tmpd,hemi,viewnames{i});
        saveas(fig,tmpimgfile);
        img_all{end+1}=imread(tmpimgfile);
        
    end
end
if(~args.render)
    camlight(ax,'headlight');
    RotationHeadlight(fig,true);
    retval=fig;
    return;
end

close(fig);
rmdir(tmpd,'s');

if(args.crop)
    croprect={};
    for i = 1:numel(img_all)
        [~,croprect{i}] = CropBGColor(img_all{i},img_all{1}(1,1,:));
    end
    croprect=cat(1,croprect{:});
    croprect=[min(croprect(:,1:2),[],1) max(croprect(:,3:4),[],1)];
    for i = 1:numel(img_all)
        img_all{i}=img_all{i}(croprect(1):croprect(3),croprect(2):croprect(4),:);
    end
end

if(numel(img_all)==4)
    img_new=[[img_all{1}; img_all{2}] [img_all{3}; img_all{4}]];
else
    img_new=cat(2,img_all{:});
end

retval=img_new;
%imwrite(img_new,sprintf('~/Downloads/%s_allviews.png',whichatlas));