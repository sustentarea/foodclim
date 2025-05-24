; FoodClim: Simulating Food Yield Responses to Climate Change in Netlogo
;
; Version: 2025-05-23 0.0.0.9000
; Authors: Daniel Vartanian, Leandro M. T. Garcia, & Aline M. de Carvalho.
; Maintainer: Daniel Vartanian <https://github.com/danielvartan>.
; License: MIT.
; Repository: https://github.com/sustentarea/foodclim/
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
  index
  month
  year
  max-value
  min-value
  min-plot-y
  max-plot-y
  range-pxcor
  range-pycor
  patch-coordinates
  seed
  tmin-ls-model
  tmax-ls-model
  prec-ls-model
  grains-res-model
  protein-res-model
  non-leafy-veg-res-model
  leafy-veg-res-model
  fruits-res-model
  dairy-res-model
  flip-index ; To use with `flip-data-series?`.
  temp ; To use with `run`.
]

patches-own [
  value
  tmin
  tmax
  prec
  latitude
  longitude
  grains-yield
  protein-yield
  non-leafy-veg-yield
  leafy-veg-yield
  fruits-yield
  dairy-yield
]

to setup [#seed]
  clear-all

  set seed #seed
  random-seed #seed

  ls:reset
  sr:setup

  set start-year normalize-year start-year

  setup-logoclim
  setup-world
  setup-variables
  setup-patches
  setup-stats

  reset-ticks
end

to setup-logoclim
  ifelse (interactive = true) [
    ls:create-interactive-models 3 logoclim-path
  ] [
    ls:create-models 3 logoclim-path
  ]

  set tmin-ls-model 0
  set tmax-ls-model 1
  set prec-ls-model 2

  ls:let #data-series data-series
  ls:let #data-resolution data-resolution
  ls:let #global-climate-model global-climate-model
  ls:let #shared-socioeconomic-pathway shared-socioeconomic-pathway
  ls:let #year start-year
  ls:let #month start-month

  ls:ask ls:models [
    set data-series #data-series
    set data-resolution #data-resolution
    set global-climate-model #global-climate-model
    set shared-socioeconomic-pathway #shared-socioeconomic-pathway
    set start-year #year
    set start-month #month
  ]

  ls:ask tmin-ls-model [
    set climate-variable "Average minimum temperature (°C)"
  ]

  ls:ask tmax-ls-model [
    set climate-variable "Average maximum temperature (°C)"
  ]

  ls:ask prec-ls-model [
    set climate-variable "Total precipitation (mm)"
  ]

  ls:ask ls:models [setup]
end

to setup-world
  let min-width [min-pxcor] ls:of tmin-ls-model
  let max-width [max-pxcor] ls:of tmin-ls-model
  let min-height [min-pycor] ls:of tmin-ls-model
  let max-height [max-pycor] ls:of tmin-ls-model

  resize-world min-width max-width min-height max-height
  set-patch-size patch-px-size
end

to setup-variables
  set index [index] ls:of tmin-ls-model
  set range-pxcor (range min-pxcor (max-pxcor + 1))
  set range-pycor (range min-pycor (max-pycor + 1))
  set patch-coordinates combine range-pxcor range-pycor
  set year [year] ls:of tmin-ls-model
  set month [month] ls:of tmin-ls-model

  set grains-res-model parse-res-model-string grains-response-model
  set protein-res-model parse-res-model-string protein-response-model
  set non-leafy-veg-res-model parse-res-model-string non-leafy-veg-response-model
  set leafy-veg-res-model parse-res-model-string leafy-veg-response-model
  set fruits-res-model parse-res-model-string fruits-response-model
  set dairy-res-model parse-res-model-string dairy-response-model
end

to setup-patches
  foreach (patch-coordinates) [
    #i -> ask patch (first #i) (last #i) [
      ls:let #i #i
      set tmin [[value] of patch (first #i) (last #i)] ls:of tmin-ls-model
      set tmax [[value] of patch (first #i) (last #i)] ls:of tmax-ls-model
      set prec [[value] of patch (first #i) (last #i)] ls:of prec-ls-model
      set latitude mean [[latitude] of patch (first #i) (last #i)] ls:of tmin-ls-model
      set longitude mean [[longitude] of patch (first #i) (last #i)] ls:of tmin-ls-model

      set value tmin
      set grains-yield tmin
      set protein-yield tmin
      set non-leafy-veg-yield tmin
      set leafy-veg-yield tmin
      set fruits-yield tmin
      set dairy-yield tmin
    ]
  ]

  compute-yield
  update-patches
  update-colors
end

to setup-stats
  set max-value max (list
    max [grains-yield] of patches with [(value <= 0) or (value >= 0)]
    max [protein-yield] of patches with [(value <= 0) or (value >= 0)]
    max [non-leafy-veg-yield] of patches with [(value <= 0) or (value >= 0)]
    max [leafy-veg-yield] of patches with [(value <= 0) or (value >= 0)]
    max [fruits-yield] of patches with [(value <= 0) or (value >= 0)]
    max [dairy-yield] of patches with [(value <= 0) or (value >= 0)]
  )

  set min-value min (list
    min [grains-yield] of patches with [(value <= 0) or (value >= 0)]
    min [protein-yield] of patches with [(value <= 0) or (value >= 0)]
    min [non-leafy-veg-yield] of patches with [(value <= 0) or (value >= 0)]
    min [leafy-veg-yield] of patches with [(value <= 0) or (value >= 0)]
    min [fruits-yield] of patches with [(value <= 0) or (value >= 0)]
    min [dairy-yield] of patches with [(value <= 0) or (value >= 0)]
  )

  ;set max-plot-y ceiling max-value
  set min-plot-y ifelse-value (min-value < 0) [floor min-value] [0]
  ;set min-plot-y floor ((quartile 1) - (6 * (quartile "iqr")))
  set max-plot-y ceiling ((quartile 3) + (3 * (quartile "iqr")))
end

to go [#tick? #wait?]
  assert-logical #tick?
  assert-logical #wait?

  ls:ask ls:models [go true true]

  if (month = [month] ls:of tmin-ls-model) [
    ifelse (
      (flip-data-series? = true) and
      ([data-series] ls:of tmin-ls-model != "Future climate data")
    ) [
      set flip-index index

      ls:let #global-climate-model global-climate-model
      ls:let #shared-socioeconomic-pathway shared-socioeconomic-pathway

      ls:ask ls:models [
        set data-series "Future climate data"
        set global-climate-model #global-climate-model
        set shared-socioeconomic-pathway #shared-socioeconomic-pathway
        set start-month "January"

        setup
      ]
    ] [
      stop
    ]
  ]

  set index [index] ls:of tmin-ls-model
  set year [year] ls:of tmin-ls-model
  set month [month] ls:of tmin-ls-model

  update-climate-vars
  compute-yield
  update-patches

  set index [index] ls:of tmin-ls-model
  set year [year] ls:of tmin-ls-model
  set month [month] ls:of tmin-ls-model

  update-climate-vars
  compute-yield
  update-patches

  if (#tick? = true) [tick]
  if (#wait? = true) [wait transition-seconds]
end

to go-back
  ls:ask ls:models [go-back]

  if (month = [month] ls:of tmin-ls-model) [
    ifelse (
      (flip-data-series? = true) and
      ([data-series] ls:of tmin-ls-model = "Future climate data")
    ) [
      ls:let #index flip-index
      ls:let #year start-year
      ls:let #month start-month

      ls:ask ls:models [
        set data-series "Historical monthly weather data"
        set start-year #year
        set start-month #month

        setup

        set index #index
        set year 2021
        set month 12
      ]
    ] [
      stop
    ]
  ]

  set index [index] ls:of tmin-ls-model
  set year [year] ls:of tmin-ls-model
  set month [month] ls:of tmin-ls-model

  update-climate-vars
  compute-yield
  update-patches
end

to update-climate-vars
  foreach (patch-coordinates) [
    #i -> ask patch (first #i) (last #i) [
      ls:let #i #i
      set tmin [[value] of patch (first #i) (last #i)] ls:of tmin-ls-model
      set tmax [[value] of patch (first #i) (last #i)] ls:of tmax-ls-model
      set prec [[value] of patch (first #i) (last #i)] ls:of prec-ls-model
    ]
  ]

  ask patches with [(tmin <= 0) or (tmin >= 0)] [
    set tmin tmin + raise-lower-tmin
    set tmax tmax + raise-lower-tmax
    set prec prec + raise-lower-prec
  ]
end

to compute-yield
  compute-food-yield "grains"
  compute-food-yield "protein"
  compute-food-yield "dairy"
  compute-food-yield "non-leafy-veg"
  compute-food-yield "leafy-veg"
  compute-food-yield "fruits"
end

to compute-food-yield [#food]
  ask patches with [
    (runresult (word #food "-yield") <= 0) or
    (runresult (word #food "-yield") >= 0)
  ] [
    let random-mult 1
    let intercept runresult (word #food "-intercept")
    let tmin-beta runresult (word #food "-tmin-beta")
    let tmax-beta runresult (word #food "-tmax-beta")
    let prec-beta runresult (word #food "-prec-beta")
    let lat-beta runresult (word #food "-lat-beta")
    let lon-beta runresult (word #food "-lon-beta")

    if (add-random? = true) [
      let random-threshold runresult (word #food "-" "random-threshold")
      set random-mult random-float random-threshold

      ifelse (random-float 1 < 0.5) [
        set random-mult 1 - random-mult
      ] [
        set random-mult 1 + random-mult
      ]
    ]

    ifelse (
      ((tmin <= 0) or (tmin >= 0)) and
      ((tmax <= 0) or (tmax >= 0)) and
      ((prec <= 0) or (prec >= 0))
     ) [
      set temp (
        intercept +
        (tmin-beta * tmin) + (tmax-beta * tmax) + (prec-beta * prec) +
        (lat-beta * latitude) + (lon-beta * longitude)
      ) * random-mult

      if (shock = true) [
        set random-mult random-float shock-threshold
        set temp temp * (1 - random-mult)
      ]

      if (temp < 0) [set temp 0]

      run (word "set " #food "-yield temp")
    ] [
      set temp tmin

      run (word "set " #food "-yield temp")
    ]
  ]
end

to update-patches
  let food food-lookup world-view

  ask patches with [(value <= 0) or (value >= 0)] [
    run (word "set value " food "-yield")
  ]

  update-colors
end

to update-colors
  let food-color lime

  (ifelse
    (world-view = "Grains") [
    set food-color orange
  ] (world-view = "Protein") [
    set food-color violet
  ] (world-view = "Non-leafy vegetables") [
    set food-color lime
  ] (world-view = "Leafy vegetables") [
    set food-color turquoise
  ] (world-view = "Fruits") [
    set food-color red
  ] (world-view = "Dairy") [
    set food-color blue
  ] [
    user-message "Invalid value in `world-view`."
  ])

  ifelse (white-max = true) [
    set max-value max [value] of patches with [(value <= 0) or (value >= 0)]
  ] [
    set max-value white-value
  ]

  ifelse (black-min = true) [
    set min-value min [value] of patches with [(value <= 0) or (value >= 0)]
  ] [
    set min-value black-value
  ]

  ask (patches) [
    ifelse ((value <= 0) or (value >= 0)) [
      set pcolor scale-color food-color value min-value max-value
    ] [
      set pcolor background-color
    ]
  ]
end

to-report food-lookup [#string]
  assert-string #string

  (ifelse
    (#string = "Grains") [report "grains"]
    (#string = "Protein") [report "protein"]
    (#string = "Dairy") [report "dairy"]
    (#string = "Non-leafy vegetables") [report "non-leafy-veg"]
    (#string = "Leafy vegetables") [report "leafy-veg"]
    (#string = "Fruits") [report "fruits"]
    [
      user-message (word
        "The value '" #string  "' was not found."
      )
    ]
  )
end

to-report combine [#list-1 #list-2]
  report ( reduce sentence ( map [ i -> map [ j -> list i j ] #list-2 ] #list-1 ))
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

to-report parse-res-model-string [#string]
  assert-string #string

  report 0
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
730
220
763
grains-intercept
grains-intercept
-100
100
71.8
0.1
1
NIL
HORIZONTAL

SLIDER
10
768
220
801
grains-tmin-beta
grains-tmin-beta
-10
10
-2.1
0.1
1
NIL
HORIZONTAL

SLIDER
10
806
220
839
grains-tmax-beta
grains-tmax-beta
-10
10
-3.5
0.1
1
NIL
HORIZONTAL

SLIDER
10
844
220
877
grains-prec-beta
grains-prec-beta
-10
10
4.77
0.01
1
NIL
HORIZONTAL

SLIDER
10
882
220
915
grains-lat-beta
grains-lat-beta
-10
5
-7.69
0.01
1
NIL
HORIZONTAL

SLIDER
10
920
220
953
grains-lon-beta
grains-lon-beta
-10
10
-8.4
0.1
1
NIL
HORIZONTAL

SLIDER
10
960
220
993
grains-random-threshold
grains-random-threshold
0
1
0.25
0.1
1
NIL
HORIZONTAL

SWITCH
455
505
665
538
add-random?
add-random?
0
1
-1000

CHOOSER
10
210
220
255
start-month
start-month
"January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December"
0

INPUTBOX
10
260
220
320
start-year
2020.0
1
0
Number

BUTTON
10
325
220
360
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
365
220
425
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
setup new-seed
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
go true true
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
go false false
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
255
440
315
background-color
9.0
1
0
Color

SLIDER
230
320
440
353
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
358
440
391
black-min
black-min
1
1
-1000

SLIDER
230
396
440
429
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
434
440
467
white-max
white-max
0
1
-1000

BUTTON
230
472
440
507
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
1450
240
Kilogram per Hectare (Mean)
Months
Value
0.0
0.0
0.0
0.0
true
true
"set-plot-y-range min-plot-y max-plot-y" ""
PENS
"Grains" 1.0 0 -955883 true "" "if (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color orange + 3\n]\n\nplot mean [grains-yield] of patches with [(value <= 0) or (value >= 0)]"
"Protein" 1.0 0 -8630108 true "" "if (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color violet + 3\n]\n\nplot mean [protein-yield] of patches with [(value <= 0) or (value >= 0)]"
"Dairy" 1.0 0 -13345367 true "" "if (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color blue + 3\n]\n\nplot mean [dairy-yield] of patches with [(value <= 0) or (value >= 0)]"
"Non-leafy veg." 1.0 0 -13840069 true "" "if (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color lime + 3\n]\n\nplot mean [non-leafy-veg-yield] of patches with [(value <= 0) or (value >= 0)]"
"Leafy veg." 1.0 0 -14835848 true "" "if (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color turquoise + 3\n]\n\nplot mean [leafy-veg-yield] of patches with [(value <= 0) or (value >= 0)]"
"Fruits" 1.0 0 -2674135 true "" "if (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color red + 3\n]\n\nplot mean [fruits-yield] of patches with [(value <= 0) or (value >= 0)]"

MONITOR
1020
430
1230
475
Mean (world-view)
mean [value] of patches with [(value <= 0) or (value >= 0)]
10
1
11

MONITOR
1020
480
1230
525
Minimum (world-view)
min [value] of patches with [(value <= 0) or (value >= 0)]
10
1
11

PLOT
1020
245
1450
425
Kilogram per Hectare (Standard Deviation)
Months
Value
0.0
0.0
0.0
0.0
true
true
"set-plot-y-range min-plot-y max-plot-y" ""
PENS
"Grains" 1.0 0 -955883 true "" "if (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color orange + 3\n]\n\nplot standard-deviation [grains-yield] of patches with [(value <= 0) or (value >= 0)]"
"Protein" 1.0 0 -8630108 true "" "if (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color violet + 3\n]\n\nplot standard-deviation [protein-yield] of patches with [(value <= 0) or (value >= 0)]"
"Dairy" 1.0 0 -13345367 true "" "if (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color blue + 3\n]\n\nplot standard-deviation [dairy-yield] of patches with [(value <= 0) or (value >= 0)]"
"Non-leafy veg." 1.0 0 -13840069 true "" "if (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color lime + 3\n]\n\nplot standard-deviation [non-leafy-veg-yield] of patches with [(value <= 0) or (value >= 0)]"
"Leafy veg." 1.0 0 -14835848 true "" "if (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color turquoise + 3\n]\n\nplot standard-deviation [leafy-veg-yield] of patches with [(value <= 0) or (value >= 0)]"
"Fruits" 1.0 0 -2674135 true "" "if (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color red + 3\n]\n\nplot standard-deviation [fruits-yield] of patches with [(value <= 0) or (value >= 0)]"

MONITOR
1240
430
1450
475
Standard deviation (world-view)
standard-deviation [value] of patches with [(value <= 0) or (value >= 0)]
10
1
11

MONITOR
1240
480
1450
525
Maximum (world-view)
max [value] of patches with [(value <= 0) or (value >= 0)]
10
1
11

CHOOSER
10
10
220
55
data-series
data-series
"Historical monthly weather data" "Future climate data"
0

CHOOSER
10
60
220
105
data-resolution
data-resolution
"30 seconds (~1 km2  at the equator)" "2.5 minutes (~21 km2 at the equator)" "5 minutes (~85 km2 at the equator)" "10 minutes (~340 km2 at the equator)"
3

CHOOSER
10
110
220
155
global-climate-model
global-climate-model
"ACCESS-CM2" "BCC-CSM2-MR" "CMCC-ESM2" "EC-Earth3-Veg" "FIO-ESM-2-0" "GFDL-ESM4" "GISS-E2-1-G" "HadGEM3-GC31-LL" "INM-CM5-0" "IPSL-CM6A-LR" "MIROC6" "MPI-ESM1-2-HR" "MRI-ESM2-0" "UKESM1-0-LL"
2

CHOOSER
10
160
220
205
shared-socioeconomic-pathway
shared-socioeconomic-pathway
"SSP-126" "SSP-245" "SSP-370" "SSP-585"
3

TEXTBOX
580
600
870
620
Parameters for Food Group Yield Response
14
0.0
1

SLIDER
255
730
465
763
protein-intercept
protein-intercept
-100
100
26.7
0.1
1
NIL
HORIZONTAL

CHOOSER
230
205
440
250
world-view
world-view
"Grains" "Protein" "Dairy" "Non-leafy vegetables" "Leafy vegetables" "Fruits"
0

SLIDER
255
770
465
803
protein-tmin-beta
protein-tmin-beta
-10
10
3.6
0.1
1
NIL
HORIZONTAL

SLIDER
255
810
465
843
protein-tmax-beta
protein-tmax-beta
-10
10
0.4
0.1
1
NIL
HORIZONTAL

SLIDER
255
850
465
883
protein-prec-beta
protein-prec-beta
-10
10
4.2
0.1
1
NIL
HORIZONTAL

SLIDER
255
885
465
918
protein-lat-beta
protein-lat-beta
-10
10
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
255
920
465
953
protein-lon-beta
protein-lon-beta
-10
10
0.6
0.1
1
NIL
HORIZONTAL

SLIDER
255
960
465
993
protein-random-threshold
protein-random-threshold
0
1
0.25
0.1
1
NIL
HORIZONTAL

SLIDER
755
730
965
763
non-leafy-veg-intercept
non-leafy-veg-intercept
0
100
33.4
0.1
1
NIL
HORIZONTAL

SLIDER
755
770
965
803
non-leafy-veg-tmin-beta
non-leafy-veg-tmin-beta
0
10
2.2
0.1
1
NIL
HORIZONTAL

SLIDER
755
810
965
843
non-leafy-veg-tmax-beta
non-leafy-veg-tmax-beta
0
10
1.8
0.1
1
NIL
HORIZONTAL

SLIDER
755
850
965
883
non-leafy-veg-prec-beta
non-leafy-veg-prec-beta
0
10
3.0
0.1
1
NIL
HORIZONTAL

SLIDER
755
885
965
918
non-leafy-veg-lat-beta
non-leafy-veg-lat-beta
0
10
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
755
920
965
953
non-leafy-veg-lon-beta
non-leafy-veg-lon-beta
0
10
0.7
0.1
1
NIL
HORIZONTAL

SLIDER
755
960
965
993
non-leafy-veg-random-threshold
non-leafy-veg-random-threshold
0
1
0.25
0.1
1
NIL
HORIZONTAL

SLIDER
995
730
1205
763
leafy-veg-intercept
leafy-veg-intercept
0
100
68.7
0.1
1
NIL
HORIZONTAL

SLIDER
995
770
1205
803
leafy-veg-tmin-beta
leafy-veg-tmin-beta
0
10
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
995
810
1205
843
leafy-veg-tmax-beta
leafy-veg-tmax-beta
0
10
2.3
0.1
1
NIL
HORIZONTAL

SLIDER
995
850
1205
883
leafy-veg-prec-beta
leafy-veg-prec-beta
0
10
8.7
0.1
1
NIL
HORIZONTAL

SLIDER
995
890
1205
923
leafy-veg-lat-beta
leafy-veg-lat-beta
0
10
2.7
0.1
1
NIL
HORIZONTAL

SLIDER
995
925
1205
958
leafy-veg-lon-beta
leafy-veg-lon-beta
0
10
1.1
0.1
1
NIL
HORIZONTAL

SLIDER
995
960
1205
993
leafy-veg-random-threshold
leafy-veg-random-threshold
0
1
0.25
0.1
1
NIL
HORIZONTAL

SLIDER
1240
730
1450
763
fruits-intercept
fruits-intercept
0
100
10.0
0.1
1
NIL
HORIZONTAL

SLIDER
1240
770
1450
803
fruits-tmin-beta
fruits-tmin-beta
0
10
1.4
0.1
1
NIL
HORIZONTAL

SLIDER
1240
810
1450
843
fruits-tmax-beta
fruits-tmax-beta
0
10
1.9
0.1
1
NIL
HORIZONTAL

SLIDER
1240
850
1450
883
fruits-prec-beta
fruits-prec-beta
0
10
3.2
0.1
1
NIL
HORIZONTAL

SLIDER
1240
890
1450
923
fruits-lat-beta
fruits-lat-beta
0
10
0.6
0.1
1
NIL
HORIZONTAL

SLIDER
1240
925
1450
958
fruits-lon-beta
fruits-lon-beta
0
10
5.6
0.1
1
NIL
HORIZONTAL

SLIDER
1240
960
1450
993
fruits-random-threshold
fruits-random-threshold
0
1
0.25
0.1
1
NIL
HORIZONTAL

SLIDER
505
730
715
763
dairy-intercept
dairy-intercept
0
100
45.0
0.1
1
NIL
HORIZONTAL

SLIDER
505
770
715
803
dairy-tmin-beta
dairy-tmin-beta
0
10
3.75
0.1
1
NIL
HORIZONTAL

SLIDER
505
810
715
843
dairy-tmax-beta
dairy-tmax-beta
0
10
3.8
0.1
1
NIL
HORIZONTAL

SLIDER
505
850
715
883
dairy-prec-beta
dairy-prec-beta
0
10
6.5
0.1
1
NIL
HORIZONTAL

SLIDER
505
885
715
918
dairy-lat-beta
dairy-lat-beta
0
10
2.6
0.1
1
NIL
HORIZONTAL

SLIDER
505
920
715
953
dairy-lon-beta
dairy-lon-beta
0
10
5.6
0.1
1
NIL
HORIZONTAL

SLIDER
505
960
715
993
dairy-random-threshold
dairy-random-threshold
0
1
0.25
0.1
1
NIL
HORIZONTAL

SLIDER
795
505
1005
538
shock-threshold
shock-threshold
0
5
1.0
0.1
1
NIL
HORIZONTAL

INPUTBOX
10
640
220
725
grains-response-model
#yield = #intercept + (#tmin-beta * #tmin) + (#tmax-beta * #tmax) + (#prec-beta * #prec) + (#latitude-beta * #latituude) + (#longitude-beta * #longitude)
1
0
String

INPUTBOX
255
640
465
725
protein-response-model
#yield = #intercept + (#tmin-beta * #tmin) + (#tmax-beta * #tmax) + (#prec-beta * #prec) + (#latitude-beta * #latituude) + (#longitude-beta * #longitude)
1
0
String

INPUTBOX
505
640
715
725
dairy-response-model
#yield = #intercept + (#tmin-beta * #tmin) + (#tmax-beta * #tmax) + (#prec-beta * #prec) + (#latitude-beta * #latituude) + (#longitude-beta * #longitude)
1
0
String

INPUTBOX
755
640
965
725
non-leafy-veg-response-model
#yield = #intercept + (#tmin-beta * #tmin) + (#tmax-beta * #tmax) + (#prec-beta * #prec) + (#latitude-beta * #latituude) + (#longitude-beta * #longitude)
1
0
String

INPUTBOX
995
640
1205
725
leafy-veg-response-model
#yield = #intercept + (#tmin-beta * #tmin) + (#tmax-beta * #tmax) + (#prec-beta * #prec) + (#latitude-beta * #latituude) + (#longitude-beta * #longitude)
1
0
String

INPUTBOX
1240
640
1450
725
fruits-response-model
#yield = #intercept + (#tmin-beta * #tmin) + (#tmax-beta * #tmax) + (#prec-beta * #prec) + (#latitude-beta * #latituude) + (#longitude-beta * #longitude)
1
0
String

SWITCH
10
430
220
463
flip-data-series?
flip-data-series?
0
1
-1000

SLIDER
455
545
630
578
raise-lower-tmin
raise-lower-tmin
-10
10
0.0
0.1
1
ºC
HORIZONTAL

SLIDER
640
545
820
578
raise-lower-tmax
raise-lower-tmax
-10
10
0.0
0.1
1
ºC
HORIZONTAL

SLIDER
830
545
1005
578
raise-lower-prec
raise-lower-prec
-250
250
0.0
0.1
1
mm
HORIZONTAL

SWITCH
675
505
785
538
shock
shock
1
1
-1000

MONITOR
1240
10
1450
55
Data series
[data-series] ls:of tmin-ls-model
0
1
11

@#$#@#$#@
# FOODCLIM: SIMULATING FOOD YIELD RESPONSES TO CLIMATE CHANGE IN NETLOGO

You are currently using the developer version of `FoodClim`.

### TO DO

- Fix interface proportions.
- Implmenent string response functions.
- Separate util functions.
- Reveise and refactor code.

## HOW TO USE IT

Refer to the [`LogoClim`](https://github.com/sustentarea/logoclim) installation guide for detailed steps on installing the required dependencies.

Once `LogoClim` is installed, you can run the `FoodClim` model by specifying the path to your `LogoClim` installation in the `FoodClim` interface. This allows `FoodClim` to access climate data provided by `LogoClim` during simulations.

### BEHAVIOR NOTES

Due to the use of empirical data, the world and charts may experience some delay. However, it’s important to note the order of events: the world will always update **before** the charts.

If `flip-series?` is on, the color of the chart series will slightly fade at the point where the flip occurs.

## HOW TO CITE

If you use this model in your research, please cite it to acknowledge the effort invested in its development and maintenance. Your citation helps support the ongoing improvement of the model.

To cite `FoodClim` in publications please use the following format:

Vartanian, D., & Carvalho, A. M. (2025). *FoodClim: Simulating food yield responses to climate change in NetLogo* [Computer software, NetLogo model]. <https://doi.org/10.17605/OSF.IO/ZGVMP>

A BibTeX entry for LaTeX users is:

```latex
@Misc{vartanian2025,
  title = {FoodClim: Simulating food production responses to climate change in NetLogo},
  author = {{Daniel Vartanian} and {Aline Martins de Carvalho}},
  year = {2025},
  doi = {https://doi.org/10.17605/OSF.IO/ZGVMP},
  note = {NetLogo model}
}
```

## HOW TO CONTRIBUTE

![Contributor Covenant 2.1 badge](images/contributor-covenant-2-1-badge.png)

Contributions are welcome! Whether it's reporting bugs, suggesting features, or improving documentation, your input is valuable.

![GitHub Sponsor badge](images/github-sponsor-badge.png)

You can also support the development of `FoodClim` by becoming a sponsor. Click [here](https://github.com/sponsors/danielvartan) to make a donation. Please mention `FoodClim` in your donation message.

## IMPORTANT LINKS

- Project repository: https://doi.org/10.17605/OSF.IO/ZGVMP
- Code repository: https://github.com/sustentarea/foodclim
- Latest release: https://github.com/sustentarea/foodclim/releases/latest
- Support development: https://github.com/sponsors/danielvartan

## LICENSE

![MIT license badge](images/mit-license-badge.png)

The `FoodClim` code is licensed under the [MIT License](https://opensource.org/license/mit). This means you can use, modify, and distribute the code freely, as long as you include the original license and copyright notice in any copies or substantial portions of the software.

## ACKNOWLEDGMENTS

We gratefully acknowledge the contributions of [Stephen E. Fick](https://orcid.org/0000-0002-3548-6966), [Robert J. Hijmans](https://orcid.org/0000-0001-5872-2872), and the entire [WorldClim](https://worldclim.org/) team for their dedication to creating and maintaining the WorldClim datasets. Their work has been instrumental in enabling researchers and practitioners to access high-quality climate data.

We also acknowledge the World Climate Research Programme ([WCRP](https://www.wcrp-climate.org/)), which, through its Working Group on Coupled Modelling, coordinated and promoted the Coupled Model Intercomparison Project Phase 6 ([CMIP6](https://pcmdi.llnl.gov/CMIP6/)).

We thank the climate modeling groups for producing and sharing their model outputs, the Earth System Grid Federation ([ESGF](https://esgf.llnl.gov/)) for archiving and providing access to the data, and the many funding agencies that support CMIP6 and ESGF.

![Sustentarea logo](images/sustentarea-logo.png)

`FoodClim` was developed with support from the Research and Extension Center [Sustentarea](https://github.com/sustentarea/) at the University of São Paulo ([USP](https://www.usp.br/)). It was originally created as part of a Sustentarea research project.

![CNPq logo](images/cnpq-logo.png)

This project was supported by the Conselho Nacional de Desenvolvimento Científico e Tecnológico - Brazil ([CNPq](https://www.gov.br/cnpq/)).

## REFERENCES

Firpo, M. Â. F., Guimarães, B. dos S., Dantas, L. G., Silva, M. G. B. da, Alves, L. M., Chadwick, R., Llopart, M. P., & Oliveira, G. S. de. (2022). Assessment of CMIP6 models’ performance in simulating present-day climate in Brazil. *Frontiers in Climate*, *4*. <https://doi.org/10.3389/fclim.2022.948499>

Vartanian, D., Garcia, L. M. T., & Carvalho, A. M. (2025). *FoodClim: WorldClim in NetLogo* [Computer software, NetLogo model]. <https://doi.org/10.17605/OSF.IO/EAPZU>
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
