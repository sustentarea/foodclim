; rice: Rice production in NetLogo.
;
; Version: 2025-03-05 0.0.0.9000
; Authors: Daniel Vartanian, & Aline M. de Carvalho.
; Maintainer: Daniel Vartanian <https://github.com/danielvartan>.
; License: MIT.
; Repository: https://github.com/sustentarea/rice/
;
; Require NetLogo >= 6.4 and R >= 4.5.
; Required R packages: `rJava`, `stringr`, and `lubridate`.
; Required NetLogo extensions: `gis`, ls`,` `pathdir`, `sr`, and `string`.

__includes [
  "nls/utils.nls"
  "nls/utils-checks.nls"
  "nls/utils-plots.nls"
  "nls/utils-strings.nls"
]

extensions [
  gis
  ls
  pathdir
  sr
  string
]

globals [
  base-file
  dataset
  model-tmin
  model-tmax
  model-prec
  index
  month
  year
  max-value
  min-value
  min-plot-y
  max-plot-y
  range-pxcor
  range-pycor
]

patches-own [
  value
]

to setup
  clear-all
  ls:reset
  sr:setup

  set start-year normalize-year start-year

  setup-variables
  setup-world
  setup-map dataset
  setup-stats
  setup-logoclim

  reset-ticks
end

to setup-variables
  (sr:run
    (word
      "files <- list.files("
      "path  = '" fix-string-for-r data-path "'"
      ")"
    )
  )

  set index 0
  set base-file make-list sr:runresult "files"
  set base-file file-path data-path (first base-file)
  set dataset load-patch-data base-file
  set range-pxcor (range min-pxcor (max-pxcor + 1))
  set range-pycor (range min-pycor (max-pycor + 1))
  set year start-year
  set month start-month
end

to setup-world
  let width floor (gis:width-of dataset / 2)
  let height floor (gis:height-of dataset / 2)

  resize-world (-1 * width ) width (-1 * height ) height
  set-patch-size patch-px-size
end

