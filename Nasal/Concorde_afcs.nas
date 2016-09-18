# =======================================================================================#
#                AFCS functions for the Concorde by Warty, 2016-09-17                    #
# =======================================================================================#
var afcs_loop = func { 
	var           altRate = getprop("/velocities/vertical-speed-fps");
	var currentFlightMode = getprop("/afcs/flight-mode");
	var        currentAGL = getprop("/position/altitude-agl-ft"); 
	var        currentIAS = getprop("/velocities/airspeed-kt");
	
	var        currentHdg = getprop("/orientation/heading-magnetic-deg");
	var     currentWP_Hdg = getprop("/instrumentation/gps/wp/wp[1]/bearing-mag-deg");
	
# --------------------------------------------------------------------------- Gyro pointer
	# make the needle point at the current waypoint
	# this should maybe be in Concorde_navigation.nas ??	
	var currentHeadingBugErrorDeg = 0;
	if(currentWP_Hdg != ''){currentHeadingBugErrorDeg = currentWP_Hdg - currentHdg ;}
	setprop("/afcs/currentHeadingBugErrorDeg", currentHeadingBugErrorDeg);	
# ------------------------------------------------------------------------------- Take off	
	# Put the gear up once take off is established	
	if(currentFlightMode == 'Take off' and currentAGL>=50 and altRate >= 10){
		setprop("/controls/gear/gear-down", 0);
		if(currentAGL >= 200 and currentIAS >= 200){
			setprop("/afcs/flight-mode", '-----');
		}
	}
# -------------------------------------------------------------------------------- Landing
	if(currentFlightMode == 'Landing'){
		# Cut power and AutoPilot once landing is established	
		if(getprop("/gear/gear[1]/wow") ==1 and getprop("/gear/gear[3]/wow")==1){
			setprop("/controls/gear/brake-parking", 1);
			#####setprop("/controls/engines/engine[0]/reverser", 1);
			setprop("/autopilot/settings/target-speed-kt", 0);	
			setprop("/autopilot/locks/altitude", "");
			setprop("/autopilot/locks/heading", "");
			setprop("/autopilot/locks/speed", "");
			setprop("/controls/engines/engine[0]/throttle", 0.0);
			setprop("/controls/engines/engine[1]/throttle", 0.0);
			setprop("/controls/engines/engine[2]/throttle", 0.0);
			setprop("/controls/engines/engine[3]/throttle", 0.0);
			####setprop("/controls/flight/speedbrake", 1);
		}
		else{setprop("/controls/gear/brake-parking", 0);} # allow for bounce!!
		if(130 >= currentIAS){
			viewAngle = 90 - 16.5 * currentIAS * (1/140); # 73.5..90
			setprop("/sim/current-view/field-of-view", viewAngle); # was probably on 73.5 zoom for landing
		}
		if( 20 >= currentIAS){
			setprop("/afcs/flight-mode", "Taxi");		
		} 
	} 	
# --------------------------------------------------------------------------end of Landing
    
    setprop("/afcs/Blink2HzCount", getprop("/afcs/Blink2HzCount")+1);
    if(getprop("/afcs/Blink2HzCount") == 5){
    	setprop("/afcs/Blink2HzCount", 0);
    	if(getprop("/afcs/Blinker2Hz") == 0){setprop("/afcs/Blinker2Hz", 1.0);}
    	else                                {setprop("/afcs/Blinker2Hz", 0.0);}
    }
    setprop("/afcs/Blink5HzCount", getprop("/afcs/Blink5HzCount")+1);
    if(getprop("/afcs/Blink5HzCount") == 2){
    	setprop("/afcs/Blink5HzCount", 0);
    	if(getprop("/afcs/Blinker5Hz") == 0){setprop("/afcs/Blinker5Hz", 1.0);}
    	else                                {setprop("/afcs/Blinker5Hz", 0.0);}
    }	


  

		settimer(afcs_loop, 0.05);
		
	}
	
setlistener("/sim/signals/fdm-initialized", func { # ====================== initialization

    setprop("/afcs/counter", 0);
  	setprop("/afcs/targetYawRate", 0);
  	setprop("/afcs/yaw", 0);
  	setprop("/afcs/Blink2HzCount", 0); setprop("/afcs/Blinker2Hz", 0);
  	setprop("/afcs/Blink5HzCount", 0); setprop("/afcs/Blinker5Hz", 0);
    setprop("/surface-positions/elevator-pos-norm", 0);
      		
	afcs_loop();
})
