function data = xb_read_bcffile(filename, varargin)
%XB_READ_BCFFILE  Reads a bcf file generated by XBeach
%
%   Reads a wave field realisation generated by XBeach.
%
%   Syntax:
%   data = xb_read_bcffile(filename, varargin)
%
%   Input:
%   filename  = Path to bcf file
%   varargin  = none
%
%   Output:
%   data      = Matrix with wave field data
%
%   Example
%   xb_read_bcffile('E001.bcf')
%   xb_read_bcffile('Q001.bcf')
%
%   See also xb_read_bcflist

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Mar 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_read_bcffile.m 7876 2013-01-04 12:39:29Z hoonhout $
% $Date: 2013-01-04 13:39:29 +0100 (Fri, 04 Jan 2013) $
% $Author: hoonhout $
% $Revision: 7876 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_read_bcffile.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'nt', 0 ...
);

OPT = setproperty(OPT, varargin{:});

if ~exist(filename, 'file')
    error('File not found');
end

%% read file

[fdir fname] = fileparts(filename);
info = dir(filename);

% determine dimensions
dims = xb_read_dims(fdir);

switch upper(fname(1))
    case 'E'
        fdims = [dims.globaly dims.wave_angle];
    case 'Q'
        % distinguish between files with separate Qx, Qy, Qtot and eta data
        % or files with just Qtot
        if OPT.nt > 0
            cols = info.bytes/8/dims.globaly/OPT.nt;
            
            if cols > 3
                fdims = [dims.globaly 4];
            elseif cols > 1
                fdims = [dims.globaly 3];
            else
                fdims = [dims.globaly];
            end
        else
            if mod(info.bytes/8/dims.globaly,4) == 0
                fdims = [dims.globaly 4];
            elseif mod(info.bytes/8/dims.globaly,3) == 0
                fdims = [dims.globaly 3];
            else
                fdims = [dims.globaly];
            end
        end
end

% determine time dimension based on filesize
nt = info.bytes/8/prod(fdims);

% read file
fid = fopen(filename, 'r');

data = nan([fdims nt]);

for i = 1:nt
    idx = [num2cell(repmat(':',1,length(fdims))) {i}];
    data(idx{:}) = fread(fid, fdims, 'double');
end

fclose(fid);