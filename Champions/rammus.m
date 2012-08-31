classdef rammus < champion
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here
    properties
        possible_actions = {'uparrow' 'leftarrow' 'downarrow' 'rightarrow' 'q' 'w' 'e' 'r' 'f'};
        taunt_delay = 0;
        powerball_delay = 0;
        reflect_delay = 0;
        tremor_delay = 0;
        duration = 10;
        powerball = false;
        reflect = false;
    end
    methods
        function obj = rammus()
        end
        function TF = mitigate(obj,overlap,hits,game)%deals with hits taken, returns true if standard health reduction not wanted
            TF = false;
            if obj.reflect
                TF = true;
                atkr_ids = unique(overlap);
                atkr_ids = atkr_ids(atkr_ids > 0);
                disp(['player' num2str(atkr_ids') ' took reflected damage']);
                affected_players = game.player_list(ismember([game.player_list.id],atkr_ids));
                if ~isempty(affected_players)
                    tempcell = num2cell([affected_players.cur_health]' -1);
                    [affected_players.cur_health] = tempcell{:};
                end
            end
        end
        function perform_action(obj,game,player,pick)
            %reduce delays by 1 tick
            time_elapsed = 1/game.framerate;
            obj.tremor_delay = max(0,obj.tremor_delay -time_elapsed);
            obj.taunt_delay = max(0,obj.taunt_delay -time_elapsed);
            obj.powerball_delay = max(0,obj.powerball_delay -time_elapsed);
            obj.reflect_delay = max(0,obj.reflect_delay -time_elapsed);
            obj.duration = max(0,obj.duration -time_elapsed);
            
            if player.team == 1
                target_team = 2;
            else
                target_team = 1;
            end
            
            
            %perform actions-----------------------------------------------
            if ~obj.powerball
                player.speed = 0;
            end
            moving = false;
            prevheading = player.heading;
%             disp(pick);
            for i=1:length(pick)
                switch pick{i}
                    case 'uparrow'                        %     go up
                        if ~moving
                            player.speed = max(1,player.speed);
                            player.heading = [0 0];
                            moving = true;
                        end
                        player.heading(1) = -1;
                        
                    case 'downarrow'                        %     go down
                        if ~moving
                            player.speed = max(1,player.speed);
                            player.heading = [0 0];
                            moving = true;
                        end
                        player.heading(1) = 1;
                    case 'leftarrow'                        %     go left
                        if ~moving
                            player.speed = max(1,player.speed);
                            player.heading = [0 0];
                            moving = true;
                        end
                        player.heading(2) = -1;
                    case 'rightarrow'
                        if ~moving
                            player.speed = max(1,player.speed);
                            player.heading = [0 0];
                            moving = true;
                        end
                        player.heading(2) = 1;        %     go right
                    case 'space'
                        if ~obj.powerball
                            game.missile_list = [game.missile_list struct('effect',0,'owner',player.id,'duration',10,...
                                'team',target_team,'row',player.position{1},'col',player.position{2},...
                                'heading',prevheading,'speed',2,'prev_row',player.position{1},'prev_col',player.position{2})];
                        end
                    case 'q'
                        if obj.powerball_delay == 0 && ~obj.reflect
                            obj.powerball = true;
                            disp('powerball!');
                            obj.powerball_delay = 10;
                            obj.duration = 7;
                        end
                    case 'w'
                        if obj.reflect_delay == 0 && ~obj.powerball
                            obj.reflect = true;
                            disp('reflect damage!');
                            obj.reflect_delay = 14;
                            obj.duration = 6;
                        end
                    case 'e'
                        if obj.taunt_delay == 0
                            obj.taunt_delay = 12;
                            [r c] = player.position{:};
                            %square of size x around pos given by:
                            %ceil(x/2)+r,ceil(x/2)+c
                            game.hitmap(target_team).id((-4:4)+r,(-4:4)+c) = player.id;
                            game.hitmap(target_team).effect((-4:4)+r,(-4:4)+c) = 4; %4 = taunt effect
                            game.hitmap(target_team).duration((-4:4)+r,(-4:4)+c) = 3; %length of taunt
                            ind = false(game.map_size);
                            ind((-4:4)+r,(-4:4)+c) =1;
                            game.set_color(ind,[1 1 1]);
                        end
                    case 'r'
                        if obj.tremor_delay == 0
                            obj.tremor = true;
                            disp('tremor!');
                            obj.tremor_delay = 60;
                            obj.duration = 8;
                        end
                end
            end
            player.bound_check_and_move(game.tempmap(:,:,1));
            
            %update currently active effects-------------------------------
            [r c] = player.position{:};
            if obj.powerball                
                game.hitmap(target_team).id((-3:3)+r,(-3:3)+c) = player.id;
                player.speed = min(ceil((30 - obj.duration)/3),5);
                if ~obj.duration
                    disp('powerball off');
                    obj.powerball = false;
                end
                ind = false(game.map_size);
                ind((-3:3)+r,(-3:3)+c) =1;
                game.set_color(ind,[1-obj.duration/30 (1-obj.duration/30)/2 obj.duration/30],false);
            end
            if obj.reflect
                if ~obj.duration
                    disp('reflect off');
                    obj.reflect = false;
                end
                ind = false(game.map_size);
                if mod(game.frameno,2)
                    ind((-3:2:3)+r,(-3:3)+c) =1;
                else
                    ind((-3:3)+r,(-3:2:3)+c) =1;
                end
                game.set_color(ind,[.8 .8 .8]);
            end
            if obj.tremor
                %tremor 1 per second
                game.hitmap(target_team).id((-5:3)+r,(-5:3)+c) = player.id;
                player.speed = min(ceil((30 - obj.duration)/3),5);
                if ~obj.duration
                    disp('powerball off');
                    obj.powerball = false;
                end
                ind = false(game.map_size);
                ind((-3:3)+r,(-3:3)+c) =1;
                game.set_color(ind,[1-obj.duration/30 (1-obj.duration/30)/2 obj.duration/30],false);
            end
            
        end
        
    end
    
    
end

