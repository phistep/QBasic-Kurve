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
pixelcount = 0
gapcount = 0
deltax = 0
deltay = 0
gapcountdown = 0

' start conditions
posx = 300
posy = 300
angle = 180

' tunables
anglemodifier = 3
linecolor = 15
pxdistmodifier = 1
gaplength = 10
gapchance = 20 ' * 1 /10000
             
' keys
rightKey$ = "d"
leftKey$ = "a"
quitKey$ = "q"

PRINT "ACHTUNG, DIE BASIC KURVE!"
PRINT "Left:  "; leftKey$
PRINT "Right: "; rightKey$
PRINT "Quit:  "; quitKey$

DO
        userKey$ = INKEY$
        IF userKey$ = leftKey$ THEN angle = (angle - anglemodifier) MOD 360
        IF userKey$ = rightKey$ THEN angle = (angle + anglemodifier) MOD 360

        deltax = COS(toRad(angle)) * pxdistmodifier
        deltay = SIN(toRad(angle)) * pxdistmodifier
      
        posx = posx + deltax
        posy = posy + deltay

        IF (RND * 10000) + 1 <= gapchance THEN
                gapcountdown = gaplength
                gapcount = gapcount + 1
        END IF
       
        IF gapcountdown = 0 THEN
                IF POINT(posx + deltax, posy + deltay) > 0 THEN
                        userKey$ = quitKey$
                ELSE
                        PSET (posx, posy), linecolor
                        pixelcount = pixelcount + 1
                END IF
        ELSE
                gapcountdown = gapcountdown - 1
        END IF

        SLEEP 1
LOOP UNTIL userKey$ = quitKey$

' debug info
PRINT
PRINT "STATS"
PRINT "angle      "; angle
PRINT "posx       "; posx
PRINT "posy       "; posy
PRINT "color      "; POINT(posx + deltax, posy + deltay)
PRINT "pixelcount "; pixelcount
PRINT "gapcount   "; gapcount

SLEEP
END

FUNCTION toRad (degrees)
toRad = (degrees / 180) * ATN(1) * 4
END FUNCTION

