function P_PSD_BASIC(PSD, fr, f, ax)

hold off;
set(0, 'currentfigure', f);
set(f, 'currentaxes', ax);
hold on;

nele = size(PSD,1);
PSD = H_SMOOTHD1(PSD');
PSD = H_SMOOTHD1(PSD');
fr = linspace(fr(1), fr(end), size(PSD,1));

imagesc(fr, 1:size(PSD,1), PSD)

c1 = colorbar;
xlabel('f (Hz)');

for ii = 1 : 32
    if isEven(ii)
        labels{ii} = num2str(ii);
    else
        labels{ii} = [];
    end
end

set(ax, 'ydir', 'rev','ylim', [1 size(PSD,1)], 'xlim', [3 120], 'ytick', linspace(1, size(PSD,1), nele), 'yticklabel', labels)
ylabel(c1, '% change from array mean')

end