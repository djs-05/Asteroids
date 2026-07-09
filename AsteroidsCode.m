% Runs the Asteroids Game.
function AsteroidsCode()
    % Suppresses errors to the console.
    try
        run;
    end
end

% Actual code to run; used in Asteroids so it won't display an error at the
% end. Also used for obfuscation.
function run()
% Basics for Setting Up a .m File
clc;
clear;
close;
hold on;

% Music Variables.
% Background Music
[bgmy] = audioread('Sound Effects/BackgroundMusic.wav');
bgp = audioplayer(bgmy,44100);

% Blaster SFX
[sey] = audioread('Sound Effects/Blaster.wav');
sep = audioplayer(sey*.25,44100);

% Disco Music
[dmy] = audioread('Sound Effects/DiscoMusic.wav');
dmp = audioplayer(dmy*.25,44100);

% Ship Exploding
[ssdy] = audioread('Sound Effects/ShipExplosion.wav');
ssdp = audioplayer(ssdy*.5,44100);

% Warp Drive
[wdy] = audioread('Sound Effects/WarpDrive.wav');
wdp = audioplayer(wdy*.5,48000);

% Lose Sound
[lsy] = audioread('Sound Effects/LoseSound.wav');
lsp = audioplayer(lsy*.25,44100);

% Win Sound
[wsy] = audioread('Sound Effects/WinSound.wav');
wsp = audioplayer(wsy*.20,48000);

% Prevents lag; warning created every time hitBox is initialized; cannot
% fix without removing hitboxes, which cannot be done.
warning('off','all');

% Sets up the Figure w/ the correct appearance
fig = figure(1);
fig.IntegerHandle="off";
fig.Name="Asteroids";
fig.MenuBar="none";
fig.Color = "#3a3a3a";
fig.CurrentCharacter='~';
fig.WindowState="fullscreen";
fig.Pointer='custom';
fig.PointerShapeCData=NaN(16);

% Variables to interact with the Callbacks
escToExit=true;
charTrack=text(0,0,"","Visible","off");
difficulty=text(-96,94,10,"Easy","FontName","Copperplate Gothic Bold","Color",[.1,.95,.1],"FontWeight","bold","FontSize",12,"BackgroundColor",[.1,.1,.1],"EdgeColor",[.9,.9,.9]);


% Sets Up Event Listeners
set(fig,KeyReleaseFcn=@(src,event)keyReleased(src,event,charTrack))
set(fig,KeyPressFcn=@(src,event)keyPressed(src,event,escToExit,charTrack,bgp,difficulty))

% Sets Camera to 2D View
view([0 0 1]);

% Initializes Var to Keep Track of Location, Rate At Which Crosshair Moves
pointer = [0,0];
changePerUpdate=2;

% Graphical Display
scoreOnTop=true;
mainPauseOnTop=false;
pauseOnTop=true;
devOnTop=true;
warningOnTop=true;

% Variables to track fun "secret" mode.
cMapDev=false;
devOp='  ';

% Variables to track sentinel values throughout the program.
winThresholdList=[10,25,50,25];
maxAsteroidsList=[5,7,10,25];
secsPerAsteroidList=[2.5,2,1.5,0.5];
deathZone=750;
sqrt2=1/sqrt(2);

% Makes the background black.
backgroundTop = area([-100,100],[100,100]);
backgroundTop.FaceColor = "black";
backgroundBottom = area([-100,100],[-100,-100]);
backgroundBottom.FaceColor = "black";


cMapDevCM=[colormap("parula"),colormap("turbo"),colormap("hsv"),colormap("cool"),...
    colormap("spring"),colormap("summer"),colormap("autumn"),colormap("winter"),...
    colormap("gray"),colormap("bone"),colormap("copper"),colormap("pink"),...
    colormap("sky"),colormap("abyss"),colormap("jet"),colormap("lines"),...
    colormap("colorcube"),colormap("prism"),colormap("flag")];

% Creates some "stars" for the background.
lightGray=[.9,.9,.9];
gray=[.8,.8,.8];
darkGray=[.6,.6,.6];
plot(-97.5+195.*rand(10),-97.5+195.*rand(10),".","Color","white");
plot(-97.5+195.*rand(10),-97.5+195.*rand(10),".","Color",gray);
plot(-97.5+195.*rand(10),-97.5+195.*rand(10),".","Color",darkGray);

