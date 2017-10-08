function Factor=convert_units(InUnits0,OutUnits0,varargin);
%CONVERT_UNITS    Unit conversion function
%
%    factor = convert_units(InUnits,OutUnits)
%
% Given an input and output strings containing units 
% CONVERT_UNITS returns the conversion multiplication 
% factor needed for converting the input units to the output units.
%
%   Input  : - InUnits:  String containing the input units  (e.g. 'days').
%            - OutUnits: String containing the output units (e.g. 'seconds').
%   Output : - factor:   Multiplication factor for converting input units to
%                        output units.
%
% * Powers can be expressed as: m3, m^3, m+3, m^-3
% * brackets are allowed
% * loose numbers are considered as multipliers rather than as powers
%   when seperated from alphabet characters by spaces: convert_units('m 3','m')= 3
% * % is considered as a factor 0.01
% * multiplicative elements should be seperated by either a space or a *
%    so this is not allowed: 'm^3kg^-1'
%
% Example : 
%
%   A = convert_units('m^3 * kg^-1 * s^-2','cm^3 * gr^-1 * s^-2').*B;
%
% Note 1: the user is responsible for the balance of the transformation.
% Note 2: units are case-sensitive.
% Note 3: add any unknown units by editing this function.
%
% See web: <a href="http://www.unidata.ucar.edu/software/udunit">http://www.unidata.ucar.edu/software/udunit</a>
% See also: qp_unitconversion, unitconv, convertUnits, unitsratio (mapping toolbox)

%-----------------------------------------------------------------------
% Tested : Matlab 6.5
%     By : Eran O. Ofek             July 2003
%    URL : http://wise-obs.tau.ac.il/~eran/matlab.html
%-----------------------------------------------------------------------

% 2008 jan 23: started forces and pressure section [Gerben J. de Boer]
% 2008 jan 23: removed refs to constants [Gerben J. de Boer]
% 2008 apr 14: added plural versions [Gerben J. de Boer]
% 2010 apr 26: allow cases like m2 in addition to m^2 [Gerben J. de Boer]
% 2012 nov   : made parsing work for \/, intermediate spaces and for signs in powers

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 08 Sep 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: convert_units.m 7762 2012-11-30 15:27:59Z boer_g $
% $Date: 2012-11-30 16:27:59 +0100 (Fri, 30 Nov 2012) $
% $Author: boer_g $
% $Revision: 7762 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/convert_units.m $
% $Keywords: $

debug = 0;

%% beautify

    InUnits = beautify( InUnits0);
   OutUnits = beautify(OutUnits0);

