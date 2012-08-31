%FIX INDEXING UPON DEATH
classdef top_lane_game < handle
    properties
        numteams = 2;
        tempmap;
        map;
        permhitmap;
        hitmap;
%         dispmap;
mapR;
mapG;
mapB;
        
        map_size;
        
        mob_list;
        missile_list = [];
        player_list;
        missile_map;
        mob_map;
        
        turn_based;
        
        winsize = 41;
        
        dxnkey = [];
        
        display = [];
        
        human_ind = 0;
        
        game_over = false;
        
        frameno;
        framerate = 30;
    end
    methods(Access = protected)
        function game_loop(obj)
            obj.frameno = 1;
            
            while 1
                tic
                obj.frameno = obj.frameno +1;
%                 obj.dispmap = zeros(size(obj.map));
                obj.mapR = zeros(obj.map_size);
                obj.mapG = zeros(obj.map_size);
                obj.mapB = zeros(obj.map_size);
                obj.tempmap = obj.map;
                obj.hitmap = obj.permhitmap;
                for i = 1:length(obj.player_list)%put players on the tempmap
                    obj.tempmap(obj.player_list(i).mapr,obj.player_list(i).mapc,1) = 1;
                end
                %select moves-------------------------------------------------
                for i = 1:length(obj.player_list)
                    if obj.human_ind == i
                        drawnow;
                        if obj.turn_based
                            while isempty(obj.dxnkey) || isempty(intersect(obj.player_list(i).champion.possible_actions,obj.dxnkey))
                                pause(1/60);
                            end
                        end
                        pick = obj.dxnkey;
                    else
                        pick = obj.player_list(i).choose_action;
                    end
                    %check for cc and deal with it---------------------------
                    
                    if obj.player_list(i).taunted
                        taunter = obj.player_list([obj.player_list.id] == obj.player_list(i).taunted(1));
                        if ~isempty(taunter) %taunter died whilst taunting
                            pick =  [{'space'} get_heading(taunter.position,obj.player_list(i).position)];
                            obj.player_list(i).taunted(2) = max(0,obj.player_list(i).taunted(2) - 1/obj.framerate);
                            if mod(obj.frameno,2) == 1
                                ind = sub2ind(obj.map_size,obj.player_list(i).position{1}+ [-5 5 5 -5],obj.player_list(i).position{2} + [-5 5 -5 5]);
                            else
                                ind = sub2ind(obj.map_size,obj.player_list(i).position{1}+ [0 0 -5 5],obj.player_list(i).position{2} + [-5 5 0 0]);
                            end
                            obj.set_color(ind,rand(1,3));
                            
                        end
                    end
                    %perform moves-------------------------------------------------
                    obj.tempmap(obj.player_list(i).mapr,obj.player_list(i).mapc,1) = 0;
                    obj.player_list(i).champion.perform_action(obj,obj.player_list(i),pick);
                    obj.tempmap(obj.player_list(i).mapr,obj.player_list(i).mapc,1) = 1;
                    hp = obj.player_list(i).cur_health/obj.player_list(i).max_health;
                    %color the players-------------------------------------------------
                    obj.mapG(obj.player_list(i).mapr,obj.player_list(i).mapc)=hp;
                    obj.mapR(obj.player_list(i).mapr,obj.player_list(i).mapc)=1-hp;
                    if obj.player_list(i).team == 1
                        color = 'teal';
                    else
                        color = 'purple';
                    end
                    ind = sub2ind(obj.map_size,obj.player_list(i).position{1}+ [-2:2 2:-1:-2],obj.player_list(i).position{2} + [-2:2 -2:2]);
                        obj.set_color(ind,color);
                end
                %environment performed actions-----------------------------
                %DO THIS NEXT
                %minion movement (treat as missiles?)
                
                %missile animation---------------------------------------------    
                obj.animate_missiles();
                
                %render screens -----------------------------------------------
