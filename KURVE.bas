DECLARE SUB delay (duration!)
DECLARE FUNCTION toRad! (degrees!)
RANDOMIZE TIMER
SCREEN 12
CLS

' arrays for keyboard routine
DIM KS(255), SC(255), DU(255)
FOR E = 0 TO 127
	SC(E) = E: DU(E) = 1
NEXT
FOR E = 128 TO 255
	SC(E) = E - 128: DU(E) = 0
NEXT

' gamefield
CONST FIELDOFFSETY = 80
CONST FIELDOFFSETX = 20
CONST FIELDWIDTH = 500
CONST FIELDHEIGHT = 350
CONST FIELDCOLOR = 0
CONST FIELDLINECOLOR = 15 ' must differ form FIELDCOLOR

' tunables
CONST ANGLEMODIFIER = 5
CONST PXDISTMODIFIER = 1
CONST GAPLENGTH = 20
CONST GAPCHANCE = 20 ' * 1 / 10000
CONST LINEWIDTH = 2 ' * 2     
CONST FRAMEDELAY = .04  ' float, in seconds, min is 0.04

' defining the datastructure for a player
TYPE plyr
	posx AS DOUBLE
	posy AS DOUBLE
	deltax AS DOUBLE
	deltay AS DOUBLE
	angle AS SINGLE
	gapcount  AS INTEGER
	gapcountdown AS INTEGER
	linelength AS INTEGER
	linecolor AS INTEGER
	leftkeycode AS INTEGER
	rightkeycode AS INTEGER
	points AS INTEGER
	active AS INTEGER
END TYPE

playercount = 2
activeplayers = playercount

DIM player(playercount) AS plyr

FOR i = 0 TO playercount
	player(i).deltax = 0
	player(i).deltay = 0
	player(i).gapcount = 0
	player(i).gapcountdown = 0
	player(i).linelength = 0
	player(i).points = 0
	player(i).active = 1
NEXT

player(1).posx = 300
player(1).posy = 300
player(1).angle = 180
player(1).linecolor = 10
player(1).leftkeycode = 30
player(1).rightkeycode = 32

player(2).posx = 100
player(2).posy = 100
player(2).angle = 90
player(2).linecolor = 12
player(2).leftkeycode = 36
player(2).rightkeycode = 38

PRINT "ACHTUNG, DIE BASIC KURVE!"

LINE (FIELDOFFSETX, FIELDOFFSETY)-(FIELDOFFSETX + FIELDWIDTH, FIELDOFFSETY + FIELDHEIGHT), FIELDLINECOLOR, B
PAINT (FIELDOFFSETX + 1, FIELDOFFSETY + 1), FIELDCOLOR, FIELDLINECOLOR


DO
	'Eric Carr's multi-key routine
	'http://tek-tips.com/faqs.cfm?fid=4193
T:
J$ = INKEY$
J = INP(&H60)
OUT &H61, INP(&H61) OR &H61: OUT &H61, &H20
KS(SC(J)) = DU(J)

	FOR i = 0 TO playercount
		IF player(i).active = 1 THEN
			IF KS(player(i).leftkeycode) = 1 THEN player(i).angle = (player(i).angle - ANGLEMODIFIER) MOD 360
			IF KS(player(i).rightkeycode) = 1 THEN player(i).angle = (player(i).angle + ANGLEMODIFIER) MOD 360
		
			player(i).deltax = COS(toRad(player(i).angle)) * PXDISTMODIFIER
			player(i).deltay = SIN(toRad(player(i).angle)) * PXDISTMODIFIER
			
			player(i).posx = player(i).posx + player(i).deltax
			player(i).posy = player(i).posy + player(i).deltay

			IF (RND * 10000) + 1 <= GAPCHANCE THEN
				player(i).gapcountdown = GAPLENGTH
				player(i).gapcount = player(i).gapcount + 1
			END IF
       
			IF player(i).gapcountdown = 0 THEN
				IF POINT(player(i).posx + player(i).deltax, player(i).posy + player(i).deltay) <> FIELDCOLOR THEN
				      player(i).active = 0
				      activeplayers = activeplayers - 1
				      COLOR player(i).linecolor: PRINT "Player "; i; " lost!": COLOR 15
				ELSE
					' still bugs with collision detection when CIRCLE is used
					' the collision will just be detected with the CIRECLE center

					'PSET (posx, posy), LINECOLOR
					CIRCLE (player(i).posx - player(i).deltax * LINEWIDTH, player(i).posy - player(i).deltay * LINEWIDTH), LINEWIDTH, player(i).linecolor
				END IF
			ELSE
				player(i).gapcountdown = player(i).gapcountdown - 1
			END IF

			player(i).linelength = player(i).linelength + 1
		END IF
		IF activeplayers = 0 THEN EXIT FOR
	NEXT
		
	delay (FRAMEDELAY)
LOOP UNTIL KS(1) = 1 OR activeplayers = 0

END

SUB delay (duration!)
	' from www.techiwarehouse.com/cat/17/BASIC-Programming
	CONST TICKS = 86400
	tim = TIMER
	DO
	LOOP UNTIL (TIMER - tim + TICKS) - (INT((TIMER - tim + TICKS) / TICKS) * TICKS) > duration
END SUB

FUNCTION toRad (degrees)
toRad = (degrees / 180) * ATN(1) * 4
END FUNCTION

