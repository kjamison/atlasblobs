function colors = val2rgb(vals,colormap_or_axes,c_lim)
if(nargin < 2)
    colormap_or_axes = gca;
end

if(numel(colormap_or_axes) > 1) %it's a colormap array
    cmap = colormap_or_axes;
    clim = [min(flatten(vals)) max(flatten(vals))];
    
elseif(strcmpi(get(colormap_or_axes,'type'),'axes'))  %it's an axes object
    cmap = colormap;
    clim = get(colormap_or_axes,'clim');
end

if(nargin > 2)
    clim = c_lim;
end

cmap_idx = min(size(cmap,1),max(1,fix((size(cmap,1)-1)*((vals - clim(1)) / (clim(2)-clim(1))) + 1)));
sz=size(vals);
if(numel(vals)==max(sz))
    sz=numel(vals);
end
colors = reshape(cmap(cmap_idx,:),[sz size(cmap,2)]);
