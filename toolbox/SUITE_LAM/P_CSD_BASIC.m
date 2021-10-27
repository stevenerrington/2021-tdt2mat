function P_CSD_BASIC(csd_in, time_vec, tlim, f, ax)

hold off;
set(0, 'currentfigure', f);
set(f, 'currentaxes', ax);
hold on;

tej = flipud(colormap('jet'));

csd_in = [csd_in(1,:) ; csd_in ; csd_in(end,:)];
nele = size(csd_in,1);
csd_in = H_2DSMOOTH(csd_in);

limi = nanmax(nanmax(abs(csd_in)));

imagesc(time_vec, 1:size(csd_in,1), csd_in);

xlabel('Time from Target (ms)');

for ii = 1 : 32
    if isEven(ii)
        labels{ii} = num2str(ii);
    else
        labels{ii} = [];
    end
end
set(gca,'xlim', tlim, 'ydir', 'rev','ylim', [1 size(csd_in,1)], 'ytick', linspace(1, size(csd_in,1), nele), 'yticklabel', labels)

caxis([-limi limi]);
colormap(tej);
c1 = colorbar;
ylabel(c1, 'nA/mm3)')

end