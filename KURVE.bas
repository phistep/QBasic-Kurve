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
CONST FIELDOFFSETY = 20
CONST FIELDOFFSETX = 20
CONST FIELDWIDTH = 480
CONST FIELDHEIGHT = 440
CONST FIELDCOLOR = 0
CONST FIELDLINECOLOR = 15 ' must differ from FIELDCOLOR

' tunables
CONST ANGLEMODIFIER = 3
CONST PXDISTMODIFIER = 1
CONST GAPLENGTH = 20
CONST GAPCHANCE = 20 ' * 1 / 10000
CONST LINEWIDTH = 2 ' * 2    
CONST FRAMEDELAY = .04  ' float, in seconds, min is 0.04
CONST NOSPAWNZONE = 75

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

' player keycodes
DIM keycodelist(6, 2) ' (# of player, leftkey | rightkey)
keycodelist(1, 1) = 16 'Q
keycodelist(1, 2) = 17 'W
keycodelist(2, 1) = 20 'T
keycodelist(2, 2) = 21 'Y/Z
keycodelist(3, 1) = 24 'O
keycodelist(3, 2) = 25 'P
keycodelist(4, 1) = 31 'S
keycodelist(4, 2) = 32 'D
keycodelist(5, 1) = 36 'J
keycodelist(5, 2) = 37 'K
keycodelist(6, 1) = 47 'V
keycodelist(6, 2) = 48 'B

' playeroptions
playercount = 2 ' up to six

'set variables
scoreupdate = 1
gameend = 0
DIM player(playercount) AS plyr

' the round loop
DO
	CLS

	' reset and randomize player values
	activeplayers = playercount
       
	FOR i = 1 TO playercount
		player(i).deltax = 0
		player(i).deltay = 0
		player(i).gapcount = 0
		player(i).gapcountdown = 0
		player(i).linelength = 0
       
		player(i).active = 1
		player(i).linecolor = i + 8
		player(i).leftkeycode = keycodelist(i, 1)
		player(i).rightkeycode = keycodelist(i, 2)

		player(i).angle = (RND * 360) + 1
		player(i).posx = (RND * (FIELDWIDTH - 2 * NOSPAWNZONE)) + FIELDOFFSETX + NOSPAWNZONE
		player(i).posy = (RND * (FIELDHEIGHT - 2 * NOSPAWNZONE)) + FIELDOFFSETY + NOSPAWNZONE
	NEXT

	' draw gamefield
	LINE (FIELDOFFSETX, FIELDOFFSETY)-(FIELDOFFSETX + FIELDWIDTH, FIELDOFFSETY + FIELDHEIGHT), FIELDLINECOLOR, B
	PAINT (FIELDOFFSETX + 1, FIELDOFFSETY + 1), FIELDCOLOR, FIELDLINECOLOR

	' the game loop
	DO
		IF scoreupdate = 1 THEN
			FOR k = 1 TO playercount
				LOCATE 2 * k + 2, 66
				COLOR player(k).linecolor
				PRINT "Player"; k; ":"; player(k).points; " "
				COLOR 15
			NEXT
			scoreupdate = 0
		END IF


		'Eric Carr's multi-key routine
		'http://tek-tips.com/faqs.cfm?fid=4193
T:
		j$ = INKEY$
		j = INP(&H60)
		OUT &H61, INP(&H61) OR &H61: OUT &H61, &H20
		KS(SC(j)) = DU(j)

		FOR i = 1 TO playercount
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
					      FOR k = 1 TO playercount
							IF player(k).active THEN player(k).points = player(k).points + 1
							IF player(k).points = (playercount - 1) * 10 THEN gameend = 1
					      NEXT
					      scoreupdate = 1
					ELSE
					      ' still bugs with collision detection when CIRCLE is used
					      ' the collision will just be detected with the CIRECLE center

					      'PSET (player(i).posx, player(i).posy), player(i).linecolor
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
	LOOP UNTIL KS(1) = 1 OR activeplayers = 1 OR gameend = 1'end game loop
LOOP UNTIL KS(1) OR gameend = 1'end round loop

END

SUB delay (duration!)
	' from www.techiwarehouse.com/cat/17/BASIC-Programming
	CONST TICKS = 86400
	tim = TIMER
	DO
	LOOP UNTIL (TIMER - tim + TICKS) - (INT((TIMER - tim + TICKS) / TICKS) * TICKS) > duration
END SUB

FUNCTION toRad (degrees!)
toRad = (degrees / 180) * ATN(1) * 4
END FUNCTION

