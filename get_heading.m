%returns the heading (arrows) needed to go towards 'goal' from 'start'
function heading = get_heading(goal,start)
[r1 c1] = start{:};
[r2 c2] = goal{:};
heading = [];
if r2 < r1 %goal is above start
    heading = [heading {'uparrow'}];
elseif r1 < r2
    heading = [heading {'downarrow'}];
end
if c2 < c1 %goal is left of start
    heading = [heading {'leftarrow'}];
elseif c1 < c2
    heading = [heading {'rightarrow'}];
end

end