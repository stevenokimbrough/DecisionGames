globals [starting-pool p-hiccup
  entrance-ramp at-entrance-ramp
  current-warning at-home
  commitment-strategies refuge
  max-ticks prob-up prob-down

  ; globals for reporting an BehaviorSpace
  in-refuge underway
  time-finished total-survived total-died
  turtle0survived? meansurvival
  mean-time-away turtle-0-time-away
  bespoke
  congestion
]

turtles-own [location time-committed
commitment-strategy survived? time-away]


to setup
  clear-all
  set max-ticks 240
  set congestion 50
  set starting-pool patch min-pxcor 0
  ask starting-pool [set pcolor red]
  set entrance-ramp patch (min-pxcor + 2) 0
  ask entrance-ramp [set pcolor yellow
  ]
  set refuge patch (max-pxcor) 3
  ask refuge [set pcolor green
    set plabel "Refuge"]
  ;ask starting-pool [set plabel "Home"]
  set p-hiccup 0.7
  set current-warning 1
; Default setup:
;  if mode = "Random"
;      [set commitment-strategies (list "Go at 1" "Go at 2" "Go at 3" "Go at 4")]
  if mode = "Random"
      [set commitment-strategies (list "Go at 3")]
  if mode = "Bespoke"
      [set commitment-strategies (list "Go at 2" "Go at 2" "Go at 3" "Go at 4" "Go at 4" "Go at 4" "Go at 4"
       "Go at 2" "Go at 2" "Go at 2" "Go at 2" "Go at 2")]
  ;;
  set prob-up downside-risk-level
  set prob-down upside-risk-level

  ask patches with [pycor = 0 and pxcor >= -27] [set pcolor white]

  ;;;
  if mode = "Random" [
  create-turtles numTurtles
  ask turtles [
    set heading 90
    move-to starting-pool
    set location "at-home"
    set time-committed 0
    set commitment-strategy one-of commitment-strategies
    set shape "car"
    set size 2
  ]
  ;; Used to study behavior of a single strategy, etc.
  ask turtle 0 [set commitment-strategy turtle-0-strategy]
  ]

  if mode = "Bespoke" [
    foreach commitment-strategies [
      x -> create-turtles 1 [set commitment-strategy x]
  ]
    ask turtles [
    set heading 90
    move-to starting-pool
    set location "at-home"
    set time-committed 0
    set shape "car"
    set size 2
  ]
    set numTurtles count turtles
  ]
  reset-ticks
end

to go
  tick
  ask turtles with [location = "at-home"] [
      if commit? commitment-strategy [
      ;if count turtles with [location = "entrance-ramp"] < max-on-ramp
      ; No, everyone gets to move to the ramp at will
      move-to entrance-ramp
        set location "entrance-ramp"
        set time-committed ticks]]
  ; p-leave is probability a random turtle gets to leave on this tick
  let p-leave 1 / ((1 + count turtles with [location = "entrance-ramp"]))
  ask turtles with [location = "entrance-ramp"] [
    if p-leave < random-float 1
      [if count turtles-on patch-ahead 3 = 0
        [fd 3 ; puts you at the beginning of the road
          set location "underway"]]]

;  ask turtles with [location = "underway"] [
;    if nobody != patch-at 1 0[
;      if not any? turtles-on patch-at 1 0
;      [
;        if random-float 1 < p-hiccup
;        [fd 1
;          if pxcor = max-pxcor [move-to refuge
;          set location "refuge"]]
;  ]
;  ]
;  ]
  ask turtles with [location = "underway"] [
    ; Determine how congested the road is ahead and
    ; reduce speed accordingly
    let my-xcor xcor
    let num-in-front count turtles with [xcor > my-xcor]
    let factor 0
    if num-in-front <= congestion ; a global variable
    [set factor (1 - (num-in-front / congestion))]
    fd factor
    if pxcor >= max-pxcor - 0.5 [move-to refuge
          set location "refuge"]
  ]
  set current-warning get-warning



  if (ticks >= max-ticks) or (current-warning >= 5)
  [set in-refuge count turtles with [location = "refuge"]
    set at-home count turtles with [location = "at-home"]
    set underway count turtles with [location = "underway"]
    set at-entrance-ramp count turtles with [location = "entrance-ramp"]
    set time-finished ticks
    runstats
  stop]