%                 for i = 1:length(obj.player_list)
%                     player = obj.player_list(i);
%                     [row col] = player.position{:};
%                     side = floor(obj.winsize/2);
%                     ind = {row-side:row+side ;col-side:col+side};
%                     player.screen = obj.tempmap(ind{:},:);
%                     player.screen(:,:,3) = player.screen(:,:,3) | obj.hitmap(player.team).id(ind{:});
%                     player.screen(:,:,2) = player.screen(:,:,2) | obj.hitmap(mod(player.team,2)+1).id(ind{:});
%                     player.screen = double(player.screen);
%                     player.screen(repmat(player.shape,[1,1,3])) = player.cur_health/player.max_health;
%                 end
%                 temp = zeros(obj.map_size);
%                 temp(obj.map(:,:,2)) = rand(size(find(obj.map(:,:,2))));
%                 obj.dispmap(:,:,3) = min(1,obj.dispmap(:,:,3)+temp);
%                 temp(obj.map(:,:,2)) = rand(size(find(obj.map(:,:,2))));
%                 obj.dispmap(:,:,2) = min(1,obj.dispmap(:,:,2)+temp);
%                 obj.dispmap(:,:,1) = min(1,obj.dispmap(:,:,1) + obj.map(:,:,1));
%                 obj.dispmap(:,:,2) = min(1,obj.dispmap(:,:,2) + obj.hitmap(1).id);
%                 obj.dispmap(:,:,3) = min(1,obj.dispmap(:,:,3) + obj.hitmap(2).id);
                obj.mapG(obj.map(:,:,2)) = min(1,obj.mapG(obj.map(:,:,2)) + rand(size(find(obj.map(:,:,2)))));
                obj.mapB(obj.map(:,:,2)) = min(1,obj.mapG(obj.map(:,:,2)) + rand(size(find(obj.map(:,:,2)))));
                obj.mapR = min(1,obj.mapR + obj.map(:,:,1));
