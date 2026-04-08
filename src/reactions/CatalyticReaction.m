classdef CatalyticReaction < Reaction
    % CATALYTICREACTION Catalytic reaction: => A
    %
    % Implements enzyme-catalyzed synthesis of a product
    % Catalyst (enzyme) concentration-dependent
    %
    % Reaction form: => A
    % Rate equation: vf = kcat_A_CATALYST * CATALYST
    %
    % Parameters:
    %   kcat_A_CATALYST       - Catalytic rate constant
    %
    % Example:
    %   dataArray = {'CAT', 'A', 'CATALYST'};
    %   reaction = CatalyticReaction('R1', dataArray);

    methods
        function obj = CatalyticReaction(reactionID, dataArray)
            % Constructor
            % Inputs:
            %   reactionID  - Reaction identifier (e.g., 'R1')
            %   dataArray   - Cell array with reaction data

            % Call superclass constructor
            obj@Reaction('CAT', reactionID);

            % Parse and validate input data
            if nargin >= 2
                obj.parseData(dataArray);
                obj.build();
            end
        end

        function parseData(obj, dataArray)
            % Parse reaction data array
            % Expected format: ['CAT', 'product', 'catalyst']

            % Extract character elements only
            charData = dataArray(cellfun(@ischar, dataArray));

            % Validate exactly 3 elements required
            if length(charData) ~= 3
                error('Reaction:SyntaxError', ...
                    'Reaction syntax error (reaction number %d, type CAT): Expected exactly 3 elements, got %d', ...
                    str2double(obj.reactionID(2:end)), length(charData));
            end

            % Remove +/- markers
            species = erase(charData(1:3), {'+', '-'});

            % Set species (substrates: none; products: A; modifiers: CATALYST)
            obj.setSpecies({}, {species{2}}, {species{3}});

            % Set regulators (no activators or inhibitors for CAT)
            obj.setRegulators({}, {});
        end

        function procStr = getProcessString(obj)
            % Get IQM process string
            % Returns: "=>A:R1"
            procStr = sprintf('=>%s:%s', obj.products{1}, obj.reactionID);
        end

        function rateEq = generateRateEquation(obj)
            % Generate the catalytic rate equation
            % Returns: Rate equation string

            A = obj.products{1};
            CATALYST = obj.modifiers{1};

            % Rate equation: kcat_A_CATALYST * CATALYST
            baseParam = sprintf('kcat_%s_%s', A, CATALYST);
            rateEq = sprintf('vf = %s*%s', baseParam, CATALYST);
        end

        function params = getParameterNames(obj)
            % Get all parameter names for this reaction
            % Returns: Cell array of parameter names

            A = obj.products{1};
            CATALYST = obj.modifiers{1};

            % Catalytic rate constant
            params = {sprintf('kcat_%s_%s', A, CATALYST)};
        end
    end
end