% Displays the asteroid in the center of the start screen.
startAst=Asteroid;
startAstObj=surfl(3*(startAst.X-startAst.xCenter),3*(startAst.Y-startAst.yCenter),3*(startAst.Z-startAst.zCenter));
rotate(startAstObj,[startAst.xRotateAxis,startAst.yRotateAxis,startAst.zRotateAxis],45,[0,0,0]);
startAstObj.CData=startAstObj.CData.*0.5;
graphicsSetup();
colormap([copper(32);hot(32)]);

startText=initStartText(lightGray,gray,darkGray);
instText=initInstText(lightGray,gray,darkGray);

devText = text(96,-94,devOnTop*(deathZone+100)+1,"Disco Mode Enabled","FontName","Copperplate Gothic Bold","Color",lightGray,"FontWeight","bold","FontSize",12,"BackgroundColor",[.1,.1,.1],"EdgeColor",lightGray,"Visible","off","HorizontalAlignment","right");
crosshair = text(pointer(1),pointer(2),deathZone+500,"⌖","Color","white","HorizontalAlignment","center","Visible","off");
score = text(-96,94,scoreOnTop*(deathZone+100)+1,"Asteroids Destroyed: 0","FontName","Copperplate Gothic Bold","Color",lightGray,"FontWeight","bold","FontSize",12,"BackgroundColor",[.1,.1,.1],"EdgeColor",lightGray,"Visible","off");
warningText = text(-96,-94,warningOnTop*(deathZone+100)+1,"Warning: Asteroid Close","FontName","Copperplate Gothic Bold","Color",[.1,.1,.1],"FontWeight","bold","FontSize",12,"BackgroundColor",[.95,.1,.1],"EdgeColor",lightGray,"Visible","off","HorizontalAlignment","left");

pauseText1(1)=text(0,5,mainPauseOnTop*(deathZone+100)+1,"Game Paused","Color","white","FontWeight","bold","FontSize",32,"HorizontalAlignment","center");
pauseText1(2)=text(0,-5,mainPauseOnTop*(deathZone+100)+1,"Press Any Game Input to Continue","Color",gray,"FontWeight","bold","FontSize",16,"HorizontalAlignment","center");
pauseText1(3)=text(96,94,pauseOnTop*(deathZone+100)+1,"Paused","Color",lightGray,"FontWeight","bold","FontSize",12,"HorizontalAlignment","right","BackgroundColor",[.1,.1,.1],"EdgeColor",lightGray);
for i = 1:length(pauseText1)
    pauseText1(i).FontName="Copperplate Gothic Bold";
    pauseText1(i).Visible="off";
end

endText(1)=text(0,50,5000,"You Win!","FontName","Copperplate Gothic Bold","FontSize",32,"FontWeight","bold","Color","white","HorizontalAlignment","center","BackgroundColor",[0,0,0]);
endText(2)=text(0,50,5000,"Game Ended","FontName","Copperplate Gothic Bold","FontSize",32,"FontWeight","bold","Color","white","HorizontalAlignment","center","BackgroundColor",[0,0,0]);
endText(3)=text(0,50,5000,"Ship Destroyed...","FontName","Copperplate Gothic Bold","FontSize",32,"FontWeight","bold","Color",[.95,.2,.2],"HorizontalAlignment","center","BackgroundColor",[0,0,0]);
endText(4)=text(0,35,5000,"Asteroids Destroyed: 0","FontName","Copperplate Gothic Bold","FontSize",18,"Color",lightGray,"HorizontalAlignment","center","BackgroundColor",[0,0,0]);
endText(5)=text(0,27.5,5000,"Time Elapsed: 0 Seconds","FontName","Copperplate Gothic Bold","FontSize",14,"Color",gray,"HorizontalAlignment","center","BackgroundColor",[0,0,0]);
endText(6)=text(0,-35,5000,"Play Again?","FontSize",32,"FontName","Copperplate Gothic Bold","FontWeight","bold","Color","white","HorizontalAlignment","center","BackgroundColor",[0,0,0]);
endText(7)=text(0,-50,5000,"Press Any Key to Continue","FontName","Copperplate Gothic Bold","FontSize",12,"FontWeight","bold","Color",lightGray,"HorizontalAlignment","center","BackgroundColor",[0,0,0]);
endText(8)=text(0,20,5000,"Difficulty: ","FontName","Copperplate Gothic Bold","FontSize",14,"Color",gray,"HorizontalAlignment","center","BackgroundColor",[0,0,0]);
for i = 1:length(endText)
    endText(i).Visible="off";
