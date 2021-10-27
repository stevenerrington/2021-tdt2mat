function [CSDf] = H_2DSMOOTH(CSD)

    new_CSD_matrix=[];
    totchan = (size(CSD,1) + 2)/10;
    el_pos = .1:.1:totchan;

    
    npoints = 10* size(CSD,1);
    le = length(el_pos)-2;
    first_z = el_pos(1)-(el_pos(2)-el_pos(1))/2; %plot starts at z1-h/2;
    last_z = el_pos(le)+(el_pos(le)-el_pos(le-1))/2; %ends at zN+h/2;
    zs = first_z:(last_z-first_z)/npoints:last_z;
    el_pos(le+1) = el_pos(le)+(el_pos(le)-el_pos(le-1)); % need an extra pos in for-loop
    j=1; %counter
    for i=1:length(zs) % all new positions
        if zs(i)>(el_pos(j)+(el_pos(j+1)-el_pos(j))/2) % > el_pos(j) + h/2
            j = min(j+1,le);
        end
        new_CSD_matrix(i,:) = CSD(j,:);
    end
    % and filter
    
    gauss_sigma  = 0.05;
    filter_range = 5*gauss_sigma; % numeric filter must be finite in extent
    [zs,CSDf]  = gaussian_filtering(zs,new_CSD_matrix,gauss_sigma,filter_range);
    
end

function [new_positions,gfiltered_CSD] = gaussian_filtering(positions,unfiltered_CSD,gauss_sigma,filter_range)


if nargin<4; filter_range = 5*gauss_sigma; end;


step = positions(2)-positions(1);
filter_positions = -filter_range/2:step:filter_range/2;
gaussian_filter = 1/(gauss_sigma*sqrt(2*pi))*exp(-filter_positions.^2/(2*gauss_sigma^2));

filter_length = length(gaussian_filter);
[m,n]=size(unfiltered_CSD);
temp_CSD=zeros(m+2*filter_length,n);
temp_CSD(filter_length+1:filter_length+m,:)=unfiltered_CSD(:,:);
scaling_factor = sum(gaussian_filter);
temp_CSD = filter(gaussian_filter/scaling_factor,1,temp_CSD);
gfiltered_CSD=temp_CSD(round(1.5*filter_length)+1:round(1.5*filter_length)+m,:);

new_positions = positions;
end