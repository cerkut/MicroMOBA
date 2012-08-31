classdef champion < handle
    properties (Abstract)
        possible_actions;
    end
    methods (Abstract)
        perform_action(obj,game,player,pick)
    end
    methods
        function TF = mitigate(obj,overlap,hits,game)
            TF = false;
        end
    end
    
end