end
pauseText=text(-30,0,5000,"Loading","FontName","Copperplate Gothic Bold","FontSize",32,"FontWeight","bold","Color","white","BackgroundColor",[0,0,0],"Visible","off");


waitforbuttonpress;
% In case esc to close is turned off, will wait till button other than
% escape is pressed to begin.
while(isscalar(fig.CurrentCharacter)&&(fig.CurrentCharacter=='0'||fig.CurrentCharacter==''))
    waitforbuttonpress;
end

userInput=fig.CurrentCharacter;
startAstObj.Visible="off";
for i = 1:length(startText)
    startText(i).Visible="off";
end
difficulty.Visible="off";

if(isscalar(fig.CurrentCharacter)&&userInput=='1')
    % Makes instText visible
    for i = 1:length(instText)
        instText(i).Visible="on";
    end

    waitforbuttonpress;
    % In case esc to close is turned off, will wait till button other than
    % escape is pressed to start.
    while(isscalar(fig.CurrentCharacter)&&fig.CurrentCharacter=='')
        waitforbuttonpress;
    end
    if(isscalar(fig.CurrentCharacter))
        devOp(1)=fig.CurrentCharacter;
    end
    for i = 1:length(instText)
        instText(i).Visible="off";
    end
end
% Allows for multiple games to be played in a row.
while(1)
    difficultyString = difficulty.String;
    if(matches(difficultyString,"Easy"))
        winThreshold=winThresholdList(1);
        maxAsteroids=maxAsteroidsList(1);
        secsPerAsteroid=secsPerAsteroidList(1);
    elseif(matches(difficultyString,"Medium"))
        winThreshold=winThresholdList(2);
        maxAsteroids=maxAsteroidsList(2);
        secsPerAsteroid=secsPerAsteroidList(2);
    elseif(matches(difficultyString,"Hard"))
        winThreshold=winThresholdList(3);
        maxAsteroids=maxAsteroidsList(3);
        secsPerAsteroid=secsPerAsteroidList(3);
    else
        winThreshold=winThresholdList(4);
        maxAsteroids=maxAsteroidsList(4);
        secsPerAsteroid=secsPerAsteroidList(4);
    end
    secsPerAsteroidDelta=0.5*secsPerAsteroid/winThreshold;
    clear difficultyString;

    numDestroyed=0;
    currentAsteroid=1;
    unitsPerAst=secsPerAsteroid*10000000;

    asteroid(1)=Asteroid;
    asteroid(1)=[];

    pauseText.Visible="on";

    drawnow;

    % Pre-allocate the creation of Asteroids to remove stuttering during
    % run-time.
    lastPauseTextUpdate=text(0,0,"","Visible","off");
    for i = 1:(winThreshold+maxAsteroids)
        pauseTextUpdate(pauseText,lastPauseTextUpdate);
        drawnow;
        tempContainer(i)=Asteroid().displayAsteroid;
        tempContainer(i).sphereObj.CData=tempContainer(i).sphereObj.CData./2;
        tempContainer(i)=tempContainer(i).initHitBox();
        tempContainer(i).sphereObj.Visible="off";
    end
    graphicsSetup();
    colormap([copper(32);hot(32)]);

    pauseText.Visible="off";

    % Just used for a bit of fun; only accessible on the second run.
    if(sum(devOp=='d')+sum(devOp=='s')==2||cMapDev)
        cMapDev=true;
        cMapNum=1;
        devText.Visible="on";
        dmp.play;
    else
        bgp.play;
    end
    
    score.Visible="on";
    crosshair.Visible="on";
    
    stopped=false;
    wasShooting=false;
    
    timeSinceLastPause=tic;
    lastMoveUpdate=tic;
    timer = tic;
    startOfGame=tic;
    devTime=tic;
    warningTime=tic;
    shootingTime=NaN;
    
    % Constantly Updating Code; Increase pause to Slow Down
    while(1)
        %Just for fun; dev mode which allows the asteroids to change
        %colors whenever a new one spawns.
        if(cMapDev&&tic-devTime>10000000)
            cMapNum=mod(cMapNum+1,19);
            colormap([cMapDevCM(1:32,cMapNum*3+1:cMapNum*3+3);hot(32)]);
            devTime=tic;
        end

        % Just makes the screen look nicer when maximized
        if(fig.WindowState=="maximized")
            fig.WindowState="fullscreen";
        end

        %Takes Inputs From the Keyboard - Updated using EventListeners so
        %multiple inputs may be taken at the same time.
        if(isscalar(fig.CurrentCharacter))
            if(fig.CurrentCharacter(1)~='~'&&sum(charTrack==fig.CurrentCharacter)==0)
                charTrack.String(end+1)=fig.CurrentCharacter(1);
            elseif(fig.CurrentCharacter(1)=='~')
                charTrack.String='~';
                wasShooting=false;
            end
        end

        % Movement Tracker
        tempCharTrack=lower(charTrack.String);
        moveMult=changePerUpdate*cast((tic-lastMoveUpdate),"double")/100000;
        % ['w', 's', 'a', 'd', 'p', 'o', ' ', 'm']
        containsChars=[contains(tempCharTrack,'w'),contains(tempCharTrack,'s'),contains(tempCharTrack,'a'),contains(tempCharTrack,'d'),contains(tempCharTrack,'p'),contains(tempCharTrack,'o'),contains(tempCharTrack,' '),contains(tempCharTrack,'m')];

        if(containsChars(6))
            endOfGame=tic;
            stopped=true;
            break;
        end
        
        % Movement Logic
        dupeInstr = sum(containsChars(1:4));
        if(dupeInstr==2||dupeInstr==4)
            moveMult=moveMult*sqrt2;
        end
        if(containsChars(1)&&pointer(2)+moveMult<=100)
            pointer(2)=pointer(2)+moveMult;
        end
        if(containsChars(2)&&pointer(2)-moveMult>=-100)
            pointer(2)=pointer(2)-moveMult;
        end
        if(containsChars(3)&&pointer(1)-moveMult>=-100)
            pointer(1)=pointer(1)-moveMult;
        end
        if(containsChars(4)&&pointer(1)+moveMult<=100)
            pointer(1)=pointer(1)+moveMult;
        end

        % Update asteroid positions, etc
        for i = 1:length(asteroid)
            asteroid(i)=asteroid(i).move(lastMoveUpdate);
            asteroid(i)=asteroid(i).rotate;
            asteroid(i)=asteroid(i).initHitBox;
        end

        lastMoveUpdate=tic;

        % Pause Logic
        if(containsChars(5)&&tic-timeSinceLastPause>2500000)
            song = dmp.isplaying;
            bgp.pause;
            dmp.pause;
            timeSinceLastPause=tic;
            for i = 1:length(pauseText1)
                pauseText1(i).Visible="on";
            end
            pause(.25)
            while(~contains('aAwWdDsSpP oOmM',fig.CurrentCharacter))
                pause(.1);
                if(fig.WindowState=="maximized")
                    fig.WindowState="fullscreen";
                end
            end
            for i = 1:length(pauseText1)
                pauseText1(i).Visible="off";
            end
            startOfGame=startOfGame+(tic-timeSinceLastPause);
            timeSinceLastPause=tic;
            lastMoveUpdate=tic;
            shootingTime=tic;
            if(~song)
                bgp.resume;
            else
                dmp.resume;
            end
        end

        % Shooting Logic
        hit=false;
        % Takes care of resetting individual coloring
        for i = 1:length(asteroid)
            if(asteroid(i).isHit)
                asteroid(i).sphereObj.CData=asteroid(i).sphereObj.CData-0.5;
                asteroid(i).isHit=false;
            end
        end
        if(containsChars(7))% Checks Each Asteroid If Hit
            if(~wasShooting&&(bgp.isplaying||dmp.isplaying))
                sep.play;
                wasShooting=true;
            end

            for i = 1:length(asteroid)
                asteroid(i).isHit = false;
            end

            j=1;
            temp=NaN(length(asteroid));
            for i = 1:length(asteroid)
                asteroid(i).initHitBox;
                if(asteroid(i).checkHit(pointer))
                    temp(j)=i;
                    j=j+1;
                end
            end

            % Finds the Closest Asteroid Hit
            closest=NaN;
            for i = 1:length(temp)
                if(i==1)
                    closest=temp(i);
                elseif(~isnan(temp(i))&&asteroid(temp(i)).zCenter>asteroid(closest).zCenter)
                    closest=temp(i);
                end
            end
            
            if(~isnan(closest))
                hit=true;
                if(~isnan(shootingTime))
                    asteroid(closest).nHits=asteroid(closest).nHits-(tic-shootingTime);
                    if(~asteroid(closest).isHit)
                        asteroid(closest).sphereObj.CData=asteroid(closest).sphereObj.CData+0.5;
                    end
                    asteroid(closest).isHit = true;
                    if(asteroid(closest).nHits<=0)
                        asteroid(closest).sphereObj.Visible="off";
                        clear asteroid(closest).*;
                        asteroid(closest)=[];
                        numDestroyed=numDestroyed+1;
                    end
                end
            else
                wasShooting=false;
            end
            clear temp.*;
            clear closest;
        end
        shootingTime=tic;
        clear containsChars.*;
    
            
        if((tic - timer > unitsPerAst||isempty(asteroid))&&length(asteroid)<maxAsteroids)
            asteroid(end+1)=tempContainer(currentAsteroid);
            asteroid(end).sphereObj.Visible="on";
            secsPerAsteroid=secsPerAsteroid-secsPerAsteroidDelta;
            unitsPerAst=10000000*secsPerAsteroid;
            currentAsteroid=currentAsteroid+1;
            timer=tic;
        end

        crosshair.Position=[pointer(1),pointer(2),crosshair.Position(3)];
        score.String="Asteroids Destroyed: "+numDestroyed;

        if(testForWarning(asteroid,deathZone))
            warningText.Visible="on";
            if(tic-warningTime>1000000)
                if(warningText.BackgroundColor(2)==.95)
                    warningText.BackgroundColor=[.95,.1,.1];
                else
                    warningText.BackgroundColor=[.95,.95,.1];
                end
                warningTime=tic;
            end
        else
            warningText.Visible="off";
        end

        if(testForGameEnd(asteroid,deathZone)||numDestroyed>=winThreshold)
            endOfGame=tic;
            break;
        end
        pause(0.005);
    end

    bgp.pause;
    bgp.stop;
    dmp.pause;
    dmp.stop;

    score.Visible="off";
    devText.Visible="off";
    warningText.Visible="off";
    
    colormap([copper(32);hot(32)]);
    
    if(numDestroyed>=winThreshold)
        % Win Animation
        wdp.play;
        for i = 1:150
            lastMoveUpdate=tic;
            for j = 1:length(asteroid)
                asteroid(j)=asteroid(j).move(lastMoveUpdate);
                asteroid(j).speed=asteroid(j).speed+.01;
            end
            pause(.01);
        end
        for i = 1:length(asteroid)
            asteroid(i).sphereObj.Visible="off";
        end
        wsp.play;
        endText(1).Visible="on";
        pause(.5);
        endText(4).Visible="on";
        for i = 0:numDestroyed
            endText(4).String="Asteroids Destroyed: "+i;
            pause(0.05);
        end
        pause(0.5);
        endText(5).Visible="on";
        for i = 0:(endOfGame-startOfGame)/10000000
            endText(5).String="Time Elapsed: "+i+" Seconds";
            pause(0.05)
        end
    else
        pause(1);
        for i = length(asteroid):-1:1
            asteroid(i).sphereObj.Visible="off";
            clear asteroid(i).*;
            asteroid(i) = [];
            pause(0.25);
        end

        if(stopped)
            endText(2).Visible="on";
        else
            ssdp.play;
            pause(1);
            % Lose Animation
            [xExplode,yExplode,zExplode]=sphere(10);
            endAnim=surfl(xExplode,yExplode,zExplode);
            initXData=endAnim.XData;
            initYData=endAnim.YData;
            initZData=endAnim.ZData;
            graphicsSetup();
            colormap hot;
            for i = [6:-.05:0,0:.1:6]
                endAnim.XData=initXData.*(36-i^2);
                endAnim.YData=initYData.*(36-i^2);
                endAnim.ZData=initZData.*(36-i^2);
                pause(0.01);
            end
            endAnim.Visible="off";
            clear endAnim.*;
            pause(1);
            lsp.play;
            endText(3).Visible="on";
        end
        pause(1);
        endText(4).Visible="on";
        endText(4).String="Asteroids Destroyed: "+numDestroyed;
        pause(1);
        endText(5).Visible="on";
        endText(5).String="Time Elapsed: "+(endOfGame-startOfGame)/10000000+" Seconds";
    end
    pause(1);
    endText(8).String="Difficulty: "+difficulty.String;
    endText(8).Visible="on";
    pause(1.5);
    endText(6).Visible="on";
    endText(7).Visible="on";
    difficulty.Visible="on";
    crosshair.Visible="off";

    waitforbuttonpress;
    % In case esc to close is turned off, will wait till button other than
    % escape is pressed to continue.
    while(isscalar(fig.CurrentCharacter)&&(fig.CurrentCharacter=='0'||fig.CurrentCharacter==''))
        waitforbuttonpress;
    end

    wsp.pause;
    wsp.stop;
    lsp.pause;
    lsp.stop;
    difficulty.Visible="off";

    % Ooh ahh, secret!
    if(isscalar(fig.CurrentCharacter))
        devOp(2)=fig.CurrentCharacter;
    end

    % Stops displaying
    for i = 1:length(endText)
        endText(i).Visible="off";
    end
    for i = length(tempContainer):-1:1
        clear tempContainer(i).*;
        tempContainer(i)=[];
    end
    for i = length(asteroid):-1:1
        clear asteroid(i).*;
        asteroid(i)=[];
    end

