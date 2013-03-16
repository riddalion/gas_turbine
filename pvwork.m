% pvwork - Compute work from pressure vs volume graph
clear all; help pvwork;  % Clear memory, figure; print header

%@ Initialize variables
nMoles = input('Enter number of moles of gas: ');
P(1) = input('Enter initial pressure (Pa): ');
V(1) = input('Enter initial volume (m^3): ');
R = 8.314;     % Ras constant (J/mole)
T(1) = P(1)*V(1)/(nMoles*R);  % Initial temperature
PPlot = P(1);  % Record initial pressure for plot
VPlot = V(1);  % Record initial volume for plot
WTotal = 0;    % Total work done (J)
iPoint = 1;    % Initial point
NCurve = 100;  % Number of points used to draw isotherm curves

%@ Loop until QUIT is selected from menu
QuitType = 4;  % Quit is the 4th selection on the menu
PathType = 0;  % Dummy value for PathType to enter while loop
while(PathType ~= QuitType)    

  %@ Select type of path (isobar, isochore or isotherm) or quit
  iPoint = iPoint + 1;  % Next point
  fprintf('For leg #%g \n',iPoint-1);
  PathType = menu(sprintf('Leg %g: Select next path',iPoint-1), ...
  'Isobar (Constant P)', 'Isochore (Constant V)', ...
  'Isotherm (Select new V)','QUIT');
  
  %@ If the next path leg is an isobar (Constant P)	
  if( PathType == 1 )
    close(gcf);    % Close the figure window
	%@ Determine the new volume, pressure and temperature
    V(iPoint) = input('Enter new volume: ');
    P(iPoint) = P(iPoint-1);     % New pressure same as old pressure
    T(iPoint) = P(iPoint)*V(iPoint)/(nMoles*R); % New temperature
 	%@ Compute the work on done an isobar
    W = P(iPoint)*( V(iPoint) - V(iPoint-1) );
	%@ Add volume and pressure to plot data
    VPlot = [VPlot V(iPoint)];   % Add points to volume data for plotting
    PPlot = [PPlot P(iPoint)];   % Add points to pressure data for plotting

  %@ else if the next path leg is an isochore (Constant V)	
  elseif( PathType == 2 )   
    close(gcf);    % Close the figure window
	%@ Determine the new volume, pressure and temperature
    P(iPoint) = input('Enter new pressure: ');
    V(iPoint) = V(iPoint-1);
    T(iPoint) = P(iPoint)*V(iPoint)/(nMoles*R);
 	%@ The work done on an isochore is zero
    W = 0;  
	%@ Add volume and pressure to plot data
    VPlot = [VPlot V(iPoint)];   % Add points to volume data for plotting
    PPlot = [PPlot P(iPoint)];   % Add points to pressure data for plotting

  %@ else if the next path leg is an isotherm (Select new V)
  elseif( PathType == 3 )   
    close(gcf);    % Close the figure window
	%@ Determine the new volume, pressure and temperature
    V(iPoint) = input('Enter new volume: ');
    T(iPoint) = T(iPoint-1);
    P(iPoint) = nMoles*R*T(iPoint)/V(iPoint);
	%@ Find the work done on the isothermal leg
    W = nMoles*R*T(iPoint)*log(V(iPoint)/V(iPoint-1));
	%@ Compute values of V and P along the isotherm and add to plot data
	for i=1:NCurve
      VNew(i) = V(iPoint-1) + (i-1)/(NCurve-1)*(V(iPoint)-V(iPoint-1));
	  PNew(i) = nMoles*R*T(iPoint)/VNew(i);
	end
    VPlot = [VPlot VNew];       % Add points to volume data for plotting
    PPlot = [PPlot PNew];       % Add points to pressure data for plotting
		
  end
  
  %@ Draw the total path on the PV diagram, adding this leg
  if( PathType ~= QuitType )
    clf; figure(gcf);     % Clear figure; bring window forward
    WTotal = WTotal + W;  % Add work done to total tally
    plot(V,P,'o',VPlot,PPlot,'-');
    axis([0 1.5*max(V) 0 1.5*max(P)]);   % Set plot range
    xlabel('Volume (m^3)');  
	ylabel('Pressure (Pa)');
    for i=1:iPoint
      text(V(i),P(i),sprintf(' %g',i));  % Mark each point
    end
    title(sprintf('Work; Last leg = %g J, Total = %g J',W,WTotal) );
    drawnow;
  end
end