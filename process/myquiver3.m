function myquiver3 (v1, v2, id)
    hold on
    for i = 1:size(v1,1)
        lab1 = v1(i,:);
        rgb1 = lab2srgb([lab1(1)*1 lab1(2) lab1(3)])/255;
        plot3(lab1(2),lab1(3),lab1(1),'o','MarkerFaceColor',rgb1,'MarkerEdgeColor',rgb1)

        lab2 = v2(i,:);
        rgb2 = lab2srgb([lab2(1)*1 lab2(2) lab2(3)])/255;
        plot3(lab2(2),lab2(3),lab2(1),'s','MarkerFaceColor',rgb2,'MarkerEdgeColor',rgb2)

        lab21 = lab2-lab1;

        quiver3(lab1(2),lab1(3),lab1(1),lab21(2),lab21(3),lab21(1),'Color',rgb1)
        
        % add label
        %text(lab2(2),lab2(3),lab2(1),sprintf('%s%d',id,i))
        
        text((lab1(2)+lab2(2))/2,(lab1(3)+lab2(3))/2,(lab1(1)+lab2(1))/2,...
            sprintf('%.0f',id(i)))
    end

    xlabel('CIELAB a*')
    ylabel('CIELAB b*')
    zlabel('CIELAB L*')
    grid on

    view(67,-6)
    axis square 
    % axis([-80 120 -50 100 0 100])
end
