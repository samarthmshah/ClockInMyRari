function clockInMyRari
%   Clock for the clock-project
%   Basic Requirements:
%   - Display the current Boston time
%   - Have 3 hands, one for the hour, minute, and second each
%   - Have at least 4 ticks on the clock (12, 3, 6, and 9) with text labels
    clear;
    close all
    clc;
    
    % Colors:
    c.fig        = [0.2, 0.2, 0.2];
    c.dial       = [0.8, 0.8, 0.8];
    c.smallDial  = [0, .5, 1];
    c.ticks      = [0.9, 0.9, 0.9];
    c.center     = [.8, .8, .8];
    c.hands      = [.65, .65, .65];
    c.secondHand = [1,0.5,0];
    h.centerCapColor = [0.8 0.8 0.8];
   
    % Sizes
    radius         = 10;
    smallR         = 4;
    bigTickSize    = 1;
    smallTickSize  = 0.5;
    secondHandSize = 0.1;
    secondsRadius  = 9;
    minutesRadius  = 8;
    hoursRadius    = 7.5;
    
    fh = figure('Name', 'Sams Watchface',...
        'menu', 'none',...
        'units','normalized',...
        'numbertitle','off',...
        'color', c.fig);
    
    axes('units','normalized');
    xCenter = 0; yCenter = 0;
    
    createCircle(xCenter, yCenter, radius);
    createSmallCircle(xCenter, yCenter, smallR);
    createTicks;
    [HMSPoints, HMSCutOff, HMSAngles] = getPoints;
    hHands = createHands(HMSPoints, HMSCutOff);
    displayDayTime();
    setupTimer(fh);
    
    function createSmallCircle(xCenter, yCenter, smallR)
        hold on;
        theta = linspace(0, 2*pi, 1e5);
        x = xCenter + smallR * sin(theta);
        y = yCenter + smallR * cos(theta);
        chS = plot(x, y, 'LineWidth', 3); 
        chS.Color = c.secondHand;
        axis equal;
        axis off;
        hold off;
    end

    function createCircle(xCenter, yCenter, r)
        % Working with radians entirely.
        % So circle goes 0 to 2pi.
        hold on;
        theta = linspace(0, 2*pi, 1e5);
        x = r * sin(theta) + xCenter;
        y = r * cos(theta) + yCenter;
        ch = plot(x, y, 'LineWidth', 3);
        ch.Color = c.dial;
        hold off;
    end  
    
    function createTicks 
        hold on;
        
        smallTickIntervalTheta = (0 : 59) * pi / 30;
        bigTickIntervalTheta   = (0:5:55) * pi/30;
        
        % Since we want the ticks to be of size 1: 
        % we do a 9*cos(theta) and 10*cos(theta) to get X coordinates of lines.
        bigXTicks = bsxfun(@times, [radius-bigTickSize; radius], cos(bigTickIntervalTheta));
        bigYTicks = bsxfun(@times, [radius-bigTickSize; radius], sin(bigTickIntervalTheta));
        plot(bigXTicks,bigYTicks,'color',c.ticks, 'LineWidth', 2);
        
        smallXTicks = bsxfun(@times, [radius-smallTickSize; radius], cos(smallTickIntervalTheta));
        smallYTicks = bsxfun(@times, [radius-smallTickSize; radius], sin(smallTickIntervalTheta));
        plot(smallXTicks,smallYTicks,'color',c.ticks, 'LineWidth', 0.5);
        hold off;
    end

    % Map the Current HMS to correct Angles using following formulaes.
    % Return the result in angle vector.
    function [angle] = getAngles
        h.clock = clock;
        h.sec   =  h.clock(6) * pi/30;
        h.min   = (h.clock(5)*6 + h.clock(6)/10) * pi/180;
        h.hr    = (h.clock(4)*30 + h.clock(5)/2 + h.clock(6)/120) * pi/180;
        angle   = [h.hr h.min h.sec];  % All radians
    end
    
    % Get (X, Y) coordinates for Hour, Minutes and Seconds each.
    function [HMSPoints, HMSCutOff, HMSAngles] = getPoints
        HMSAngles = getAngles;  % [H m s]
        
        XCoordinates = [... 
            xCenter + hoursRadius   * sin(HMSAngles(1)),...
            xCenter + minutesRadius * sin(HMSAngles(2)),...
            xCenter + secondsRadius * sin(HMSAngles(3))...
            ];
        XCutOffCoordinates = [... 
            xCenter + smallR * sin(HMSAngles(1)),...
            xCenter + smallR * sin(HMSAngles(2)),...
            xCenter + (radius-bigTickSize-secondHandSize) * sin(HMSAngles(3))...
            ];
        YCoordinates = [...
            yCenter + hoursRadius   * cos(HMSAngles(1)),...
            yCenter + minutesRadius * cos(HMSAngles(2)),...
            yCenter + secondsRadius * cos(HMSAngles(3))...
            ];
        YCutOffCoordinates = [...
           yCenter + smallR * cos(HMSAngles(1)),...
           yCenter + smallR * cos(HMSAngles(2)),...
           yCenter + (radius-bigTickSize-secondHandSize) * cos(HMSAngles(3))...
           ];
        HMSPoints = [XCoordinates; YCoordinates];
        HMSCutOff = [XCutOffCoordinates; YCutOffCoordinates];
    end

    function hHands = createHands(HMSPoints, HMSCutOff)
        hold on;
        hourHand = line([HMSCutOff(1,1) HMSPoints(1,1)], [HMSCutOff(2,1) HMSPoints(2,1)]);
        hourHand.Color = c.hands;
        hourHand.LineWidth = 3;
        minuteHand = line([HMSCutOff(1,2) HMSPoints(1,2)], [HMSCutOff(2,2) HMSPoints(2,2)]);
        minuteHand.Color = c.hands;
        minuteHand.LineWidth = 1.1;
        secondHand = line([HMSCutOff(1,3) HMSPoints(1,3)], [HMSCutOff(2,3) HMSPoints(2,3)]);
        secondHand.Color = c.secondHand;
        secondHand.LineWidth = 25;
        hHands = [hourHand, minuteHand, secondHand];
        hold off;
    end
    
 % Create a timer function occuring every second.
    function setupTimer(fh)
        t = timer('ExecutionMode', 'fixedRate', 'Period', 0.05);
        t.TimerFcn = { @updateClock, hHands };
        start(t);
        fh.DeleteFcn = { @deleteTimer, t };
    end
    
    function updateClock(~, ~, hHands) 
       hourHand   = hHands(1);
       minuteHand = hHands(2);
       secondHand = hHands(3);
       
       [HMSPoints, HMSCutOff, HMSAngles] = getPoints;
       
       hourHand.XData   = [HMSCutOff(1, 1) HMSPoints(1, 1)];
       hourHand.YData   = [HMSCutOff(2, 1) HMSPoints(2, 1)];
       minuteHand.XData = [HMSCutOff(1, 2) HMSPoints(1, 2)];
       minuteHand.YData = [HMSCutOff(2, 2) HMSPoints(2, 2)];
       secondHand.XData = [HMSCutOff(1, 3) HMSPoints(1, 3)];
       secondHand.YData = [HMSCutOff(2, 3) HMSPoints(2, 3)];
       
    end
    
    function deleteTimer(~,~,t)
        stop(t);
        delete(t);
    end
    
    function displayDayTime
        hold on;
        str = {datestr(now, 'mmmm dd,'), datestr(now, 'yyyy')};
        text(0, 0, str,...
            'FontName', 'Consolas',...
            'FontWeight', 'Bold',...
            'FontSize', 12,...
            'FontUnits', 'Normalized',...
            'Color', c.dial,...
            'HorizontalAlignment','center',...
            'VerticalAlignment','middle');    
        hold off;
    end

end
