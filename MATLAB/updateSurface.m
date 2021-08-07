function updateSurface(p_1, p_2, p_3, p_4, p_5, p_6, p_7, p_8, display_arr)

Channles_=display_arr;


p_1.YData = Channles_(1,:);
p_2.YData = Channles_(2,:);
p_3.YData = Channles_(3,:);
p_4.YData = Channles_(4,:);
p_5.YData = Channles_(5,:);
p_6.YData = Channles_(6,:);
p_7.YData = Channles_(7,:);
p_8.YData = Channles_(8,:);
drawnow

end