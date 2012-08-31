classdef player < handle
    properties
        screen;
        shape;
        hit_map;
        
        id;
        team;
        score;
        cur_health;
        position;
        heading;
        
        max_health;
        mana;
        stunned = false;
        snared = false;
        slowed = 0;
        taunted = 0;
        speed = 1;
        
        champion;
        type;
        human;
        
        mapr;
        mapc;
    end
    methods
        function obj = player(type,champ)
            if exist('champ','var')
                obj.champion = champ;
            else
                obj.champion = nigglet();
            end
            obj.type = type;
            obj.human = false;
            switch obj.type
                case 'human'
                    obj.max_health = 100;
                    obj.human = true;
                case 'random'
                    obj.max_health = randi(100);
                case 'tdbp'
                case 'ferl'
            end
%             obj.max_health = 10000;%for debugging
            obj.cur_health = obj.max_health;
        end
        function [mapr mapc] = map_shape_ind(obj)
            [r c] = find(obj.shape);
            r = r -21;
            c = c -21;
            mapr = r + obj.position{1};
            mapc = c + obj.position{2};
        end
        function action = choose_action(obj)
            switch obj.type
                case 'random'
                    numa = randi(2);
                    ind = randi(length(obj.champion.possible_actions),numa,1);
                    action = obj.champion.possible_actions(ind);
            end
        end
        function val = get.mapr(obj)
            [r c] = find(obj.shape);
            r = r -21;
            val = r + obj.position{1};
        end
        function val = get.mapc(obj)
            [r c] = find(obj.shape);
            c = c -21;
            val = c + obj.position{2};
        end
        function bound_check_and_move(obj,objmap)
           
%             heading = [0 0];
%             for j=1:length(obj.heading)
%                 switch obj.heading{j}
%                     case 'w'
%                         heading = heading - [1 0];
%                     case 'a'
%                         heading = heading - [0 1];
%                     case 's'
%                         heading = heading + [1 0];
%                     case 'd'
%                         heading = heading + [0 1];
%                 end
%             end
%             disp(heading)
            moves = obj.speed;
            while moves
                r = obj.mapr;
                c = obj.mapc;
                if obj.heading(1) ~= 0
                    if find(objmap(r+obj.heading(1),c) > 0,1)
                        
                    else
                        obj.position{1} = obj.position{1} + obj.heading(1);
                    end
                end
                if obj.heading(2) ~= 0
                    if find(objmap(r,c+obj.heading(2)) > 0,1)
                    
                    else
                        obj.position{2} = obj.position{2} + obj.heading(2);
                    end
                end
                moves = moves - 1;
            end
        end
    end
end