to setup-map [#dataset]
  assert-gis #dataset

  let envelope gis:envelope-of #dataset

  ifelse
  ((item 0 envelope < -150) or (item 1 envelope > 150)) [
    gis:set-world-envelope-ds gis:envelope-of #dataset
  ]
  [gis:set-world-envelope gis:envelope-of #dataset]

  gis:apply-raster #dataset value

  ask (patches) [
    if ((value <= 0) or (value >= 0)) [
      set value random-float 100
    ]
  ]

  update-colors
end

to setup-stats
  set max-value max [value] of patches with [value >= -9999]
  set min-value min [value] of patches with [value >= -9999]

  ;set max-plot-y ceiling max-value
  set min-plot-y ifelse-value (min-value < 0) [floor min-value] [0]
  ;set min-plot-y floor ((quartile 1) - (6 * (quartile "iqr")))
  set max-plot-y ceiling ((quartile 3) + (3 * (quartile "iqr")))
end

to setup-logoclim
  ifelse (interactive = true) [
    ls:create-interactive-models 3 logoclim-path
  ] [
    ls:create-models 3 logoclim-path
  ]

  set model-tmin 0
  set model-tmax 1
  set model-prec 2

  ls:let seed random (2 ^ 31)
  ls:let s-year start-year
  ls:let s-month start-month

  ls:ask model-tmin [
    set data-series "Historical monthly weather data"
    set data-resolution "10 minutes (~340 km2 at the equator)"
    set climate-variable "Average minimum temperature (°C)"
    set start-year s-year
    set start-month s-month

    setup
  ]

  ls:ask model-tmax [
    set data-series "Historical monthly weather data"
    set data-resolution "10 minutes (~340 km2 at the equator)"
    set climate-variable "Average maximum temperature (°C)"
    set start-year s-year
    set start-month s-month

    setup
  ]

  ls:ask model-prec [
    set data-series "Historical monthly weather data"
    set data-resolution "10 minutes (~340 km2 at the equator)"
    set climate-variable "Total precipitation (mm)"
    set start-year s-year
    set start-month s-month

    setup
  ]
end

to go [#continuous? #update-plots? #wait?]
  assert-logical #continuous?
  assert-logical #update-plots?
  assert-logical #wait?

  set index index + 1
  walk #wait?

  if (#update-plots? = true) [update-plots]
  if (#continuous? = true) [tick]

  ls:ask ls:models [go true true true]

  set year [year] ls:of model-tmin
  set month [month] ls:of model-tmin
end

to go-back
  stop
end

to walk [#wait?]
  assert-logical #wait?

  foreach (combine range-pxcor range-pycor) [
    #comb -> ask patch (first #comb) (last #comb) [
      ls:let #comb #comb
      let lg-tmin [[value] of patch (first #comb) (last #comb)] ls:of model-tmin
      let lg-tmax [[value] of patch (first #comb) (last #comb)] ls:of model-tmax
      let lg-prec [[value] of patch (first #comb) (last #comb)] ls:of model-prec

      let random-mult 1

      if (add-random? = true) [
        set random-mult random-float random-mult-threshold
      ]

      if (
        ((lg-tmin <= 0) or (lg-tmin >= 0)) and
        ((lg-tmax <= 0) or (lg-tmax >= 0)) and
        ((lg-prec <= 0) or (lg-prec >= 0))
       ) [
        set value (
          intercept + (tmin-beta * lg-tmin) + (tmax-beta * lg-tmax) + (prec-beta * lg-prec)
        ) * random-mult
      ]

      if (value < 0) [set value 0]
    ]
  ]

  update-colors

  if (#wait? = true) [wait transition-seconds]
end

to update-colors
  ifelse (white-max = true) [
    set max-value max [value] of patches with [value >= -9999]
  ] [
    set max-value white-value
  ]

  ifelse (black-min = true) [
    set min-value min [value] of patches with [value >= -9999]
  ] [
    set min-value black-value
  ]

  ask (patches) [
    ifelse ((value <= 0) or (value >= 0)) [
      set pcolor scale-color rice-color value min-value max-value
    ] [
      set pcolor background-color
    ]
  ]
end

to-report combine [#list-1 #list-2]
  report ( reduce sentence ( map [ i -> map [ j -> list i j ] #list-2 ] #list-1 ))
end

to-report comb [_m _s]
  if (_m = 0) [ report [[]] ]
  if (_s = []) [ report [] ]
  let _rest butfirst _s
  let _lista map [? -> fput item 0 _s ?] comb (_m - 1) _rest
  let _listb comb _m _rest
  report (sentence _lista _listb)
end

to shock

end

to show-values
  ifelse mouse-inside? [
    ask patch mouse-xcor mouse-ycor [
      let radius-mean round mean [pcolor] of patches in-radius 3
      let color-shade radius-mean - (precision radius-mean -1)

      ifelse (color-shade < 0) [
        set plabel-color black
      ] [
        set plabel-color white
      ]

      carefully [
        set plabel precision value 2
      ] [
        set plabel value
      ]
    ]

    ask other patches who-are-not patch mouse-xcor mouse-ycor [
      set plabel ""
    ]
  ] [
    ask patches [set plabel ""]
  ]
end

to-report file-path [#string-1 #string-2]
  assert-string #string-1
  assert-string #string-2

  let middle-sep ""
  let separator pathdir:get-separator

  if (str-detect #string-1 "[A-Za-z0-9]$") [
    set middle-sep separator
  ]

  report (word
    #string-1
    middle-sep
    #string-2
  )
end

to-report fix-string-for-r [#path]
  assert-atomic #path

  let test true
  set #path as-character #path

  carefully [
    let r-test sr:runresult (word "'" #path "'")
  ] [
    set test false
  ]

  ifelse (test = false) [
    let separator pathdir:get-separator
    let double-separator rep-collapse separator 2
    let str-split string:split-on separator #path

    if (last str-split = "") [
      set str-split but-last str-split
    ]

    report collapse str-split double-separator
  ] [
    report #path
  ]
end

to-report load-patch-data [#file]
  assert-string #file
  assert-file-exists #file

  report gis:load-dataset #file
end

; Transform data from one scale to another
;
; @param x Value to rescale.
; @param a-min, a-max Values from the original range.
; @param b-min, b-max Values for the new target range.
to-report rescale [#x #a-min #a-max #b-min #b-max]
  report #b-min + ((#x - #a-min) / (#a-max - #a-min)) * (#b-max - #b-min)
end

; Brazil shape
; `gis:world-envelope`
; x_min = -74 | x_min = -28.833333333
; y_min = -33.75 | y_max = 5.416666666

; 10m
; Origin: Center of the World
; x_min = -135 | x_max = 135
; y_min = -117 | y_max = 117

; Set to 10m -> Change to automatic

to-report get-latitude [#pxcor]
  report rescale #pxcor -135 135 -74 -28.833333333
end

to-report get-longitude [#pycor]
  report rescale #pycor -117 117 -33.75 5.416666666
end
@#$#@#$#@
GRAPHICS-WINDOW
455
10
1005
489
-1
-1
2.0
1
10
1
1
1
0
0
0
1
-135
135
-117
117
0
0
1
Months
30.0

SLIDER
10
10
220
43
intercept
intercept
0
100
62.5
1
1
NIL
HORIZONTAL

SLIDER
10
48
220
81
tmin-beta
tmin-beta
0
5
0.525
0.01
1
NIL
HORIZONTAL

SLIDER
10
86
220
119
tmax-beta
tmax-beta
0
5
0.125
0.01
1
NIL
HORIZONTAL

SLIDER
10
124
220
157
prec-beta
prec-beta
0
5
1.635
0.01
1
NIL
HORIZONTAL

SLIDER
10
162
220
195
random-mult-threshold
random-mult-threshold
0
5
1.25
0.1
1
NIL
HORIZONTAL

SWITCH
10
200
220
233
add-random?
add-random?
1
1
-1000

CHOOSER
10
238
220
283
start-month
start-month
"January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December"
0

INPUTBOX
10
288
220
348
start-year
1960.0
1
0
Number

BUTTON
10
353
220
388
Select data directory
set data-path user-directory
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
10
393
220
453
data-path
../data/
1
0
String

BUTTON
10
458
220
493
Select LogoClim file
set logoclim-path user-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
10
498
220
558
logoclim-path
../../logoclim/nlogo/logoclim.nlogo
1
0
String

BUTTON
230
10
330
45
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
340
10
440
45
Go
go true true true
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

BUTTON
230
50
330
85
Go back
go-back
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

BUTTON
340
50
440
85
Go forward
go false false false
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

SLIDER
230
90
440
123
transition-seconds
transition-seconds
0
3
0.0
0.1
1
s
HORIZONTAL

SLIDER
230
128
440
161
patch-px-size
patch-px-size
0
10
2.0
0.01
1
px
HORIZONTAL

SWITCH
230
166
440
199
interactive
interactive
1
1
-1000

INPUTBOX
230
204
440
264
rice-color
64.0
1
0
Color

INPUTBOX
230
269
440
329
background-color
9.0
1
0
Color

SLIDER
230
334
440
367
black-value
black-value
-500
500
0.0
1
1
NIL
HORIZONTAL

SWITCH
230
372
440
405
black-min
black-min
1
1
-1000

SLIDER
230
410
440
443
white-value
white-value
-500
500
50.0
1
1
NIL
HORIZONTAL

SWITCH
230
448
440
481
white-max
white-max
0
1
-1000

BUTTON
230
486
440
521
Show values
show-values
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
1020
10
1120
55
Year
year
0
1
11

MONITOR
1130
10
1230
55
Month
month-monitor month
0
1
11

PLOT
1020
60
1230
240
Mean
Months
Value
0.0
0.0
0.0
0.0
true
false
"set-plot-y-range min-plot-y max-plot-y" ""
PENS
"default" 0.5 0 -16777216 true "" "plot mean [value] of patches with [value >= -99999]"

MONITOR
1020
245
1230
290
Mean
mean [value] of patches with [value >= -99999]
10
1
11

PLOT
1020
295
1230
475
Minimum
Months
Value
0.0
0.0
0.0
0.0
true
false
"set-plot-y-range min-plot-y max-plot-y" ""
PENS
"default" 0.5 0 -16777216 true "" "plot min [value] of patches with [value >= -99999]"

MONITOR
1020
480
1230
525
Minimum
min [value] of patches with [value >= -99999]
10
1
11

PLOT
1240
60
1450
240
Standard Deviation
Months
Value
0.0
0.0
0.0
0.0
true
false
"set-plot-y-range min-plot-y max-plot-y" ""
PENS
"default" 0.5 0 -16777216 true "" "plot standard-deviation [value] of patches with [value >= -99999]"

MONITOR
1240
245
1450
290
Standard deviation
standard-deviation [value] of patches with [value >= -99999]
10
1
11

PLOT
1240
295
1450
475
Maximum
Months
Value
0.0
0.0
0.0
0.0
true
false
"set-plot-y-range min-plot-y max-plot-y" ""
PENS
"default" 0.5 0 -16777216 true "" "plot max [value] of patches with [value >= -99999]"

MONITOR
1240
480
1450
525
Maximum
max [value] of patches with [value >= -99999]
10
1
11

PLOT
1460
60
1670
240
Value Distribution
NIL
Frequency
0.0
0.0
0.0
0.0
true
false
"let min-plot-x floor (min [value] of patches with [value >= -99999])\nlet max-plot-x ceiling (max [value] of patches with [value >= -99999])\nset-plot-x-range min-plot-x (max-plot-x)\nset-histogram-num-bars 30" "let min-plot-x floor (min [value] of patches with [value >= -99999])\nlet max-plot-x ceiling (max [value] of patches with [value >= -99999])\nset-plot-x-range min-plot-x (max-plot-x)\nset-histogram-num-bars 30"
PENS
"default" 1.0 1 -16777216 true "" "histogram [value] of patches with [value >= -99999]"

PLOT
1460
295
1670
475
Observed Mean Deviation
NIL
P Diff
0.0
0.0
-10.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot 1 - (mean ([value] of patches with [value >= -99999]))"

MONITOR
1460
480
1670
525
Observed mean deviation
1 - (mean ([value] of patches with [value >= -99999]))
5
1
11

BUTTON
230
525
440
561
Shock
shock
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
# RICE: RICE PRODUCTION IN NETLOGO

Developer version.
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
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
1
@#$#@#$#@
