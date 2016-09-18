# Concorde
FlightGear development/experimental version

I have managed to get a Concorde that is at least flyable, in spite of the fact that the existing systems/instruments/buttons are pretty much non-functional. Because so little of the cockpit and systems are currently operational I have fitted a test HUD whilst all the instrumentation is sorted.

Also added some keyboard controls and shortcuts:

Home = Take Off	(AP set to 200 kts, brakes off & nose down). landing gear will be raised automatically on climbing through 50 ft.

PageUp = Climb out (AP set to current hdg, 250 kts, +1,000fpm vertical speed).

PageDown = Approach	(AP set to 220 kts & nose half down)

End = Landing	(AP set to 190 kts, gear & nose down).  Brakes will be applied and engine power cut when both main wheels are firmly on the ground.  Any AP selections will also be cut.

* = Cut power, disengage AP & apply all brakes 

] = nose down
[ = nose up
g = landing gear toggle
, = left rudder
. = right rudder
b = apply all brakes whilst pressed, releases them on key-up
B = toggle parking brake on or off

+ = Set  AP to current speed & heading values and set vertical speed to zero

Ctrl-S = Toggle autopilot speed by auto-throttle lock
9 = Increase throttle or autopilot auto-throttle
3 = Decrease throttle or autopilot auto-throttle

Ctrl-A = (Toggle autopilot altitude lock) sets current altitude in AP and sets VS to zero
8 = Increase AP altitude or vertical speed (fpm)
2 = Decrease AP altitude or vertical speed (fpm)

Ctrl-H = (Toggle autopilot heading lock ) sets current heading in AP
( = left  10 degrees, when AP hdg hold engaged
) = right 10 degrees, when AP hdg hold engaged
4 = Decrease AP heading -1 degree, left
6 = Increase AP heading +1 degree, right



Thrust reversers are not obviously working at the moment.
