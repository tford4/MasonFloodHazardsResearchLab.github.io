#bin/bash!

#ssh -p 22 fhrl@Poseidon.vsnet.gmu.edu
#SERVER="akhalid6@gmu.edu"
#GITDIR=/home/fhrl/Documents/PotomicTidalForecastModel/RESULTS/PLOTS/MasonFloodHazardsResearchLab.github.io/Potomac_flood_forecast_model_by_ADCIRC

git remote set-url origin git@github.com:MasonFloodHazardsResearchLab/MasonFloodHazardsResearchLab.github.io.git
git pull
git add --all
git commit -m "testing"

git push 
#Username='akhalid6@gmu.edu'