end
end



%----------------

% Important Functions for Use Throughout Program

% Must be called after every batch of calls to display or other functions.
function graphicsSetup()
    % Removes Axes
    ax=gca;
    ax.XColor = "none";
    ax.YColor = "none";
    ax.ZColor = "none";
    % Standardizes Aspect Ratio
    axis equal;
    axis([-100,100,-100,100,0,2000]);
    %Just Visual Stuff
    shading interp;
end


% Custom EventListener for KeyReleasedScn.
function keyReleased(src,keyData,charTrack)
    try
        src.CurrentCharacter='~';
        charTrack.String=erase(charTrack.String,string(keyData.Character));
        if(contains("wWaAsSdD",string(keyData.Character)))
            toRemove='wWaAsSdD';
            for i = 1:length(toRemove)
                charTrack.String=erase(charTrack.String,string(toRemove(i)));
            end
        end
    end
end

% Custom EventListener for KeyPressedScn.
function keyPressed(src,keyData,escToExit,charTrack,audioPlayer,difficulty)
    try
        if(escToExit&&keyData.Character=='')
            delete(src);
        elseif(keyData.Character=='m'&&audioPlayer.isplaying)
            audioPlayer.pause;
        elseif(keyData.Character=='m')
            audioPlayer.resume;
        elseif(keyData.Character=='0'&&difficulty.Visible=="on")
            if(matches(difficulty.String,"Easy"))
                difficulty.String="Medium";
                difficulty.Color=[.95,.95,.1];
            elseif(matches(difficulty.String,"Medium"))
                difficulty.String="Hard";
                difficulty.Color=[.95,.1,.1];
            elseif(matches(difficulty.String,"Hard"))
                difficulty.String="Impossible";
                difficulty.Color=[.95,.1,.95];
            else
                difficulty.String="Easy";
                difficulty.Color=[.1,.95,.1];
            end
        else
            charTrack.String=strcat(charTrack.String,string(keyData.Character));
        end
    end
