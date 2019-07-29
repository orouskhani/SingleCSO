clc;
clear all;
close all;

%% Problem Definition

nVar=[20 0];             % Number of Decision Variables

VarSize=[1 , nVar(1) ; 1 , nVar(2)];   % Size of Decision Variables Matrix

VarMin=[-10 , -10];         % Lower Bound of Variables
VarMax=[10 , 10];         % Upper Bound of Variables


%% CSO Parameters

MaxIt=100;      % Maximum Number of Iterations

nPop=100;        % Population Size (Swarm Size)

w=1;            % Inertia Weight
wdamp=0.99;     % Inertia Weight Damping Ratio
c1=2;           % Global Learning Coefficient
MR = 1;         % 1 = all cats in seeking and 0 = all cats in tracing

% Velocity Limits
VelMax=0.1*(VarMax-VarMin);
VelMin=-VelMax;

%% Initialization

empty_particle.Position=[];
empty_particle.Cost=[];
empty_particle.Velocity=[];
empty_particle.flag = false;
empty_particle.Best.Position=[];
empty_particle.Best.Cost=[];

particle=repmat(empty_particle,nPop,1);

GlobalBest.Cost=inf;

for i=1:nPop
    
    % Initialize Position
    particle(i).Position(1:nVar(1))=unifrnd(VarMin(1),VarMax(1),VarSize(1,:));
    particle(i).Position(nVar(1)+1:nVar(2)+1)=unifrnd(VarMin(2),VarMax(2),VarSize(2,:));
    
    % Initialize Velocity
    particle(i).Velocity(1:nVar(1))=zeros(VarSize(1,:));
    particle(i).Velocity(nVar(1)+1:nVar(2)+1)=zeros(VarSize(2,:));
    % Evaluation
    particle(i).Cost=Benchmark(particle(i).Position);
    
    % Update Personal Best
    particle(i).Best.Position=particle(i).Position;
    particle(i).Best.Cost=particle(i).Cost;
    
    % Update Global Best
    if particle(i).Best.Cost<GlobalBest.Cost
        GlobalBest=particle(i).Best;
    end
    
end

BestCost=zeros(MaxIt,1);

%% CSO Movement
for it=1:MaxIt
    indices = randperm(nPop , floor(nPop*MR));
    for i=1:nPop
        ind = find(indices == i);
        
        if(~isempty(ind))
        %% Seeking Mode    
            [particle(i), GlobalBest] = Seeking( particle(i) , GlobalBest , VelMax , VelMin , VarMax , VarMin , VarSize , nVar);
        else
        %% Tracing Mode
            [ particle(i) , GlobalBest ] = Tracing( particle(i) , GlobalBest , VelMax , VelMin , VarMax , VarMin , VarSize , nVar , w , c1);
        end
        if(particle(i).Cost < GlobalBest.Cost)
            GlobalBest = particle(i);
        end
    end
    BestCost(it)=GlobalBest.Cost;
    disp(['Iteration ' num2str(it)  ', Best Cost = ' num2str(BestCost(it))]);
    w=w*wdamp;
end


%% Results
figure;
semilogy(BestCost,'LineWidth',2);
xlabel('Iteration');
ylabel('Best Cost');

