function t_final = virus_simulation_2024_partg(numberPeople, sizeEnvironment, radiusOfInfection, chanceOfInfectionPerTimestep, lengthOfInfection, simulationLength)
numberPeople = 1000;
sizeEnvironment = 100;
lengthOfInfection = 3;
people = zeros(numberPeople, 6);
people(:,1:2)=ceil(rand(numberPeople,2)*sizeEnvironment);

%% Now assign gender 0 = male, 1 = female to column 4 of the people matrix
%Read table from Netherlands population as of 29th August 2022
[num,txt,raw] = xlsread('D:\UM\MATLAB\Data\population');
M0 = raw(2:21,1:3);
M = array2table(M0,'VariableNames',{'age group','men','women'});
M.total = cell2mat(M{:,2}) + cell2mat(M{:,3});
M.menpercent=cell2mat(M{:,2})./M.total*100;
M.womenpercent = cell2mat(M{:,3})./M.total*100;
MalePerc = mean(M.menpercent);
FemalePerc= mean(M.womenpercent);
femalenumber = round((FemalePerc/100)*numberPeople);
people(1:femalenumber,4) = 1; 
randomOrder = randperm(numberPeople);
people(:,4) = people(randomOrder,4);

%% Assign age to each of these people based on the age distribution of the Netherlands population
M.agepercent = M.total./sum(M.total)*100;
agenumber = round((M.agepercent/100)*numberPeople);
sum(agenumber) == numberPeople;
agenumber(end) = agenumber(end) + (numberPeople-sum(agenumber));
age_array=zeros(numberPeople,1);
age_cum=cumsum(agenumber);
age_array(1:age_cum(1)) = randi([(1-1)*5,(1*5-1)],agenumber(1),1);
for i=2:20
  age_array((age_cum(i-1)+1):age_cum(i))=randi([(i-1)*5,(i*5-1)],agenumber(i),1);
end
people(:,3)=age_array;

%% Set one person to be infected at the start and identify newly infected people 
infected = ceil(rand(1)*numberPeople);
people(infected,5)=lengthOfInfection;
radiusOfInfection = 5;
simulationLength = 50;
chanceOfInfectionPerTimestep = 0.5;
t_final = [];

%Start the simulation
for time=1:simulationLength
if sum(people(:,5)) == 0
       t_final = time;
       return;
end

%Calculate distance to  infected people and then identify newly infected
%people
distances=squareform(pdist(people(:,1:2)));
notSociallyDistanced=and(distances<radiusOfInfection, distances>0);
potentiallyInfected=notSociallyDistanced(people(:,5)>0,:);
if size(potentiallyInfected,1)>0
       infectionRand = rand(size(potentiallyInfected,1), numberPeople);
       potentiallyInfected2 = potentiallyInfected .* (infectionRand>chanceOfInfectionPerTimestep);
       notImmune = potentiallyInfected2.*(not(repmat(people(:,5)>0,1,size(potentiallyInfected,1))))'.*(repmat(not(people(:,6)),1,size(potentiallyInfected,1)))';
       ind = find(sum(notImmune,1)>0);
end

%% Assign length of infection of males over 60 to 7, and of females over 60 to 5, and others to 3
maleover60 = ind(and(people(ind,3)>60,people(ind,4)==0));
femaleover60 = ind(and(people(ind,3)>60,people(ind,4)==1));
upto60 = ind(people(ind,3)<=60);
people(maleover60,5)=lengthOfInfection+4;
people(femaleover60,5)=lengthOfInfection+2;
people(upto60,5)=lengthOfInfection;

%% Next we need to set up the new day
   %Who is going to stop being infectious (and become immune)?
   people(people(:,5)==1,6)=1;

%% Now, we simulate the vaccination process
%Randomly assign the position of vaccination center
vaccinationCenter = ceil(rand(1,2) * sizeEnvironment);
vaccinationRadius = 8;
%Set vaccination capacity
vaccinationCapacity = 50;
%Set the first value of the number of people who are vaccinated at the start
vaccinationNumber = 0;
%Find people who haven't been infected and haven't obtained immunity yet as
%potentially vaccinated people
potentialVac = find(and(people(:,5)==0,people(:,6)==0));
%Simulate the vaccination process
for l = 1: length(potentialVac)
%If the number of vaccinated people reaches the vaccination capacity, the
%vaccination will be stopped
if vaccinationNumber == vaccinationCapacity
break;
end
%Calculate the distance between the potentially vaccinated people and
%vaccination center
distancesToCenter(l) = sqrt((people(potentialVac(l),1) - vaccinationCenter(1)).^2 + (people(potentialVac(l),2) - vaccinationCenter(2)).^2);
%If the distance between a potentially vaccinated person and vaccination
%center is under 8, this person will be vaccinated and get immune
if distancesToCenter(l) < vaccinationRadius
  people(potentialVac(l),6)=1;
%The number of vaccinated people is increased by 1 
  vaccinationNumber=vaccinationNumber+1;
end
end

%% Continue to set up the new day for the new simulation
   %Now everyone who is infectious has their infection shortened by 1.
   people(people(:,5)>0,5)=people(people(:,5)>0,5)-1;
   %Now everyone can move up to one unit in each direction
   move=ceil(rand(numberPeople,2)*3)-2;
   people(:,1:2)=people(:,1:2)+move;
   %Check whether people have wandered off the square area and fix (they
   %come in the other side)
   people(people(:,1)<1,1)=sizeEnvironment;
   people(people(:,2)<1,2)=sizeEnvironment;
   people(people(:,1)>sizeEnvironment,1)=1;
   people(people(:,2)>sizeEnvironment,2)=1;
   
   end
end
