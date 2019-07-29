function [ particle, GlobalBest ] = Seeking( particle , GlobalBest , VelMax , VelMin , VarMax , VarMin , VarSize , nVar)
SRD = 0.5;
SMP = 4;
numOfVars = sum(nVar);
CDC = floor(0.8 * numOfVars);
Fitness_Values = zeros(1 , SMP + 1);
particle_copies = repmat(particle , 1, SMP+1);

for i = 1 : length(particle_copies)
    permIndices = randperm(numOfVars , CDC);
    if i==1
        particle_copies(1) = particle;
    else
        for index = 1 : length(permIndices)
            booleanFlag = mod(randi(2),2);
            if(booleanFlag == 0)
                particle_copies(i).Position(permIndices(index)) = particle_copies(i).Position(permIndices(index)) * (1 + SRD) ;
            else
                particle_copies(i).Position(permIndices(index)) = particle_copies(i).Position(permIndices(index)) * (1 - SRD) ;
            end
        end
    end
    
    
    % Apply Position Limits
    particle_copies(i).Position(1:nVar(1)) = max(particle_copies(i).Position(1:nVar(1)),VarMin(1));
    particle_copies(i).Position(1:nVar(1)) = min(particle_copies(i).Position(1:nVar(1)),VarMax(1));
    
    particle_copies(i).Position(nVar(1)+1:nVar(2)+1) = max(particle_copies(i).Position(nVar(1)+1:nVar(2)+1),VarMin(2));
    particle_copies(i).Position(nVar(1)+1:nVar(2)+1) = min(particle_copies(i).Position(nVar(1)+1:nVar(2)+1),VarMax(2));
    
     particle_copies(i).Cost = Benchmark(particle_copies(i).Position);
     Fitness_Values(i) = particle_copies(i).Cost;
end


maxF = max(Fitness_Values);
minF = min(Fitness_Values);

particle_probability = abs(Fitness_Values - maxF) / abs(maxF - minF);
randIndex = rand();
IsGreater = particle_probability >= randIndex;
GreaterIndex = find(IsGreater == 1);

particle = particle_copies(GreaterIndex(1));


if particle.Cost<particle.Best.Cost
    
    particle.Best.Position=particle.Position;
    particle.Best.Cost=particle.Cost;
    
    % Update Global Best
    if particle.Best.Cost<GlobalBest.Cost
        GlobalBest=particle.Best;
    end
    
end

