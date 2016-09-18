	setprop("/navigation/closest-icao", ' ');     
	setprop("/navigation/closest-runway", ' ');
	setprop("/navigation/closest-distance", 0);
	setprop("/navigation/closest-course", 0);
	setprop("/navigation/closest-lat", 0);
	setprop("/navigation/closest-lon", 0);
	setprop("/navigation/closest-alt", 0);
	setprop("/navigation/runway-heading", 0);	
	setprop("/navigation/type", 'ILS'); 
	setprop("/navigation/closestTxt", '---');
	setprop("/navigation/airfieldTxt", '---');
	setprop("/navigation/autoPressure", 'OFF');

    var dialog = gui.Dialog.new("/sim/gui/dialogs/Concorde/navigator/dialog","Aircraft/Concorde/Nasal/Concorde_navigator.xml");
 	gui.popupTip("Concorde navigator on board", 1);
 	 
	#setprop("sim/menubar/default/menu[100]/item[3]/label", 'Navigator');
	# this needs to be boolean true - but how to do it?? 
	#setprop("sim/menubar/default/menu[100]/item[3]/enabled", getprop("sim/menubar/default/menu[100]/item[2]/enabled") );
	#setprop("sim/menubar/default/menu[100]/item[3]/binding/command", 'nasal'); 
	#setprop("sim/menubar/default/menu[100]/item[3]/binding/script", 'gui.showDialog("navigator");');
	
	# so this is a KB version
	#setprop("input/keyboard/key[78]/desc", 'Navigator dialog');
	#setprop("input/keyboard/key[78]/name", 'N');
	#setprop("input/keyboard/key[78]/binding/command", 'nasal');
	#setprop("input/keyboard/key[78]/binding/script", 'gui.showDialog("navigator");');

	 
	          

