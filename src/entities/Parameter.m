classdef Parameter < handle
    % PARAMETER Represents a parameter in the biological model
    %
    % Properties:
    %   name          - Parameter name (e.g., 'ka_FGFR2_pFGFR2_FGF')
    %   value         - Numerical value
    %   defaultValue  - Default value from database
    %   units         - Units of measurement (optional)
    %   description   - Description of the parameter (optional)
    %   reactionType  - Which reaction type uses this parameter (optional)
    %
    % Example:
    %   p = Parameter('ka_FGFR2_pFGFR2_FGF', 0.01);
    %   p = Parameter('Km_AKT_pAKT', 100, 'nM', 'Michaelis constant');

    properties
        name char
        value double = 1.0
        defaultValue double = 1.0
        units char = ''
        description char = ''
        reactionType char = ''
    end

    methods
        function obj = Parameter(name, value, units, description, reactionType)
            % Constructor
            % Inputs:
            %   name          - Parameter name (required)
            %   value         - Numerical value (default: 1.0)
            %   units         - Units (default: '')
            %   description   - Description (default: '')
            %   reactionType  - Reaction type (default: '')

            if nargin < 1
                error('Parameter:InvalidInput', 'Parameter name is required');
            end

            obj.name = name;

            if nargin >= 2
                obj.value = value;
                obj.defaultValue = value;
            end

            if nargin >= 3
                obj.units = units;
            end

            if nargin >= 4
                obj.description = description;
            end

            if nargin >= 5
                obj.reactionType = reactionType;
            end
        end

        function setDefaultValue(obj, defaultValue)
            % Set default value for parameter
            obj.defaultValue = defaultValue;
            if obj.value == 1.0  % If value wasn't explicitly set
                obj.value = defaultValue;
            end
        end

        function isValid = validate(obj)
            % Validate the parameter
            % Returns: true if valid, false otherwise

            isValid = true;

            % Name must not be empty
            if isempty(obj.name)
                warning('Parameter:EmptyName', 'Parameter name cannot be empty');
                isValid = false;
            end

            % Value must be positive
            if obj.value <= 0
                warning('Parameter:NonPositiveValue', ...
                    'Parameter "%s" has non-positive value: %f', ...
                    obj.name, obj.value);
                isValid = false;
            end

            % Name should not contain special characters except underscore
            if ~isempty(regexp(obj.name, '[^a-zA-Z0-9_]', 'once'))
                warning('Parameter:InvalidName', ...
                    'Parameter name "%s" contains invalid characters', obj.name);
                isValid = false;
            end
        end

        function str = toString(obj)
            % Convert to string representation
            if ~isempty(obj.units)
                str = sprintf('%s = %g %s', obj.name, obj.value, obj.units);
            else
                str = sprintf('%s = %g', obj.name, obj.value);
            end
        end

        function disp(obj)
            % Display method
            fprintf('Parameter: %s\n', obj.toString());
            if ~isempty(obj.description)
                fprintf('  Description: %s\n', obj.description);
            end
            if ~isempty(obj.reactionType)
                fprintf('  Reaction Type: %s\n', obj.reactionType);
            end
        end
    end
end