end


% Tests if the game has been lost.
function lose = testForGameEnd(a,deathZone)
    lose=false;
    for i = 1:length(a)
        if(inShape(a(i).hitBox,0,0,deathZone)||a(i).zCenter>0.95*deathZone)
            lose=true;
        end
    end
end

% Tests if warning should be on.
function w = testForWarning(a,deathZone)
    w=false;
    for i = 1:length(a)
        if(a(i).zCenter>0.65*deathZone)
            w=true;
        end
    end
end

% Sets up start text.
function startText=initStartText(lightGray,gray,darkGray)
    startText(1)=text(0,60,10,"Asteroids","FontName","Copperplate Gothic Bold","Color","white","FontWeight","bold","FontSize",64,"HorizontalAlignment","center","BackgroundColor",[0,0,0]);
    startText(2)=text(0,-47.5,10,"Press 0 To Change Difficulty","FontName","Copperplate Gothic Bold","Color",darkGray,"FontWeight","bold","FontSize",12,"HorizontalAlignment","center","BackgroundColor",[0,0,0]);
    startText(3)=text(0,-55,10,"Press 1 For Instructions","FontName","Copperplate Gothic Bold","Color",gray,"FontWeight","bold","FontSize",16,"HorizontalAlignment","center","BackgroundColor",[0,0,0]);
    startText(4)=text(0,-65,10,"Press Any Other Key to Play","FontName","Copperplate Gothic Bold","Color",lightGray,"FontWeight","bold","FontSize",20,"HorizontalAlignment","center","BackgroundColor",[0,0,0]);
