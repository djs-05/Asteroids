classdef Asteroid
    properties
        xCenter;
        yCenter;
        zCenter;
        zFactor;
        X;
        Y;
        Z;
        xRotateAxis;
        yRotateAxis;
        zRotateAxis;
        rotSpeed;
        speed;
        sphereObj;
        nPoly;
        nHits;
        hitBox;
        isHit = false;
    end
    methods
        function a = Asteroid()
            if(randi(2)==1)
                if(randi(2)==1)
                    a.xCenter=-115-5*rand;
                    a.yCenter=-100+200*rand;
                else
                    a.xCenter=115+5*rand;
                    a.yCenter=-100+200*rand;
                end
            else
                if(randi(2)==1)
                    a.xCenter=-100+200*rand;
                    a.yCenter=-115-5*rand;
                else
                    a.xCenter=-100+200*rand;
                    a.yCenter=115+5*rand;
                end
            end
            a.zCenter=100+randi(100);
            a.zFactor=7+3*rand;
            nPolys=5+randi(2);
            [a.X,a.Y,a.Z]=sphere(nPolys);
            a.X=a.X.*a.zFactor+a.xCenter;
            a.Y=a.Y.*a.zFactor+a.yCenter;
            a.Z=a.Z.*a.zFactor+a.zCenter;
            a.xRotateAxis=0;
            a.yRotateAxis=0;
            a.zRotateAxis=0;
            while(a.xRotateAxis==0&&a.yRotateAxis==0&&a.zRotateAxis==0)
                a.xRotateAxis = -1+2*rand;
                a.yRotateAxis = -1+2*rand;
                a.zRotateAxis = -1+2*rand;
            end
            a.rotSpeed = 0.25+0.5*rand;
            a.speed = 1-0.0004*(9+rand);
            a.nPoly=nPolys;
            a.nHits = 2500000;
            a.displayAsteroid;
        end
        
        function a = displayAsteroid(a)
            a.sphereObj = surfl(a.X,a.Y,a.Z);
        end

        function a=rotate(a)
            direction=[a.xRotateAxis,a.yRotateAxis,a.zRotateAxis];
            origin = [a.xCenter,a.yCenter,a.zCenter];
            rotate(a.sphereObj,direction,a.rotSpeed,origin);
        end

        function a=move(a,lastMoveUpdate)
            timeDif = cast(tic-lastMoveUpdate,"double")/100000;
            initSpeed=a.speed;
            a.speed = 1+(a.speed-1)*timeDif;
            a.sphereObj.XData=(a.sphereObj.XData-a.xCenter)./a.speed+a.xCenter*a.speed;
            a.sphereObj.YData=(a.sphereObj.YData-a.yCenter)./a.speed+a.yCenter*a.speed;
            a.sphereObj.ZData=(a.sphereObj.ZData-a.zCenter)./a.speed+a.zCenter/a.speed;
            a.xCenter=a.xCenter*a.speed;
            a.yCenter=a.yCenter*a.speed;
            a.zCenter=a.zCenter/a.speed;
            a.zFactor=a.zFactor/a.speed;
            a.speed=initSpeed;
        end

        function a = initHitBox(a)
            a.hitBox= alphaShape(a.sphereObj.XData(:),a.sphereObj.YData(:),a.sphereObj.ZData(:),a.zFactor);
        end

        function hit = checkHit(a,pointer)
            hit = inShape(a.hitBox,pointer(1),pointer(2),a.zCenter);
        end

        function color(a)
            colormap(a.sphereObj,copper);
        end
    end
end