%% start unit conversion

   percent         = 0.01; % same as in UD units

   %% Definitions  
   % ---------------------
   RAD             = 180./pi;
   cyc             = 1;
   cycle           = 1;
   cycles          = 1;
   
   %% Definitions  
   % ---------------------
   ppm             = 1e-6;

   %% Length units 
   % ---------------------
   mm              = 1e-3;                    % mms
   mms             = mm;                      % mms
   millimeter      = mm;                      % mms
   millimeters     = mm;                      % mms

   cm              = 1e-2;                    % cms
   cms             = cm;                      % cms
   centimeter      = cm;                      % cms
   centimeters     = cm;                      % cms

   dm              = 1e-1;                    % decimeter

   inch            = 0.0254;                  % inch
   	     
   feet            = 0.30480;                 % foot
   foot            = feet;                    % foot
   feets           = feet;                    % foot
   	     
   yard            = 0.9144;                  % yard
   yards           = yard;                    % yard
	     
   m               = 1;                       % meters
   meter           = m;                       % meters
   meters          = m;                       % meters
	     
   km              = 1000;                    % km
   kilometer       = km;                      % kilometers
   kilometers      = km;                      % kilometers
	     
   mile            = 1609;                    % miles
   miles           = mile;                    % miles
   
   %% Volume units 
   % ---------------------
   l               = 1e-3;                    % liter
   liter           = l;                       % liter
   liters          = l;                       % liter
   litre           = l;                       % liter
   litres          = l;                       % liter

   %% Time units 
   % ---------------------
   
   s               = 1;                       % seconds
   sec             = s;                       % seconds
   secs            = s;                       % seconds
   second          = s;                       % seconds
   seconds         = s;                       % seconds
   S               = s;                       % seconds datenum
   SC              = s;                       % seconds
   SEC             = s;                       % seconds SWAN
   
   ms              = 0.001*s;                 % milliseconds
   millisecs       = ms;                      % milliseconds
   millisec        = ms;                      % milliseconds
   millisecond     = ms;                      % milliseconds
   milliseconds    = ms;                      % milliseconds
   
   nanosecond      = 1e-9*s;                  % nanoseconds
   nanoseconds     = nanosecond;              % nanoseconds

   min             = 60*s;                    % minutes
   mins            = min;                     % minutes
   minute          = min;                     % minutes
   minutes         = min;                     % minutes
   MN              = min;                     % minutes
   MI              = min;                     % minutes datenum
   MIN             = min;                     % minutes SWAN
   
   h               = 3600*s;                  % hours
   hh              = h;                       % hours
   H               = h;                       % hours datenum
   HH              = h;                       % hours
   HR              = h;                       % hours SWAN
   hr              = h;                       % hours
   hrs             = h;                       % hours
   hour            = h;                       % hours
   hours           = h;                       % hours
   
   sday            = 86164.09053*s;           % sidereal days
   sdays           = sday;                    % sidereal days

   d               = 86400*s;                 % days
   day             = d;                       % days
   days            = d;                       % days
   DAY             = d;                       % days SWAN
   DAYS            = d;                       % days
   
   week            = 7.*day;                  % weeks
   weeks           = week;                    % weeks
   
   %% years: http://en.wikipedia.org/wiki/Gregorian_year
   
   yr              = 365.24218967.*day;       % tropical year http://en.wikipedia.org/wiki/Gregorian_year#Sidereal.2C_tropical.2C_and_anomalistic_years
   yrs             = yr;                      % tropical year
   year            = yr;                      % tropical year
   years           = yr;                      % tropical year
   
   common_year     = day*365;                 % common year
   common_years    = common_year;             % common year
    
   leap_year       = day*366;                 % leap year
   leap_years      = leap_year;               % leap year

   Gregorian_year  = day*365.2425;            % Gregorian year
   Gregorian_years = Gregorian_year;          % Gregorian year
    
   Julian_year     = day*365.25;              % Julian year
   Julian_years    = Julian_year;             % Julian year
   
   sidereal_year   = day*365.2564;            % sidereal year
   sidereal_years  = Julian_year;             % sidereal year
  
   cen             = year*100;                % tropical century
   
   month           = year/12;                 % months
   months          = month;                   % months
   
   %% Pressure units 
   % ---------------------
   Pa              = 1;                       % pascal
   Pascal          = Pa;                      % pascal
   pascal          = Pa;                      % pascal
   hPa             = 100;                     % hectopascal
   bar             = 1e5;                     % bar
   mbar            = 100;                     % millibar

   %% Force units 
   % ---------------------
   dyn             = 1e-5;                    % dyne
   dyne            = 1e-5;                    % dyne
   dynes           = 1e-5;                    % dyne
   	      
   N               = 1;                       % Newton
   newton          = N;                       % Newton
   Newton          = N;                       % Newton
   
   %% Mass units 
   % ---------------------
   ug               = 1e-9;                   % ug
   mg               = 1e-6;                   % mg
   mgr              = mg;                     % mg

   gr               = 1e-3;                   % grams
   grs              = gr;                     % grams
   gram             = gr;                     % grams
   grams            = gr;                     % grams
   g                = gr;                     % grams
   
   kg               = 1;                      % kilograms
   kgs              = kg;                     % kilograms
   kilogram         = kg;                     % kilograms
   kilograms        = kg;                     % kilograms

   libra            = 0.32736409;             % libra
   pound            = 0.45359237;             % pound
   
   %% Angle units 
   % ---------------------
   rad             = 1;                       % radian
   deg             = 1./RAD;                  % degree
   amin            = deg./60;                 % arcmin
   asec            = amin./60;                % arcsec
   degrees_north   = deg;
   degrees_east    = deg;
   degree_north    = deg;
   degree_east     = deg;
   degree_true     = deg;
   
   %% Solid Angle units 
   % ---------------------
   ster            = 1;                       % steradian
   sdeg            = 1./(RAD.^2);             % square degree
   smin            = 1./((60.*RAD).^2);       % square arcmin
   ssec            = 1./((3600.*RAD).^2);     % square arcsec

% Find conversion factor 
%---------------------
   if debug
      disp(['InUnits  ', InUnits0 ,' beautified to ',InUnits , ' = ',num2str(eval(InUnits) )])
      disp(['OutUnits ', OutUnits0,' beautified to ',OutUnits, ' = ',num2str(eval(OutUnits))])
   end

   F1              = eval(InUnits);
   F2              = eval(OutUnits);
   Factor          = F1./F2;

%% EOF


function str = beautify(str)

   % fortran stlye multiplication
   str = strrep(str,'**','^'   );

   % percentages
   str = strrep(str,'%' ,'0.01');

   % remove double white spaces fo any kind (tab, space,...)
   ind = Inf;while ~isempty(ind);ind      = regexpi(str,'\s\s')         ;str(ind  )=[];;end

   % remove spaces before or after multiplication or division */\
   ind = Inf;while ~isempty(ind);ind      = regexpi(str,'\s[\\/*]{1,1}');str(ind  )=[];;end
   ind = Inf;while ~isempty(ind);ind      = regexpi(str,'[\\/*]{1,1}\s');str(ind  )=[];;end

   % replace all occurences like m2 with m^2 and m-2 with m^-2
   ind      = regexpi(str,'[abcdefghijklmnopqrstuvwxyz][-+]*\d');
   jj = 0;
   for ii=1:length(ind)
      str = strrep(str,[str(ind(ii)+jj)     str(ind(ii)+jj+1)],...
                       [str(ind(ii)+jj) '^' str(ind(ii)+jj+1)]);
      jj = jj + 1;
   end

   % turn loose elements into multiplication string
   ind = Inf;while ~isempty(ind);ind      = regexpi(str,'\s[\\/*]{1,1}');str(ind  )=[];;end
   str = strrep(str,' ' ,'*'   );
