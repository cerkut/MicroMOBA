function map = make_top_lane()
map = zeros(80,160,3);
temp = rand(80,160)>.99;
map(:,:,2) = temp;
map(1:15,[1:60 end-60:end],2) = 1;
map(end-15:end,61:end-60,2) = 1;