end

to-report get-warning
  ;; A simple version for testing:
  ;  let y ticks * 0.15
  ;  report min (list y 5)
  let new-warning current-warning
  if random-float 1 <= prob-up
  [set new-warning min (list (new-warning + 1) 5)]
  if random-float 1 <= prob-down
  [set new-warning max (list (new-warning - 1) 0)]
  report new-warning
end

to-report commit? [s]
  ; Agent's strategies will be numerically or otherwise encoded.
  ; Here we decode the strategies and return True or False depending
  ; on whether the agent/turtle gets committed to evacuate.
  ; I will use strings for the input parameter, s.
  if s = "Go at 1" and current-warning >= 1
  [report true]
  if s = "Go at 2" and current-warning >= 2
  [report true]
  if s = "Go at 3" and current-warning >= 3
  [report true]
  if s = "Go at 4" and current-warning >= 4
  [report true]

  report false

end

to dostats
  clear-output
  output-print (word "Turtles in Refuge: " count turtles with [location = "refuge"])
  output-print (word "'Go at 1' in Refuge: " count turtles with [location = "refuge" and commitment-strategy = "Go at 1"])
  output-print (word "'Go at 2' in Refuge: " count turtles with [location = "refuge" and commitment-strategy = "Go at 2"])
  output-print (word "'Go at 3' in Refuge: " count turtles with [location = "refuge" and commitment-strategy = "Go at 3"])
  output-print (word "'Go at 4' in Refuge: " count turtles with [location = "refuge" and commitment-strategy = "Go at 4"])
  output-print (word "Turtles at home: " count turtles with [location = "at-home"])
  output-print (word "Turtles in entrance-ramp: " count turtles with [location = "entrance-ramp"])
  ;output-print (word "Turtles in starting-pool: " count turtles with [location = "starting-pool"])
  output-print (word "Turtles underway: " count turtles with [location = "underway"])

end

to runstats
  clear-output
  if current-warning < 5
  [ask turtles [set survived? 100]]
  if current-warning = 5
  [ask turtles with [location = "refuge"] [set survived? 100]
  ask turtles with [location != "refuge"] [set survived? 0]]
  set total-died count turtles with [survived? = 0]
  set total-survived count turtles with [survived? = 100]
  ask turtle 0 [set turtle0survived? survived?]

  let accum  []
  let time-gone -1
  ask turtles [ifelse time-committed = 0
    [set time-gone 0]
    [set time-gone (ticks - time-committed)]
    set accum lput time-gone accum
    set time-away time-gone]
  set mean-time-away  mean accum
  ask turtle 0 [set turtle-0-time-away time-away]
  set accum []
  ask turtles [set accum lput survived? accum]
  set meansurvival mean accum
end

