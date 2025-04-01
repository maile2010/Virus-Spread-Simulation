function t_final = virus_simulation_2024_assign(numberPeople, sizeEnvironment, radiusOfInfection, chanceOfInfectionPerTimestep, lengthOfInfection, simulationLength)
numberPeople = 1000;
sizeEnvironment = 100;
lengthOfInfection = 3;
people = zeros(numberPeople, 6);
people(:,1:2)=ceil(rand(numberPeople,2)*sizeEnvironment);

%% Now assign gender 0 = male, 1 = female to column 4 of the people matrix
%read the table from the Netherlands population as of 29th August 2022
[num,txt,raw] = xlsread('D:\UM\MATLAB\Data\population');
M0 = raw(2:21,1:3);
%Assign the name for each column of table M
M = array2table(M0,'VariableNames',{'age group','men','women'});
%Calculate the total number of people in each age group
M.total = cell2mat(M{:,2}) + cell2mat(M{:,3});
%Calculate the percentage of males in each age group 
M.menpercent=cell2mat(M{:,2})./M.total*100;
%Calculate the percentage of females in each age group
M.womenpercent = cell2mat(M{:,3})./M.total*100;
%Calculate the percentage of males in the Netherlands population
MalePerc = mean(M.menpercent);
%Calculate the percentage of females in the Netherlands population
FemalePerc= mean(M.womenpercent);

%Thus, the gender distribution of the Netherlands population is 
% 46.7342 % male : 53.2658 % female. 
%Now, we need to assign this distribution randomly to column 4 of the 
%people matrix with male = 0 and female = 1

%Calculate the number of females in the simulated population
femalenumber = round((FemalePerc/100)*numberPeople);
%Assign the gender of these people to 1
people(1:femalenumber,4) = 1; 
%Rearrange the gender of the simulated population randomly
randomOrder = randperm(numberPeople);
people(:,4) = people(randomOrder,4);

%% Assign age to each of these people
%Calculate the percentage of each age group from the Netherlands population
M.agepercent = M.total./sum(M.total)*100;
%Calculate the number of people in each age group of the people matrix
agenumber = round((M.agepercent/100)*numberPeople);
%Check if the sum of people from all age groups is not equal to the total
%number of people due to rounding
sum(agenumber) == numberPeople;
%If no, we need to adjust the agenumber to the same value as numberPeople 
agenumber(end) = agenumber(end) + (numberPeople-sum(agenumber));
%Create a zero array of age of all people in the simulated population
age_array=zeros(numberPeople,1);
%Calculate the cumulative sum of people in each age group as the
%indices for age_array
age_cum=cumsum(agenumber);
%Randomly assign the age for people in age group 0-5
age_array(1:age_cum(1)) = randi([(1-1)*5,(1*5-1)],agenumber(1),1);
%Randomly assign the age for people from the age group 5-10 to 95 and above
for i=2:20
  age_array((age_cum(i-1)+1):age_cum(i))=randi([(i-1)*5,(i*5-1)],agenumber(i),1);
end
%Assign column 3 of the people matrix to the values of age_array
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

%% Question c - Alternative codes for code line 129
%Find the indices of people who haven't been infected and haven't acquired the
%immune at the beginning of the simulated timestep
I = find(and(people(:,5)==0,people(:,6)==0));
%Create a zeros matrix with the same size as the potentiallyInfected2 matrix
Alt = zeros(size(potentiallyInfected,1),numberPeople);
%Identify newly infected people in the Alt matrix (entry = 1)
Alt(:,I)= potentiallyInfected2(:,I)*1;

%% Assign length of infection of males over 60 to 7, and of females over 60 to 5, and others to 3
%Find the indices of newly infected people who are males over 60
maleover60 = ind(and(people(ind,3)>60,people(ind,4)==0));
%Find the indices of newly infected people who are females over 60
femaleover60 = ind(and(people(ind,3)>60,people(ind,4)==1));
%Find the indices of newly infected people who are under or equal to 60
upto60 = ind(people(ind,3)<=60);
%Assign the length of infection of newly infected people
people(maleover60,5)=lengthOfInfection+4;
people(femaleover60,5)=lengthOfInfection+2;
people(upto60,5)=lengthOfInfection;

 %% Next we need to set up the new day
    %Who is going to stop being infectious (and become immune)?
    people(people(:,5)==1,6)=1;
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

 