end

% Sets up instruction text.
function instText=initInstText(lightGray,~,~)
    instText(1)=text(0,85,10,"Instructions","Color","white","FontWeight","bold","FontSize",32);
    instText(2)=text(0,70,10,"You are the commander of a spaceship");
    instText(3)=text(0,62.5,10,"hurtling through an asteroid field.");
    instText(4)=text(0,52.5,10,"Your mission is to make it through the");
    instText(5)=text(0,45,10,"field without allowing any asteroids to");
    instText(6)=text(0,37.5,10,"reach your ship.");
    instText(7)=text(0,27.5,10,"Hover the cursor over an asteroid and");
    instText(8)=text(0,20,10,"press/hold [space] to destroy it.");
    instText(9)=text(0,5,10,"Inputs","Color","white","FontWeight","bold","FontSize",32);
    instText(10)=text(0,-10,10,"W = Move Cursor Up");
    instText(11)=text(0,-17.5,10,"A = Move Cursor Left");
    instText(12)=text(0,-25,10,"S = Move Cursor Right");
    instText(13)=text(0,-32.5,10,"D = Move Cursor Down");
    instText(14)=text(0,-40,10,"Space = Shoot");
    instText(15)=text(0,-47.5,10,"M = Mute/Unmute");
    instText(16)=text(0,-55,10,"P = Pause");
    instText(17)=text(0,-62.5,10,"O = Quit");
    instText(18)=text(0,-62.5,10,"esc = Exit Game");
    instText(19)=text(0,-77.5,10,"Press Any Key to Start","Color","white","FontWeight","bold","FontSize",32);
    
    %Sets Up Common Styles for instText
    for i = 1:length(instText)
        instText(i).FontName="Copperplate Gothic Bold";
        instText(i).HorizontalAlignment="center";
        instText(i).BackgroundColor="black";
        instText(i).Visible="off";
    end
    for i = [2:8,10:18]
        instText(i).Color=lightGray;
        instText(i).FontSize=12;
    end
end

function pauseTextUpdate(pauseText,update)
    if(tic-update.Position(1)>=2500000)
        if(matches(pauseText.String,"Loading"))
            pauseText.String="Loading.";
        elseif(matches(pauseText.String,"Loading."))
            pauseText.String="Loading..";
        elseif(matches(pauseText.String,"Loading.."))
            pauseText.String="Loading...";
        else
            pauseText.String="Loading";
        end
        update.Position(1)=tic;
    end
end