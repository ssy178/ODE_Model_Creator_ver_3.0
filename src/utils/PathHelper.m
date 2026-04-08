classdef PathHelper
    % PATHHELPER Utility functions for path manipulation
    %
    % This class provides static utility methods for working with file paths
    % in a platform-independent manner.
    %
    % Methods:
    %   isAbsolutePath(path) - Check if path is absolute
    %   ensureAbsolutePath(path, basePath) - Convert to absolute if needed
    %   getProjectRoot() - Get project root directory
    %   joinPaths(varargin) - Join path components safely
    %
    % Example:
    %   if PathHelper.isAbsolutePath('C:\temp\file.txt')
    %       disp('Absolute path');
    %   end

    methods (Static)
        function isAbs = isAbsolutePath(path)
            % Check if a path is absolute
            % Input: path - Path string to check
            % Returns: true if absolute, false if relative
            %
            % Examples:
            %   isAbsolutePath('C:\temp\file.txt')  -> true  (Windows)
            %   isAbsolutePath('/usr/local/file')   -> true  (Unix/Mac)
            %   isAbsolutePath('relative/path.txt') -> false

            if isempty(path)
                isAbs = false;
                return;
            end

            % Convert to string if needed
            if ~ischar(path) && ~isstring(path)
                isAbs = false;
                return;
            end

            path = char(path);

            % Windows absolute path: starts with drive letter (C:\, D:\, etc.)
            % or UNC path (\\server\share)
            if ispc
                % Check for drive letter (e.g., C:\)
                if length(path) >= 3 && path(2) == ':' && (path(3) == '\' || path(3) == '/')
                    isAbs = true;
                    return;
                end
                % Check for UNC path (\\server\share)
                if length(path) >= 2 && path(1) == '\' && path(2) == '\'
                    isAbs = true;
                    return;
                end
            end

            % Unix/Mac absolute path: starts with /
            if path(1) == '/' || path(1) == '\'
                isAbs = true;
                return;
            end

            % If none of above, it's relative
            isAbs = false;
        end

        function absPath = ensureAbsolutePath(path, basePath)
            % Convert path to absolute if it's relative
            % Inputs:
            %   path     - Path to convert
            %   basePath - Base directory for relative paths (optional, default: pwd)
            % Returns: Absolute path
            %
            % Example:
            %   absPath = PathHelper.ensureAbsolutePath('output/model.txt', 'C:\project')

            if nargin < 2
                basePath = pwd;
            end

            if PathHelper.isAbsolutePath(path)
                absPath = path;
            else
                absPath = fullfile(basePath, path);
            end
        end

        function rootPath = getProjectRoot()
            % Get the project root directory
            % Returns: Path to ODEModelCreator root directory
            %
            % This function finds the project root by looking for the 'src' directory

            % Get the directory where this file is located
            thisFile = mfilename('fullpath');
            thisDir = fileparts(thisFile);

            % Navigate up to project root (from src/utils/ to root)
            rootPath = fullfile(thisDir, '..', '..');
            rootPath = PathHelper.normalizePath(rootPath);
        end

        function normalizedPath = normalizePath(path)
            % Normalize a path by resolving .. and . components
            % Input: path - Path to normalize
            % Returns: Normalized absolute path
            %
            % Example:
            %   normalizePath('C:\temp\..\data') -> 'C:\data'

            % Get full absolute path
            if PathHelper.isAbsolutePath(path)
                fullPath = path;
            else
                fullPath = fullfile(pwd, path);
            end

            % Use MATLAB's built-in to resolve . and .. components
            % Create a java.io.File object to get canonical path
            try
                javaFile = java.io.File(fullPath);
                normalizedPath = char(javaFile.getCanonicalPath());
            catch
                % Fallback if Java method fails
                normalizedPath = fullPath;
            end
        end

        function joined = joinPaths(varargin)
            % Join multiple path components safely
            % Input: varargin - Path components to join
            % Returns: Joined path
            %
            % Example:
            %   joinPaths('C:\temp', 'data', 'file.txt') -> 'C:\temp\data\file.txt'

            if nargin == 0
                joined = '';
                return;
            end

            % Use fullfile for platform-independent path joining
            joined = fullfile(varargin{:});
        end

        function exists = fileExists(path)
            % Check if a file exists
            % Input: path - File path to check
            % Returns: true if file exists, false otherwise

            exists = exist(path, 'file') == 2;
        end

        function exists = dirExists(path)
            % Check if a directory exists
            % Input: path - Directory path to check
            % Returns: true if directory exists, false otherwise

            exists = exist(path, 'dir') == 7;
        end

        function ensureDir(path)
            % Create directory if it doesn't exist
            % Input: path - Directory path to create

            if ~PathHelper.dirExists(path)
                mkdir(path);
            end
        end

        function [dirPath, fileName, ext] = splitPath(path)
            % Split a path into directory, filename, and extension
            % Input: path - Full file path
            % Returns:
            %   dirPath  - Directory path
            %   fileName - Filename without extension
            %   ext      - File extension (including '.')
            %
            % Example:
            %   [dir, name, ext] = splitPath('C:\temp\file.txt')
            %   dir = 'C:\temp', name = 'file', ext = '.txt'

            [dirPath, fileName, ext] = fileparts(path);
        end

        function relativePath = getRelativePath(targetPath, basePath)
            % Get relative path from basePath to targetPath
            % Inputs:
            %   targetPath - Target file/directory
            %   basePath   - Base directory (default: pwd)
            % Returns: Relative path
            %
            % Example:
            %   getRelativePath('C:\project\data\file.txt', 'C:\project')
            %   -> 'data\file.txt'

            if nargin < 2
                basePath = pwd;
            end

            % Normalize both paths
            targetPath = PathHelper.normalizePath(targetPath);
            basePath = PathHelper.normalizePath(basePath);

            % Try to compute relative path
            try
                % Split paths into components
                targetParts = strsplit(targetPath, filesep);
                baseParts = strsplit(basePath, filesep);

                % Find common prefix
                commonLength = 0;
                for i = 1:min(length(targetParts), length(baseParts))
                    if strcmpi(targetParts{i}, baseParts{i})
                        commonLength = i;
                    else
                        break;
                    end
                end

                % Build relative path
                upLevels = length(baseParts) - commonLength;
                relativeParts = [repmat({'..'}, 1, upLevels), targetParts(commonLength+1:end)];

                if isempty(relativeParts)
                    relativePath = '.';
                else
                    relativePath = fullfile(relativeParts{:});
                end
            catch
                % If relative path computation fails, return target path
                relativePath = targetPath;
            end
        end
    end
end
