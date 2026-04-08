classdef (Abstract) Reaction < handle
    % REACTION Abstract base class for all reaction types
    %
    % This class defines the interface that all concrete reaction types must implement.
    % Each reaction generates:
    %   - Rate equation string (mathematical expression)
    %   - Parameter names and default values
    %   - Species involved in the reaction
    %
    % Concrete subclasses must implement:
    %   - generateRateEquation() - Creates the mathematical rate equation
    %   - getParameterNames() - Returns all parameters used
    %
    % Properties:
    %   type        - Reaction type code (e.g., 'MA', 'ASSO', 'MMS')
    %   reactionID  - Unique reaction identifier (e.g., 'R1', 'R2')
    %   substrates  - Cell array of substrate species names
    %   products    - Cell array of product species names
    %   modifiers   - Cell array of modifier species (enzyme, etc.)
    %   activators  - Cell array of activator names
    %   inhibitors  - Cell array of inhibitor names
    %   rateEquation - String representation of rate equation
    %   parameters  - Cell array of parameter names

    properties
        type char
        reactionID char
        substrates cell = {}
        products cell = {}
        modifiers cell = {}
        activators cell = {}
        inhibitors cell = {}
        rateEquation char = ''
        parameters cell = {}
    end

    methods
        function obj = Reaction(type, reactionID)
            % Constructor
            % Inputs:
            %   type        - Reaction type code
            %   reactionID  - Reaction identifier
            if nargin >= 1
                obj.type = type;
            end
            if nargin >= 2
                obj.reactionID = reactionID;
            end
        end

        function setSpecies(obj, substrates, products, modifiers)
            % Set species involved in reaction
            % Inputs:
            %   substrates - Cell array of substrate names
            %   products   - Cell array of product names
            %   modifiers  - Cell array of modifier names (optional)

            if ~iscell(substrates), substrates = {substrates}; end
            if ~iscell(products), products = {products}; end

            obj.substrates = substrates;
            obj.products = products;

            if nargin >= 4
                if ~iscell(modifiers), modifiers = {modifiers}; end
                obj.modifiers = modifiers;
            end
        end

        function setRegulators(obj, activators, inhibitors)
            % Set regulators (activators and inhibitors)
            % Inputs:
            %   activators - Cell array of activator names
            %   inhibitors - Cell array of inhibitor names

            if nargin >= 2 && ~isempty(activators)
                if ~iscell(activators), activators = {activators}; end
                obj.activators = activators;
            end

            if nargin >= 3 && ~isempty(inhibitors)
                if ~iscell(inhibitors), inhibitors = {inhibitors}; end
                obj.inhibitors = inhibitors;
            end
        end

        function build(obj)
            % Build the reaction (generate rate equation and parameters)
            obj.rateEquation = obj.generateRateEquation();
            obj.parameters = obj.getParameterNames();
        end

        function species = getAllSpecies(obj)
            % Get all species involved in this reaction
            % Returns: Cell array of unique species names
            species = unique([obj.substrates, obj.products, obj.modifiers]);
        end

        function procStr = getProcessString(obj)
            % Get IQM process string (reaction equation)
            % Must be implemented by subclass or use default implementation
            % Returns: String like "A+B=>C:R1"
            error('Reaction:NotImplemented', ...
                'Subclass must implement getProcessString() or call superclass default');
        end

        function isValid = validate(obj)
            % Validate the reaction structure
            % Returns: true if valid, false otherwise

            isValid = true;

            % Must have at least one substrate (unless it's a Synthesis reaction)
            isSynthesis = any(strcmp(obj.type, {'SYN0', 'SYNF', 'SYNS', 'SYS0', 'SYN_SYNS'}));
            if isempty(obj.substrates) && ~isSynthesis
                warning('Reaction:NoSubstrates', ...
                    'Reaction %s [%s] has no substrates', obj.reactionID, obj.type);
                isValid = false;
            end

            % Must have at least one product (unless it's a Degradation reaction)
            isDegradation = any(strcmp(obj.type, {'DEG0', 'DEGF', 'DEGS'}));
            if isempty(obj.products) && ~isDegradation
                warning('Reaction:NoProducts', ...
                    'Reaction %s [%s] has no products', obj.reactionID, obj.type);
                isValid = false;
            end

            % Rate equation must not be empty
            if isempty(obj.rateEquation)
                warning('Reaction:NoRateEquation', ...
                    'Reaction %s has no rate equation', obj.reactionID);
                isValid = false;
            end

            % Must have parameters
            if isempty(obj.parameters)
                warning('Reaction:NoParameters', ...
                    'Reaction %s has no parameters', obj.reactionID);
                isValid = false;
            end
        end

        function str = toString(obj)
            % Convert to string representation
            str = sprintf('%s: %s', obj.reactionID, obj.getProcessString());
        end

        function disp(obj)
            % Display method
            fprintf('Reaction %s [%s]\n', obj.reactionID, obj.type);
            fprintf('  Process: %s\n', obj.getProcessString());
            fprintf('  Rate Eq: %s\n', obj.rateEquation);
            fprintf('  Parameters (%d): %s\n', length(obj.parameters), ...
                strjoin(obj.parameters, ', '));
            if ~isempty(obj.activators)
                fprintf('  Activators: %s\n', strjoin(obj.activators, ', '));
            end
            if ~isempty(obj.inhibitors)
                fprintf('  Inhibitors: %s\n', strjoin(obj.inhibitors, ', '));
            end
        end
    end

    methods (Abstract)
        % Generate the mathematical rate equation string
        % Returns: String representation of rate equation
        rateEq = generateRateEquation(obj)

        % Get all parameter names used by this reaction
        % Returns: Cell array of parameter names
        params = getParameterNames(obj)
    end

    methods (Static)
        function [species, activators, inhibitors] = parseReactionData(dataArray)
            % Helper method to parse reaction data array
            % Input: Cell array with format ['TYPE', 'substrate1', 'substrate2', '+activator', '-inhibitor', ...]
            % Returns:
            %   species    - Cell array of base species (first 4 elements without +/-)
            %   activators - Cell array of activator names (elements starting with +)
            %   inhibitors - Cell array of inhibitor names (elements starting with -)

            % Extract first 4 elements as species (remove +/- markers)
            numBaseElements = min(4, length(dataArray));
            species = erase(dataArray(1:numBaseElements), {'+', '-'});

            % Extract activators (contain '+') and remove the '+' marker
            activatorMask = contains(dataArray, '+');
            activators = erase(dataArray(activatorMask), '+');

            % Extract inhibitors (contain '-') and remove the '-' marker
            inhibitorMask = contains(dataArray, '-');
            inhibitors = erase(dataArray(inhibitorMask), '-');
        end

        function validateMinimumElements(dataArray, minRequired, reactionType, reactionNum)
            % Validate that data array has minimum required elements
            if length(dataArray) < minRequired
                error('Reaction:SyntaxError', ...
                    'Reaction syntax error (reaction number %d, type %s): Expected at least %d elements, got %d', ...
                    reactionNum, reactionType, minRequired, length(dataArray));
            end
        end
    end
end