to dostrategystats
  ask turtles [
    let toprint (word commitment-strategy "," survived? "," time-committed)
    output-print toprint
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
314
10
1117
226
-1
-1
12.231
1
10
1
1
1
0
0
0
1
-32
32
-8
8
0
0
1
ticks
30.0

BUTTON
46
24
112
57
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
46
58
112
94
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
18
139
134
184
NIL
current-warning
1
1
11

MONITOR
147
202
299
247
Turtles underway
count turtles with [location = \"underway\"]
17
1
11

MONITOR
147
247
299
292
Turtles at refuge
count turtles with [location = \"refuge\"]
17
1
11

OUTPUT
9
299
303
475
13

BUTTON
335
433
413
466
NIL
dostats
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
133
59
305
92
numTurtles
numTurtles
1
100
100.0
1
1
NIL
HORIZONTAL

CHOOSER
311
333
449
378
turtle-0-strategy
turtle-0-strategy
"Go at 1" "Go at 2" "Go at 3" "Go at 4" "Never go"
0

MONITOR
147
157
299
202
Turtles at entrance ramp
count turtles with [location = \"entrance-ramp\"]
17
1
11

MONITOR
147
113
299
158
Turtles at home
count turtles with [location = \"at-home\"]
17
1
11

CHOOSER
315
234
463
279
downside-risk-level
downside-risk-level
0.1 0.09 0.08 0.07 0.06 0.05 0.04 0.01
4

CHOOSER
469
234
607
279
upside-risk-level
upside-risk-level
0.1 0.09 0.08 0.07 0.01
3

CHOOSER
131
10
305
55
mode
mode
"Random" "Bespoke"
0

MONITOR
18
184
134
229
NIL
ticks
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Kimbrough, S. O. (2018).  NetLogo Decision Games Evacuation model.  http://www.modelingcommons.org.  

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2018 Steven Orla Kimbrough.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Steven Orla Kimbrough at kimbrough@wharton.upenn.edu.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

car top
true
0
Polygon -7500403 true true 151 8 119 10 98 25 86 48 82 225 90 270 105 289 150 294 195 291 210 270 219 225 214 47 201 24 181 11
Polygon -16777216 true false 210 195 195 210 195 135 210 105
Polygon -16777216 true false 105 255 120 270 180 270 195 255 195 225 105 225
Polygon -16777216 true false 90 195 105 210 105 135 90 105
Polygon -1 true false 205 29 180 30 181 11
Line -7500403 false 210 165 195 165
Line -7500403 false 90 165 105 165
Polygon -16777216 true false 121 135 180 134 204 97 182 89 153 85 120 89 98 97
Line -16777216 false 210 90 195 30
Line -16777216 false 90 90 105 30
Polygon -1 true false 95 29 120 30 119 11

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment2" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="240"/>
    <exitCondition>current-warning &gt;= 5</exitCondition>
    <metric>at-home</metric>
    <metric>at-entrance-ramp</metric>
    <metric>underway</metric>
    <metric>in-refuge</metric>
    <metric>downside-risk-level</metric>
    <metric>upside-risk-level</metric>
    <metric>ticks</metric>
    <metric>meansurvival</metric>
    <metric>mean-time-away</metric>
    <metric>turtle0survived?</metric>
    <metric>turtle-0-time-away</metric>
    <enumeratedValueSet variable="numTurtles">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="turtle-0-strategy">
      <value value="&quot;Go at 4&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentBespoke1" repetitions="30" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="240"/>
    <exitCondition>current-warning &gt;= 5</exitCondition>
    <metric>at-home</metric>
    <metric>at-entrance-ramp</metric>
    <metric>underway</metric>
    <metric>in-refuge</metric>
    <metric>downside-risk-level</metric>
    <metric>upside-risk-level</metric>
    <metric>ticks</metric>
    <metric>meansurvival</metric>
    <metric>mean-time-away</metric>
    <metric>turtle0survived?</metric>
    <metric>turtle-0-time-away</metric>
    <enumeratedValueSet variable="mode">
      <value value="&quot;Bespoke&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentvarying" repetitions="30" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="240"/>
    <exitCondition>current-warning &gt;= 5</exitCondition>
    <metric>at-home</metric>
    <metric>at-entrance-ramp</metric>
    <metric>underway</metric>
    <metric>in-refuge</metric>
    <metric>downside-risk-level</metric>
    <metric>upside-risk-level</metric>
    <metric>ticks</metric>
    <metric>meansurvival</metric>
    <metric>mean-time-away</metric>
    <metric>turtle0survived?</metric>
    <metric>turtle-0-time-away</metric>
    <enumeratedValueSet variable="numTurtles">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="turtle-0-strategy">
      <value value="&quot;Never go&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
