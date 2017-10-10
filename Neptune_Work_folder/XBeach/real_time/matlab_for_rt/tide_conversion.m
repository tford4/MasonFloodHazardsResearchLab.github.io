
%%      Define Path Directory
% This helps with keeping everything in order instead of writing the file
% path multiple times
run(['/home/vse/Neptune_Work_folder/XBeach/real_time/matlab_for_rt/','oetsettings.m']);
tide_dir        = '/home/vse/Neptune_Work_folder/XBeach/real_time/tide_from_arslaan/';
dir             = '/home/vse/Neptune_Work_folder/XBeach/real_time/input/';


%%      determine the tide either use data files or xbeach default    

tide=importdata([tide_dir,'WLFort63.txt']);

tide_h(:,1)=tide.textdata(4:2:end,2);
tide_t(:,1)=tide.textdata(3:2:end,2);

tide_height=str2double(tide_h(:,1));
tide_time=str2double(tide_t(:,1));
tide_time(1:end,1)=3600;
for i=1:length(tide_time(1:(end-1),1))
    tide_time(i+1,1)=tide_time(i,1)+3600;
end
%%    Generate the tide
  xb_tide=xb_generate_tide('time',tide_time,'front',tide_height);
  zsfile=xs_get(xb_tide, 'zs0file');
cd(dir)
  xb_write_tide(zsfile);

