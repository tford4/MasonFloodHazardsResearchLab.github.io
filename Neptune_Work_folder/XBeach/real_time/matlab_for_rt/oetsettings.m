function oetsettings(varargin)
%OETSETTINGS   enable the openearthtools matlab tools by adding all relevant matlab paths.
%
% openearthtools is a collection of open source tools intended to be licensed under the (<a href="http://www.gnu.org/licenses/licenses.html">GNU (Lesser) Public License</a>).
%
% In order to suppress this information, run the function with input argument quiet:
% "oetsettings('quiet');" or "oetsettings quiet"
%
% By default oetsettings generates a tutorial search database (only if no current database 
% or current database is outdated). Suppressed generation: "oetsettings(...,'searchdb',false);"
% 
% For more information on openearthtools refer to the following sources:
% * wiki:               <a href="http://OpenEarth.nl">OpenEarth.nl</a>, <a href="http://OpenEarth.nl">OpenEarth.eu</a>
% * 1. Subversion, data <a href="https://svn.oss.deltares.nl/repos/openearthrawdata/trunk/">https://svn.oss.deltares.nl/repos/openearthrawdata/trunk/matlab</a>
% *    ,,        models <a href="https://svn.oss.deltares.nl/repos/openearthmodels/trunk/">https://svn.oss.deltares.nl/repos/openearthmodels/trunk/matlab</a>
% *    ,,         tools <a href="https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab">https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab</a>
% * 2. OPeNDAP/netCDF   <a href="http://opendap.deltares.nl">http://opendap.deltares.nl</a>
% * 3. Google Earth     <a href="http://kml.deltares.nl">http://kml.deltares.nl</a>, opendap
% * Matlab: + Scroll through the openearthtools directories 
%           + use help     : help netcdf, help general, help applications
%           + use lookfor  : lookfor google, lookfor 
%           + use doc      : doc xbeach, doc swan
%           + use tutorials: doc tutorials, also on www.openearth.nl
%
%See also:    oetsettings: path, restoredefaultpath, addpathfast,
%          openearthtools: general, applications, io, tutorials
%              highlights: convertcoordinates, googleplot, opendap
% OET matlab coding style: oetnewfun, setproperty

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) <2004-2011> <Deltares>
%
%          <gerben.deboer@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.eu">openearthtools</a>.
% openearthtools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: oetsettings.m 7610 2012-10-31 15:35:56Z baart_f $
% $Date: 2012-10-31 16:35:56 +0100 (Wed, 31 Oct 2012) $
% $Author: baart_f $
% $Revision: 7610 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/oetsettings.m $
% $Keywords: $

%% Retrieve verbose state from input 

   OPT = struct(...
       'quiet',false,...
       'searchdb',true);
   nextarg   = 1;
   
   if mod(nargin,2)==1 % odd # arguments
       if strcmp(varargin{1},'quiet')
           OPT.quiet = true;
       else
           error(['unknown argument:',varargin{1}])
       end
       nextarg   = 2;
   end
   
   OPT = setproperty(OPT,varargin{nextarg:end});
   
%% Acknowledge user we started adding the toolbox

   if ~(OPT.quiet)
       disp('Adding <a href="http://OpenEarth.deltares.nl">openearthtools</a>, please wait ...')
       disp(' ')
   end
      
%% Collect warning and directory state

%    state.warning = warning;
   state.pwd     = cd;

%% Add paths

   basepath = fileparts(mfilename('fullpath'));
%    warning off
% keep the warning on
   addpathfast(basepath,'append',false); % excludes *.svn directories!

%% Create tutorial search database

    if OPT.searchdb
        createSearchDb = true;
        
        docSearchDir = fullfile(oetroot,'docs','OpenEarthDocs','oethelpdocs');
        docInfo = dir(fullfile(docSearchDir,'helptoc.xml'));
        
        if isdir(fullfile(docSearchDir,'helpsearch')) && ...
                exist(fullfile(docSearchDir,'searchdbversion.mat'),'file')
            load(fullfile(docSearchDir,'searchdbversion.mat'));
            createSearchDb = ~strcmp(searchDbVersion.MatlabVersion,version) ||...
                searchDbVersion.DocVersion ~= docInfo.datenum; %#ok<NODEF>
        end
        if createSearchDb
            disp('Creating <a href="http://OpenEarth.deltares.nl">openearthtools</a> search database, please wait ...')
            try % does not work when using read-only checkout
                DocumentationExists = exist(fullfile(docSearchDir,'helptoc.xml'),'file');
                if DocumentationExists && exist('builddocsearchdb','file')
                    builddocsearchdb(docSearchDir);
                    searchDbVersion = struct(...
                        'DocVersion',docInfo.datenum,...
                        'MatlabVersion',version); %#ok<NASGU>
                    save(fullfile(docSearchDir,'searchdbversion.mat'),'searchDbVersion');
                end
            catch
                warning('OET:NoSearchDB',...
                    ['Could not build search database because %s is read-only. \n'...'
                    'the openearthtools help documentation is still available in the matlab help navigator.'],...
                    docSearchDir);
            end
        end
    end
    
%% Restore warning and directory state

%    warning(state.warning)
        cd(state.pwd)

   clear state

%% set svn:keywords automatically to any new m-file

   autosetSVNkeywords
   
%% NETCDF (if not present yet)
%  (NB RESTOREDEFAULTPATH does not restore java paths)

   netcdf_settings('quiet',OPT.quiet) % in /io/netcdf/

%% Report

   if ~(OPT.quiet)
       disp(' ')
       help oetsettings
   end
   
%% EOF