%                 obj.mapG = min(1,obj.mapG + obj.hitmap(1).id);
%                 obj.mapB = min(1,obj.mapB + obj.hitmap(2).id);
%                 ind = find(obj.hitmap(1).id);
%                 obj.set_color(ind,'purple');
%                 ind = find(obj.hitmap(2).id);
%                 obj.set_color(ind,'teal');
                %detect hitmap overlap with players-----------------------------------------------
                obj.resolve_attacks();
                
                if obj.game_over
                    disp('game_over');
                    return
                end
                if obj.human_ind
                    if ~isempty(obj.display)
                        imagesc(obj.player_list(obj.human_ind).screen,'Parent',obj.display.game_panel);
                    else
                          [row col] = obj.player_list(obj.human_ind).position{:};
                          side = floor(obj.winsize/2);
                            ind = {row-side:row+side ;col-side:col+side};
                          imagesc(cat(3,obj.mapR(ind{:}),obj.mapG(ind{:}),obj.mapB(ind{:})));
                    end
                else
                    imagesc(cat(3,obj.mapR,obj.mapG,obj.mapB));
                end
                
                t = toc; %t~.013!
                if 1/obj.framerate-t < 0
                    disp('++++++++++++++++++++++++++++++++++++++++theres slowdown :-(');
                end
                pause(1/obj.framerate-t);
            end
            
        end
        function animate_missiles(obj)
            temp_list = [obj.missile_list];%use this or seg faults ensue
            if ~isempty(temp_list)
                [temp_list.prev_row] = temp_list.row;
                [temp_list.prev_col] = temp_list.col;
                [temp_list.speed] = temp_list.speed;%accel
                dur = num2cell([temp_list.duration]' - 1);
                [temp_list.duration] = dur{:};
                [temp_list(~[temp_list.duration])] = [];
                if ~isempty(temp_list)
                    headings = vertcat(temp_list.heading);
                    rows = num2cell([temp_list.row]'+[temp_list.speed]'.*headings(:,1));
                    [temp_list.row] = rows{:};
                    cols = num2cell([temp_list.col]'+[temp_list.speed]'.*headings(:,2));
                    [temp_list.col] = cols{:};
                    
                    [temp_list(([temp_list.row] == [temp_list.prev_row]) & ([temp_list.col] == [temp_list.prev_col]))] = [];
                    if ~isempty(temp_list)
                        [temp_list([temp_list.col] <= floor(obj.winsize/2))] = [];
                    end
                    if ~isempty(temp_list)
                        [temp_list([temp_list.row] <= floor(obj.winsize/2))] = [];
                    end
                    if ~isempty(temp_list)
                        [temp_list([temp_list.col] > obj.map_size(2)-floor(obj.winsize/2))] = [];
                    end
                    if ~isempty(temp_list)
                        [temp_list([temp_list.row] > obj.map_size(1)-floor(obj.winsize/2))] = [];
                    end
                    %                     if ~isempty(temp_list)
                    %                         temp = obj.tempmap(:,:,3);
                    %                         temp(sub2ind(obj.map_size,[temp_list.row],[temp_list.col])) = 1;
                    %                         obj.tempmap(:,:,3) = temp;
                    %                     end
                end
            end
            [obj.missile_list] = temp_list;
            %draw lines where missiles have moved--------------------------
            if ~isempty(obj.missile_list)
                for t=1:obj.numteams
                    valid_missiles = obj.missile_list([obj.missile_list.team] == t);
                    if ~isempty(valid_missiles)
                        for i=1:length(valid_missiles)
                            r = valid_missiles(i).row;
                            c = valid_missiles(i).col;
                            prev_r = valid_missiles(i).prev_row;
                            prev_c = valid_missiles(i).prev_col;
                            [x y] = bresenham(prev_c,prev_r,c,r);
                            ind = sub2ind(obj.map_size,y,x);
                            obj.hitmap(t).id(ind) = valid_missiles(i).owner;
                            obj.hitmap(t).effect(ind) = valid_missiles(i).effect;
                            cind = false(obj.map_size);
                            cind(ind) = 1;
                            if t == 2
                                obj.set_color(cind,'teal');
                            else
                                obj.set_color(cind,'purple');
                            end
                                
                        end
                    end
                end
            end
        end
        function keyrelease(obj,varargin)
            %updates global variables to indicate key releases
            key = get(gcbf,'CurrentKey');
            obj.dxnkey(strcmp(obj.dxnkey,key)) = [];
        end
        function keypress(obj,varargin)
            %updates global variables to indicate button status
            key = get(gcbf,'CurrentKey');
            if find(strcmp(key,obj.dxnkey))
                %do nothing
            else
                obj.dxnkey=[obj.dxnkey {key}];
            end;
        end
        function resolve_attacks(obj)
            %only handles collisions with non-environmental objects (i.e. hitmap)
            %environment collisions (e.g. edge of map, boulders, etc.)
            %handled at time of action
            
            dead = zeros(size(obj.player_list));
            for i=1:length(obj.player_list)
                player = obj.player_list(i);
                %               hits = sum(find(player.screen(find(player.shape))));
                [mapr mapc] = player.map_shape_ind;
                overlap = obj.hitmap(player.team).id(sub2ind(obj.map_size,mapr,mapc));
                
                hits = sum(overlap > 0);
                if hits > 0
                    
                    if ~player.champion.mitigate(overlap,hits,obj)
                        atkr_ids = unique(overlap);
                        atkr_ids = atkr_ids(atkr_ids > 0);
                        for a = 1:length(atkr_ids)
                            disp(['player' num2str(atkr_ids(a)) ' hit player' num2str(player.id) ' for ' num2str(hits) ' damage!']);
                        end
                        %                     [r c] = find(player.shape);
                        %                     player.screen(r,c,2)=1;
                        [mapr mapc] = player.map_shape_ind;
                        obj.tempmap(mapr,mapc,2) = 1;
                        player.cur_health = player.cur_health - 1;
                        %                     disp(player.cur_health);
                    end
                    [effects ind junk] = unique(obj.hitmap(player.team).effect(sub2ind(obj.map_size,mapr,mapc)));
                    for e=1:length(effects)
                        switch effects(e)
                            case 1 %slow
                            case 2 %snare
                            case 3 %stun
                            case 4 %taunt
                                disp('taunted!');
                                duration = obj.hitmap(player.team).duration(sub2ind(obj.map_size,mapr,mapc));
                                player.taunted = [overlap(ind(e)) duration(ind(e))];
                        end
                    end
                end
                if player.cur_health <= 0
                    dead(i) = 1;
                end
            end
            if find(dead)
                obj.player_list(logical(dead)) = [];
                if isempty(obj.player_list)
                    disp('everyones dead...');
                    obj.game_over = true;
                    return
                end
                obj.human_ind = find([obj.player_list.human]);
                if isempty(obj.human_ind)
                    disp('team 2 wins! humans suck!');
                    obj.game_over = true;
                end
                if isempty(obj.player_list([obj.player_list.team] == 2))
                    disp('team 1 wins! humans rule!');
                    obj.game_over = true;
                end
                if isempty(obj.player_list([obj.player_list.team] == 1))
                    disp('team 2 wins! humans suck!');
                    obj.game_over = true;
                end
            end
        end
    end
    methods
        function obj = top_lane_game(use_human,use_turns,num_bots,disp_handle)
            if exist('disp_handle','var')
                obj.display = disp_handle;
            end
            obj.turn_based = use_turns;
            obj.map = make_top_lane();
            obj.map = logical(padarray(obj.map,[floor(obj.winsize/2) floor(obj.winsize/2)],1));
            temp = obj.map(:,:,2);
            temp(obj.map(:,:,1)) = 0;
            obj.map(:,:,2) = temp;
            obj.map_size = size(obj.map(:,:,1));
            obj.permhitmap = struct('id',zeros(obj.map_size),'effect',zeros(obj.map_size),'duration',zeros(obj.map_size));
            obj.permhitmap = [obj.permhitmap obj.permhitmap];
            obj.tempmap = obj.map;
            obj.mob_list = [];
            for i=1:num_bots
                obj.player_list = [obj.player_list player('random',rammus())];
            end
            obj.missile_map = logical(zeros(size(obj.map(:,:,1))));
            obj.mob_map = logical(zeros(size(obj.map(:,:,1))));
            for i = 1:length(obj.player_list)
                obj.player_list(i).position = {25+i*5,160-25};
                obj.player_list(i).heading = [-1 0];
                obj.tempmap(obj.player_list(i).position{:},3) = 1;
                obj.player_list(i).team = mod(i,2)+1;
                obj.player_list(i).id = i;
                
                %                 obj.player_list(i).screen = obj.render_screen(obj.player_list(i));
                shapeside = 5;
                obj.player_list(i).shape = logical(padarray(ones(shapeside),[floor((obj.winsize-shapeside)/2) floor((obj.winsize-shapeside)/2)],0));
            end
            if use_human
                obj.player_list = [obj.player_list player('human',rammus())];
                obj.player_list(end).team = 1;
                obj.human_ind = length(obj.player_list);
                human = obj.player_list(obj.human_ind);
                human.id = obj.human_ind;
                human.position = {61,25};
                human.heading = [-1 0];
                obj.tempmap(human.position{:},3) = 1;
                %                 human.screen = obj.render_screen(human);
                shapeside = 5;
                human.shape = logical(padarray(ones(shapeside),[floor((obj.winsize-shapeside)/2) floor((obj.winsize-shapeside)/2)],0));
            else
                for i=1:2:length(obj.player_list)
                    obj.player_list(i).team = 2;
                end
            end
        end
        function play_game(obj)
            if obj.human_ind
                
                if ~isempty(obj.display)
                    h = obj.display.figure1;
                    imagesc(obj.player_list(obj.human_ind).screen,'Parent',obj.display.game_panel);
                else
                    h = figure;
                    imagesc(obj.player_list(obj.human_ind).screen);
                end
                set(h,'keypressfcn',@obj.keypress,'keyreleasefcn',@obj.keyrelease,'WindowButtonUpFcn','');
            end
            obj.game_loop();
        end
        function set_color(obj,ind,color,overwrite,sub)
            if nargin < 4
                overwrite = true;
            end
            if nargin < 5
                sub = false;
            end
            if isa(color,'char')
                switch color
                    case 'red'
                        rgb = [1 0 0];
                    case 'green'
                        rgb = [0 1 0];
                    case 'blue'
                        rgb = [0 0 1];
                    case 'purple'
                        rgb = [0.5451 0 0.5451];
                    case 'teal'
                        rgb = [0 .5020 .5020];
                    case 'grey'
                        rgb = [0.4118 0.4118 0.4118];
                end
            else
                rgb = color;
            end
            if overwrite
                obj.mapR(ind) = rgb(1);
                obj.mapG(ind) = rgb(2);
                obj.mapB(ind) = rgb(3);
            else
                obj.mapR(ind) = min(1,rgb(1) +  obj.mapR(ind));
                obj.mapG(ind) = min(1,rgb(2) + obj.mapG(ind));
                obj.mapB(ind) = min(1,rgb(3) + obj.mapB(ind));
            end
%                 obj.dispmap(rows,cols,1) = rgb(1);
%                 obj.dispmap(rows,cols,2) = rgb(2);
%                 obj.dispmap(rows,cols,3) = rgb(3);
        end
    end
end