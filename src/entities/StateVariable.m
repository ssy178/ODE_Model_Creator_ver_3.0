classdef StateVariable < handle
    % STATEVARIABLE Represents a state variable in the biological model
    %
    % Properties:
    %   name          - Variable name (e.g., 'FGFR2', 'pFGFR2')
    %   initialValue  - Initial concentration/amount (default: 0)
    %   units         - Units of measurement (optional)
    %   description   - Description of the variable (optional)
    %
    % Example:
    %   sv = StateVariable('FGFR2');
    %   sv = StateVariable('pFGFR2', 10);
    %   sv = StateVariable('FGFR2', 0, 'nM', 'FGF Receptor 2');

    properties
        name char
        initialValue double = 0
        units char = ''
        description char = ''
    end

    methods
        function obj = StateVariable(name, initialValue, units, description)
            % Constructor
            % Inputs:
            %   name          - Variable name (required)
            %   initialValue  - Initial value (default: 0)
            %   units         - Units (default: '')
            %   description   - Description (default: '')

            if nargin < 1
                error('StateVariable:InvalidInput', 'Variable name is required');
            end

            obj.name = name;

            if nargin >= 2
                obj.initialValue = initialValue;
            end

            if nargin >= 3
                obj.units = units;
            end

            if nargin >= 4
                obj.description = description;
            end
        end

        function isValid = validate(obj)
            % Validate the state variable
            % Returns: true if valid, false otherwise

            isValid = true;

            % Name must not be empty
            if isempty(obj.name)
                warning('StateVariable:EmptyName', 'State variable name cannot be empty');
                isValid = false;
            end

            % Initial value must be non-negative
            if obj.initialValue < 0
                warning('StateVariable:NegativeValue', ...
                    'State variable "%s" has negative initial value: %f', ...
                    obj.name, obj.initialValue);
                isValid = false;
            end

            % Name should not contain special characters except underscore
            if ~isempty(regexp(obj.name, '[^a-zA-Z0-9_]', 'once'))
                warning('StateVariable:InvalidName', ...
                    'State variable name "%s" contains invalid characters', obj.name);
                isValid = false;
            end
        end

        function str = toString(obj)
            % Convert to string representation
            if ~isempty(obj.units)
                str = sprintf('%s = %g %s', obj.name, obj.initialValue, obj.units);
            else
                str = sprintf('%s = %g', obj.name, obj.initialValue);
            end
        end

        function disp(obj)
            % Display method
            fprintf('StateVariable: %s\n', obj.toString());
            if ~isempty(obj.description)
                fprintf('  Description: %s\n', obj.description);
            end
        end
    end
end
