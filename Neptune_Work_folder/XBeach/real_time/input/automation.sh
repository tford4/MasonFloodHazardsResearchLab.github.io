#bin/bash!

#ssh fhrl@poseidon.vsnet.gmu.edu 

#scp fhrl@poseidon.vsnet.gmu.edu:/home/fhrl/Documents/XBEACH/WaterLevels_from_Mason_forecast/WLFort63.txt /home/vse/Neptune_Work_folder/XBeach/real_time/tide_from_arslaan/WLFort63.txt  

#matlab -nodisplay -nosplash -r "run /home/vse/Neptune_Work_folder/XBeach/real_time/matlab_for_rt/tide_conversion.m;exit"

#killall -9 matlab


#cd /home/vse/Neptune_Work_folder/XBeach/real_time/input 

#./xbeach



#mv /home/vse/Neptune_Work_folder/XBeach/real_time/input/*.dat /home/vse/Neptune_Work_folder/XBeach/real_time/output

#mv /home/vse/Neptune_Work_folder/XBeach/real_time/input/*.bcf /home/vse/Neptune_Work_folder/XBeach/real_time/output

#cp /home/vse/Neptune_Work_folder/XBeach/real_time/input/*.grd /home/vse/Neptune_Work_folder/XBeach/real_time/output

#cd /home/vse/Neptune_Work_folder/XBeach/real_time/output


#matlab -nodisplay -nosplash -r "run /home/vse/Neptune_Work_folder/XBeach/real_time/matlab_for_rt/video_plot.m; exit;"

#killall -9 matlab

cd /home/vse/Neptune_Work_folder/XBeach/real_time/figures

ffmpeg -i xbeach_mgb.avi xbeach_mgb_movietest.mp4

cp /home/vse/Neptune_Work_folder/XBeach/real_time/figures/xbeach_mgb_movietest.mp4  /home/vse/Neptune_Work_folder/XBeach/real_time/figures/MasonFloodHazardsResearchLab.github.io/Xbeach

#git push git@github.com:MasonFloodHazardsResearchLab/MasonFloodHazardsResearchLab.github.io.git/Xbeach

#git clone git@github.com:MasonFloodHazardsResearchLab/MasonFloodHazardsResearchLab.github.io.git

#git set url git@github.com:MasonFloodHazardsResearchLab/MasonFloodHazardsResearchLab.github.io.git

git remote set-url origin git@github.com:MasonFloodHazardsResearchLab/MasonFloodHazardsResearchLab.github.io.git
git pull
git add --all
git commit -m "testing"
git push -f origin <Xbeach>

