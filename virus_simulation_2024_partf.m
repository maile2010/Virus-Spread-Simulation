function infectionDays = virus_simulation_2024_partf(numberPeople, sizeEnvironment, radiusOfInfection, chanceOfInfectionPerTimestep, lengthOfInfection)
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

%% Simulate the days needed to reach no infection for initially infected people ranging from 1 to 30
for n = 1:30
%Assign the number of initially infected people at each iteration
infectedNumber(n) = n;
%Assign randomly the indices of n initially infected people
infected(1:n,n) = randperm(numberPeople, infectedNumber(n));
%Assign the length of infection of initially infected people to
%lengthOfInfection
people(infected(1:n,n), 5) = lengthOfInfection;
%Set the radius of infection and change of infection per timestep
radiusOfInfection = 5;
chanceOfInfectionPerTimestep = 0.5;

%Next, we identify the final day of infection at which no one is infected in the population

%Set the first day of infection as 1
time=1;
%Run while loop to simulate the days needed to reach no infection in the population
while sum(people(:,5))~=0
%Identify newly infected people 
distances=squareform(pdist(people(:,1:2)));
notSociallyDistanced=and(distances<radiusOfInfection, distances>0);
potentiallyInfected=notSociallyDistanced(people(:,5)>0,:);
if size(potentiallyInfected,1)>0
      infectionRand = rand(size(potentiallyInfected,1), numberPeople);
      potentiallyInfected2 = potentiallyInfected .* (infectionRand>chanceOfInfectionPerTimestep);
      notImmune = potentiallyInfected2.*(not(repmat(people(:,5)>0,1,size(potentiallyInfected,1))))'.*(repmat(not(people(:,6)),1,size(potentiallyInfected,1)))';
      ind = find(sum(notImmune,1)>0);
end

%% Assign length of infection of males over 60 to 7, of females over 60 to 5, and others to 3
maleover60 = ind(and(people(ind,3)>60,people(ind,4)==0));
femaleover60 = ind(and(people(ind,3)>60,people(ind,4)==1));
upto60 = ind(people(ind,3)<=60);
people(maleover60,5)=lengthOfInfection+4;
people(femaleover60,5)=lengthOfInfection+2;
people(upto60,5)=lengthOfInfection;

%% Next we need to set up the new day
people(people(:,5)==1,6)=1;
people(people(:,5)>0,5)=people(people(:,5)>0,5)-1;
move=ceil(rand(numberPeople,2)*3)-2;
people(:,1:2)=people(:,1:2)+move;
%Check whether people have wandered off the square area and fix (they
%come in the other side)
people(people(:,1)<1,1)=sizeEnvironment;
people(people(:,2)<1,2)=sizeEnvironment;
people(people(:,1)>sizeEnvironment,1)=1;
people(people(:,2)>sizeEnvironment,2)=1;

%time is increased by one unit until no one is infected anymore in the population
time = time+1;
end
infectionDays(n) = time;
%To start a new for loop with a new number of initially infected people, we need to
%reset all the length of infection values and all the immune status to 0 at the
%end of the current loop
people(:,5:6)=0; 
end
%plot the days needed to reach no infection versus the number of innitially
%infected people in the population
plot(infectionDays,'b-o');
xlabel('Number of Initially Infected People');
ylabel('Days Needed to Reach no Infection');
title('Days to Reach No Infection vs. Number of Initially Infected People');
end
