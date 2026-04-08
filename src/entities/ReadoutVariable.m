classdef ReadoutVariable < handle
    % READOUTVARIABLE Represents a complex observable variable in the biological model
    %
    % Properties:
    %   name        - Readout variable name (e.g., 'Total_AKT')
    %   components  - Cell array of component variable names
    %
    % Example:
    %   readout = ReadoutVariable('Total_AKT', {'AKT', 'pAKT', 'aAKT'});
    %   eqStr = readout.getIQMEquation();
    %   % Returns: "Total_AKT = AKT + pAKT + aAKT"

    properties
        name char
        components cell = {}
    end

    methods
        function obj = ReadoutVariable(name, components)
            % Constructor
            % Inputs:
            %   name        - Readout variable name (required)
            %   components  - Cell array of component names (required)

            if nargin < 1
                error('ReadoutVariable:InvalidInput', 'Variable name is required');
            end

            if nargin < 2
                error('ReadoutVariable:InvalidInput', 'Components are required');
            end

            obj.name = name;

            % Ensure components is a cell array
            if ~iscell(components)
                components = {components};
            end

            obj.components = components;
        end

        function eqStr = getIQMEquation(obj)
            % Generate IQM equation string for this readout variable
            % Returns: String like "Total_AKT = AKT + pAKT + aAKT"

            if isempty(obj.components)
                eqStr = sprintf('%s = 0', obj.name);
                return;
            end

            % Join components with ' + '
            componentStr = strjoin(obj.components, ' + ');
            eqStr = sprintf('%s = %s', obj.name, componentStr);
        end

        function addComponent(obj, component)
            % Add a component to the readout variable
            obj.components{end+1} = component;
        end

        function removeComponent(obj, component)
            % Remove a component from the readout variable
            obj.components = obj.components(~strcmp(obj.components, component));
        end

        function isValid = validate(obj)
            % Validate the readout variable
            % Returns: true if valid, false otherwise

            isValid = true;

            % Name must not be empty
            if isempty(obj.name)
                warning('ReadoutVariable:EmptyName', 'Readout variable name cannot be empty');
                isValid = false;
            end

            % Must have at least one component
            if isempty(obj.components)
                warning('ReadoutVariable:NoComponents', ...
                    'Readout variable "%s" has no components', obj.name);
                isValid = false;
            end

            % All components must be non-empty strings
            for i = 1:length(obj.components)
                if ~ischar(obj.components{i}) || isempty(obj.components{i})
                    warning('ReadoutVariable:InvalidComponent', ...
                        'Readout variable "%s" has invalid component at position %d', ...
                        obj.name, i);
                    isValid = false;
                end
            end
        end

        function str = toString(obj)
            % Convert to string representation
            str = obj.getIQMEquation();
        end

        function disp(obj)
            % Display method
            fprintf('ReadoutVariable: %s\n', obj.toString());
            fprintf('  Components (%d): ', length(obj.components));
            fprintf('%s ', obj.components{:});
            fprintf('\n');
        end
    end
end
