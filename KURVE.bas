DECLARE FUNCTION toRad! (degrees!)
RANDOMIZE TIMER
SCREEN 12
CLS

' typecast
DIM posx AS DOUBLE
DIM posy AS DOUBLE
DIM deltax AS DOUBLE
DIM deltay AS DOUBLE

' setting vars to zero
linelength = 0
gapcount = 0
deltax = 0
deltay = 0
gapcountdown = 0

' start conditions
posx = 300
posy = 300
angle = 180

' gamefield
CONST FIELDOFFSETY = 80
CONST FIELDOFFSETX = 20
CONST FIELDWIDTH = 500
CONST FIELDHEIGHT = 350
CONST FIELDCOLOR = 0
CONST FIELDLINECOLOR = 15 ' must differ form FIELDCOLOR

' tunables
CONST ANGLEMODIFIER = 3
CONST LINECOLOR = 10 ' must differ from FIELDCOLOR
CONST PXDISTMODIFIER = 1
CONST GAPLENGTH = 10
CONST GAPCHANCE = 20 ' * 1 / 10000
CONST LINEWIDTH = 2 ' * 2         

' keys
CONST rightKey$ = "d"
CONST leftKey$ = "a"
CONST QUITKEY$ = "q"

PRINT "ACHTUNG, DIE BASIC KURVE!"
PRINT "Left:  "; leftKey$
PRINT "Right: "; rightKey$
PRINT "Quit:  "; QUITKEY$

LINE (FIELDOFFSETX, FIELDOFFSETY)-(FIELDOFFSETX + FIELDWIDTH, FIELDOFFSETY + FIELDHEIGHT), FIELDLINECOLOR, B
PAINT (FIELDOFFSETX + 1, FIELDOFFSETY + 1), FIELDCOLOR, FIELDLINECOLOR


DO
        userKey$ = INKEY$
        IF userKey$ = leftKey$ THEN angle = (angle - ANGLEMODIFIER) MOD 360
        IF userKey$ = rightKey$ THEN angle = (angle + ANGLEMODIFIER) MOD 360

        deltax = COS(toRad(angle)) * PXDISTMODIFIER
        deltay = SIN(toRad(angle)) * PXDISTMODIFIER
      
        posx = posx + deltax
        posy = posy + deltay

        IF (RND * 10000) + 1 <= GAPCHANCE THEN
                gapcountdown = GAPLENGTH
                gapcount = gapcount + 1
        END IF
       
        IF gapcountdown = 0 THEN
                IF POINT(posx + deltax, posy + deltay) <> FIELDCOLOR THEN
                        userKey$ = QUITKEY$
                ELSE
                        ' still bugs with collision detection when CIRCLE is used
                        ' the collision will just be detected with the CIRECLE center

                        'PSET (posx, posy), LINECOLOR
                        CIRCLE (posx - deltax * LINEWIDTH, posy - deltay * LINEWIDTH), LINEWIDTH, LINECOLOR
                END IF
        ELSE
                gapcountdown = gapcountdown - 1
        END IF

        linelength = linelength + 1

        SLEEP 1
LOOP UNTIL userKey$ = QUITKEY$

' debug info
PRINT
PRINT "STATS"
PRINT "angle      "; angle
PRINT "posx       "; posx
PRINT "posy       "; posy
PRINT "color      "; POINT(posx + deltax, posy + deltay)
PRINT "linelength "; linelength
PRINT "gapcount   "; gapcount

SLEEP
END

FUNCTION toRad (degrees)
toRad = (degrees / 180) * ATN(1) * 4
END FUNCTION

