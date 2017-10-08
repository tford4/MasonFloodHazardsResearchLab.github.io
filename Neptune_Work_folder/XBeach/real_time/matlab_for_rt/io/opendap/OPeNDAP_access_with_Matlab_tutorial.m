%OPENDAP_ACCESS_WITH_MATLAB_TUTORIAL  how to use OPeNDAP from within matlab
%
% This tutorial is also available for Python and R
%
%See also: OPeNDAP_subsetting_with_Matlab_tutorial 

% $Id: OPeNDAP_access_with_Matlab_tutorial.m 5281 2011-09-28 11:43:45Z boer_g $
% $Date: 2011-09-28 13:43:45 +0200 (wo, 28 sep 2011) $
% $Author: boer_g $
% $Revision: 5281 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/opendap/OPeNDAP_access_with_Matlab_tutorial.m $
% $Keywords: $

% This document is also posted on a wiki: http://public.deltares.nl/display/OET/OPeNDAP+access+with+matlab

%%
run('Z:\Software\XBeach\xbeach_release_10May2013\xbeach_release_10May2013\oetsettings.m')

%% Read data from an opendap server
url_grid = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB116_4544.nc'
url_time = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/concentration_of_suspended_matter_in_sea_water/id410-DELFZBTHVN.nc'

%%
nc_dump(url_grid)
nc_dump(url_time)

%% Get grid data 
G.x = nc_varget(url_grid,'x');
G.y = nc_varget(url_grid,'y');
G.z = nc_varget(url_grid,'z',[0 0 0],[1 -1 -1]);% get only one timestep (here: 1st), but all x and y, note: nc_varget is zero based.

%% Get time series data
figure
T.t   = nc_cf_time(url_time,'time'); % adapt reference date of 1970 in netCDF to Matlab reference date of 0000
T.eta = nc_varget (url_time,'concentration_of_suspended_matter_in_sea_water');

%% plot grid data
pcolorcorcen(G.x,G.y,G.z)
axis equal
axis tight
tickmap('xy')
grid on
xlabel('x')
ylabel('y')
colorbarwithtitle('z')

%% plot timeseries data
figure
plot(T.t,T.eta)
datetick('x')
grid on