var nav_loop = func { 
	var myQNH = getprop("/environment/pressure-sea-level-inhg") * 033.863887;
	var myMb  = getprop("/instrumentation/altimeter/setting-inhg") * 033.863887;
	var myLat = getprop("/position/latitude-deg");
	var myLon = getprop("/position/longitude-deg");
	var myAlt = getprop("/position/altitude-ft");
	var myHdg = getprop("/orientation/heading-magnetic-deg");
	var info = airportinfo("airport");
	var closestRwy = 0;
	var closestDist = 99999.9 ;
	var closestCourse = 99999.9 ;
	var altDiff = math.round(myAlt - info.elevation* M2FT);
	var aboveBelowTxt = 'below';
	var altFeet = 0;
	var altSettingTxt = '= OK';
	var cseDiff = 0.0;
	var cseDiffSmallest = 999.0;
	
		
	# the following is common to all runways:
	setprop("/navigation/closest-icao", info.id);
	altFeet = int(info.elevation* M2FT +0.5);			
	setprop("/navigation/closest-alt", altFeet);
	altDiff = math.round(myAlt - info.elevation* M2FT);
	setprop("/navigation/height-difference", int(altDiff +0.5));
	
	# but for these, we need to find the closest runway,	
	foreach(var rwy; keys(info.runways)) {
		var to = {lat: info.runways[rwy].lat, lon: info.runways[rwy].lon};
		var (course, dist) = courseAndDistance(myLat, myLon, to);
		if(closestDist >= dist){
			closestRwy = rwy ;
			closestDist = dist;
			closestCourse = course ;
			cseDiff = closestCourse - myHdg ;
			setprop("/navigation/runway-heading", int(info.runways[rwy].heading +0.5));
			setprop("/navigation/closest-lat", info.runways[rwy].lat);
			setprop("/navigation/closest-lon", info.runways[rwy].lon);
		}
		# end of find closest runway, 
		setprop("/navigation/closest-runway", closestRwy);
		setprop("/navigation/closest-distance", closestDist);
		setprop("/navigation/closest-course", closestCourse);
	}
	var closestTxt = ["Closest runway= Rw",closestRwy, ";", sprintf("%.2f", closestDist), "nm @", math.round(closestCourse), "deg", info.name,"[",info.id,"]"];
	closestTxt = string.join(" ", closestTxt);
	setprop("/navigation/closestTxt", closestTxt);
	
	var courseTxt = ["Course correction required=", sprintf("%.2f", cseDiff), "deg"];
	courseTxt = string.join(" ", courseTxt);
	setprop("/navigation/courseTxt", courseTxt);

	if(0 >= altDiff){aboveBelowTxt = 'ABOVE';}	
	var airfieldTxt = ["Airfield altitude=", sprintf("%.0f", altFeet), ", which is", sprintf("%.0f", altDiff), "ft", aboveBelowTxt, " current altitude "];
	airfieldTxt = string.join(" ", airfieldTxt);
	setprop("/navigation/airfieldTxt", airfieldTxt);
	
	# which is the most aligned runway? - See EGOD as an example - because the closest one 
	# might not be the one you are heading for!
		foreach(var rwy; keys(info.runways)) {
		var to = {lat: info.runways[rwy].lat, lon: info.runways[rwy].lon};
		var (course, dist) = courseAndDistance(myLat, myLon, to);
		cseDiff = myHdg - info.runways[rwy].heading ;
		# messy, Q+D !
		if(0 >= cseDiff  ){cseDiff = -cseDiff;}
		if(cseDiff >= 360){cseDiff = cseDiff - 360;}
		if(cseDiffSmallest >= cseDiff){
			cseDiffSmallest = cseDiff;
			mostAlignedRwy = rwy ;
			mostAlignedCourse = course ;
			mostAligneDist = dist;
			setprop("/navigation/mostAligned-runway-heading", int(info.runways[rwy].heading +0.5));
			setprop("/navigation/mostAligned-lat", info.runways[rwy].lat);
			setprop("/navigation/mostAligned-lon", info.runways[rwy].lon);
		}
		# end of find most aligned runway, 
		setprop("/navigation/mostAligned-runway", mostAlignedRwy);
		setprop("/navigation/mostAligned-distance", mostAligneDist);
		setprop("/navigation/mostAligned-offset", cseDiffSmallest);
	}
	
		var ILS_caption = " - ";
		var (altDiff, brgToTgt, distance, glideSlope, runwayOffset, relativeRwyHeading, hdgOffsetToRwy) = needles(
			getprop("/navigation/closest-alt"), 
			getprop("/navigation/mostAligned-lat"), 
			getprop("/navigation/mostAligned-lon"), 
			getprop("/navigation/mostAligned-runway-heading")
		);
		setprop("/navigation/needleGlideslope", glideSlope -3);
		setprop("/navigation/needleLocaliser", runwayOffset);
		if(runwayOffset >= -10 and 10 >= runwayOffset){
			setprop("/navigation/localiser", 1);
			ILS_caption = ['RWY', getprop("/navigation/mostAligned-runway")];
			ILS_caption = string.join(" ", ILS_caption);		}
		else{
			setprop("/navigation/localiser", 0);
			setprop("/navigation/needleLocaliser", 0);
			ILS_caption = " - ";
		}
		setprop("/navigation/ILS-caption", ILS_caption);
		
		
		
		if(glideSlope >= -8 and 8 >= glideSlope and runwayOffset >= -10 and 10 >= runwayOffset){
			setprop("/navigation/glideSlope", 1);
		}
		else{
			setprop("/navigation/glideSlope", 0);
			setprop("/navigation/needleGlideslope", 0);
		}
		
		
		

	
	if ( (myMb-myQNH)*(myMb-myQNH) >= 2){
		if(getprop("/navigation/autoPressure")=='QNH'){
			setprop("/instrumentation/altimeter/setting-inhg", getprop("/environment/pressure-sea-level-inhg"));
			gui.popupTip("Altimeter set to local QNH", 2);
		}
		else{
			altSettingTxt = '-!OOPS!-';
		}
	}	
	var pressureTxt = ["Sea level pressure (QNH)=", sprintf("%.0f", myQNH), "; current altimeter setting=", sprintf("%.0f", myMb), altSettingTxt];
	pressureTxt = string.join(" ", pressureTxt);
	setprop("/navigation/pressureTxt", pressureTxt);	
	
	
	
	settimer(nav_loop, 1);
 } 
var needles = func(tgtAlt, tgtLat, tgtLon, tgtHdg) {
 	var          myLat = getprop("/position/latitude-deg");
	var          myLon = getprop("/position/longitude-deg");
	var          myAlt = getprop("/position/altitude-ft");
	var currentHeading = getprop("/orientation/heading-deg");
	var        altDiff = math.round(myAlt - tgtAlt* M2FT);
	var to = {lat: tgtLat, lon: tgtLon};
	var (brgToTgt, distToTgt) = courseAndDistance(myLat, myLon, to);
	var glideSlope = 0 ;  
	if( distToTgt == 0.0 ){glideSlope = 90 ;}# just in case .. 
	elsif(altDiff == 0.0 ){glideSlope =  0 ;}# .. div by zero ?????
	else{
	var sinGlideSlope = (altDiff)/(distToTgt * 6076.1);
		   glideSlope = (math.sin(sinGlideSlope))* (180 / math.pi); # should it be tangent ??
	}
	var runwayOffset       =  geo.normdeg180(tgtHdg - brgToTgt) ;
	var relativeRwyHeading = -geo.normdeg180(currentHeading - tgtHdg) ;	
	var hdgOffsetToRwy     =  geo.normdeg180(currentHeading - brgToTgt);
	return [altDiff, brgToTgt, distToTgt, glideSlope, runwayOffset, relativeRwyHeading, hdgOffsetToRwy];
}



var init = setlistener("/sim/signals/fdm-initialized", func() {
	removelistener(init); # only call once
	settimer(nav_loop, 5);
	nav_loop();
});