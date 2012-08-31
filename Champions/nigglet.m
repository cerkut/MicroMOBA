classdef nigglet < champion
    properties
        possible_actions = {'w' 'a' 's' 'd' 'k' 'space'};
        delay;
    end
    
    methods
        function obj = nigglet()
            obj.delay = 0;
        end
        
%         function val = get.possible_actions(obj)
%             if obj.delay < 0
%                 val = {'w' 'a' 's' 'd' 'k'};
%             else
%                 val = {'w' 'a' 's' 'd'};
%             end
%             
%         end
        function perform_action(obj,game,player,pick)
            if obj.delay > 0
                obj.delay = obj.delay -1;
            end
            if player.team == 1
                target_team = 2;
            else
                target_team = 1;
            end
            oldpos = player.position;
            heading = player.heading;
            
            [prevy prevx] = oldpos{:};
            [cury curx] = oldpos{:};
            %             pick = [pick heading];
            %             disp(pick)
            i = 0;
            if find(strcmp(pick,'space'))
                speed = 2;
                pick(strcmp(pick,'space')) = [];
%                 disp('yay');
            else
                speed = 1;
            end
            while i<length(pick) %TO DO: translate heading to (row,col) changes, then save those instead
                i = i+1;
                switch pick{i}
                    case 'w'
                        %     go up
                        cury = cury-speed;
                    case 's'
                        %     go down
                        cury = cury+speed;
                    case 'a'
                        %     go left
                        curx = curx-speed;
                    case 'd'
                        %     go right
                        curx = curx+speed;
                    case 'k'
%                         disp('yup');
                        if obj.delay == 0
                        obj.delay = 30;

                        game.missile_list = [game.missile_list struct('effect',0,'owner',player.id,'duration',10,'team',target_team,'row',prevy,'col',prevx,'heading',{heading},'speed',2,'prev_row',prevy,'prev_col',prevx)];
                        end
                        
                    otherwise
                        disp(pick(i));
                end
%                 pick = pick(2:end);
            end
            %detect out of bounds------------------------------------------
            % if move ==1
            bonus_penalty = 0;
            penalty = 0;
            % end
            old_bonus = bonus_penalty;
            if curx <= floor(game.winsize/2)
                curx = floor(game.winsize/2)+1;
                bonus_penalty = bonus_penalty + 1;
            end
            if cury <= floor(game.winsize/2)
                cury = floor(game.winsize/2)+1;
                bonus_penalty = bonus_penalty + 1;
            end
            if curx > size(game.map,2)-floor(game.winsize/2)
                curx = size(game.map,2)-floor(game.winsize/2);
                bonus_penalty = bonus_penalty + 1;
            end
            if cury > size(game.map,1)-floor(game.winsize/2)
                cury = size(game.map,1)-floor(game.winsize/2);
                bonus_penalty = bonus_penalty + 1;
            end
            
            %---------------------------------------------hit detection----------------------------------
            pos = bound_check([prevy prevx],[cury curx],game.tempmap(:,:,1),player.shape);
            player.position = {pos(1) pos(2)};
%             if game.map(cury,prevx,1) > 0%CHANGE TO CHECK WHOLE SHAPE
%                 cury = prevy;
%                 bonus_penalty = bonus_penalty + 1;
%             end
%             if game.map(cury,curx,1) > 0
%                 curx = prevx;
%                 bonus_penalty = bonus_penalty + 1;
%             end
%             
% 
%             
%             if old_bonus == bonus_penalty && (size(game.map,1) - cury) >= (size(game.map,1) - prevy)
%                 bonus_penalty = 0;
%             else
%                 penalty = penalty + bonus_penalty;
%             end
%             player.position = {cury curx};

            pick(strcmp(pick,'k')) = [];
            if ~isempty(pick)
                player.heading = pick;
            end
        end
    end
end