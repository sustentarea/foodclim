; FoodClim: Simulating Food Yield Responses to Climate Change in Netlogo
;
; Version: 2025-07-14 0.0.0.9002
; Authors: Daniel Vartanian, Leandro Garcia, & Aline M. de Carvalho
; Maintainer: Daniel Vartanian <https://github.com/danielvartan>
; License: MIT
; Repository: https://github.com/sustentarea/foodclim
;
; Require NetLogo >= 6.4 and the LogoClim NetLogo model.
; Required NetLogo extensions: `ls` and `string`.

__includes [
  "nls/as-list.nls"
  "nls/as-string.nls"
  "nls/check-all.nls"
  "nls/check-atomic.nls"
  "nls/check-between.nls"
  "nls/check-choice.nls"
  "nls/check-empty.nls"
  "nls/check-integer.nls"
  "nls/check-list.nls"
  "nls/check-logical.nls"
  "nls/check-missing.nls"
  "nls/check-nan.nls"
  "nls/check-number.nls"
  "nls/check-tick-window.nls"
  "nls/check-start-year.nls"
  "nls/check-string.nls"
  "nls/check-string-or-integer.nls"
  "nls/check-true.nls"
  "nls/collapse.nls"
  "nls/combine.nls"
  "nls/compute-food-yield.nls"
  "nls/compute-random-mult.nls"
  "nls/compute-yield-value.nls"
  "nls/compute-yield-baseline.nls"
  "nls/compute-yield-response.nls"
  "nls/go-back.nls"
  "nls/halt.nls"
  "nls/lookup-food-group.nls"
  "nls/num-to-str-month.nls"
  "nls/plot-max-y.nls"
  "nls/plot-pen-color.nls"
  "nls/quartile.nls"
  "nls/raise-lower-patch-value.nls"
  "nls/setup-logoclim.nls"
  "nls/setup-patches.nls"
  "nls/setup-stats.nls"
  "nls/setup-variables.nls"
  "nls/setup-world.nls"
  "nls/show-values.nls"
  "nls/single-quote.nls"
  "nls/str-extract.nls"
  "nls/str-to-num-month.nls"
  "nls/update-climate-vars.nls"
  "nls/update-patches.nls"
]

extensions [
  ls
  string
]

globals [
  index
  month
  year
  baseline-period
  max-value
  min-value
  range-pxcor
  range-pycor
  patch-coordinates
  plot-x-max-range
  tmin-ls-model
  tmax-ls-model
  prec-ls-model
  flip-index ; To use with `flip-data-series?`.
  temp ; To use with `run`.
  seed
  settings
]

patches-own [
  value
  value-baseline
  value-baseline-rel
  tmin
  tmax
  prec
  latitude
  longitude
  grains-yield
  grains-yield-baseline-1
  grains-yield-baseline-2
  grains-yield-baseline-3
  grains-yield-baseline-4
  grains-yield-baseline-5
  grains-yield-baseline-6
  grains-yield-baseline-7
  grains-yield-baseline-8
  grains-yield-baseline-9
  grains-yield-baseline-10
  grains-yield-baseline-11
  grains-yield-baseline-12
  grains-yield-baseline-rel
  protein-yield
  protein-yield-baseline-1
  protein-yield-baseline-2
  protein-yield-baseline-3
  protein-yield-baseline-4
  protein-yield-baseline-5
  protein-yield-baseline-6
  protein-yield-baseline-7
  protein-yield-baseline-8
  protein-yield-baseline-9
  protein-yield-baseline-10
  protein-yield-baseline-11
  protein-yield-baseline-12
  protein-yield-baseline-rel
  dairy-yield
  dairy-yield-baseline-1
  dairy-yield-baseline-2
  dairy-yield-baseline-3
  dairy-yield-baseline-4
  dairy-yield-baseline-5
  dairy-yield-baseline-6
  dairy-yield-baseline-7
  dairy-yield-baseline-8
  dairy-yield-baseline-9
  dairy-yield-baseline-10
  dairy-yield-baseline-11
  dairy-yield-baseline-12
  dairy-yield-baseline-rel
  non-leafy-veg-yield
  non-leafy-veg-yield-baseline-1
  non-leafy-veg-yield-baseline-2
  non-leafy-veg-yield-baseline-3
  non-leafy-veg-yield-baseline-4
  non-leafy-veg-yield-baseline-5
  non-leafy-veg-yield-baseline-6
  non-leafy-veg-yield-baseline-7
  non-leafy-veg-yield-baseline-8
  non-leafy-veg-yield-baseline-9
  non-leafy-veg-yield-baseline-10
  non-leafy-veg-yield-baseline-11
  non-leafy-veg-yield-baseline-12
  non-leafy-veg-yield-baseline-rel
  leafy-veg-yield
  leafy-veg-yield-baseline-1
  leafy-veg-yield-baseline-2
  leafy-veg-yield-baseline-3
  leafy-veg-yield-baseline-4
  leafy-veg-yield-baseline-5
  leafy-veg-yield-baseline-6
  leafy-veg-yield-baseline-7
  leafy-veg-yield-baseline-8
  leafy-veg-yield-baseline-9
  leafy-veg-yield-baseline-10
  leafy-veg-yield-baseline-11
  leafy-veg-yield-baseline-12
  leafy-veg-yield-baseline-rel
  fruits-yield
  fruits-yield-baseline-1
  fruits-yield-baseline-2
  fruits-yield-baseline-3
  fruits-yield-baseline-4
  fruits-yield-baseline-5
  fruits-yield-baseline-6
  fruits-yield-baseline-7
  fruits-yield-baseline-8
  fruits-yield-baseline-9
  fruits-yield-baseline-10
  fruits-yield-baseline-11
  fruits-yield-baseline-12
  fruits-yield-baseline-rel
]

to setup [#seed]
  clear-all

  set seed #seed
  random-seed seed

  ls:reset

  setup-logoclim

  assert-start-year
  assert-tick-window 12

  setup-world
  setup-variables
  setup-patches
  setup-stats

  reset-ticks
end

to go [#tick? #wait?]
  assert-logical #tick?
  assert-logical #wait?

  ls:ask ls:models [go true true]

  if (month = [month] ls:of tmin-ls-model) [
    ifelse (
      (is-true? flip-data-series?) and
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
  set plot-x-max-range ceiling ((ticks + 1) * 1.25)

  update-climate-vars
  compute-food-yield
  if ((index < 12) and (flip-index = 0)) [compute-yield-baseline]
  update-patches

  if (#tick? = true) [tick]
  if (#wait? = true) [wait transition-seconds]
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
785
820
995
853
grains-intercept
grains-intercept
-100000
100000
5900.0
100
1
kg/ha
HORIZONTAL

SLIDER
785
855
995
888
grains-tmin-beta
grains-tmin-beta
-10000
10000
1500.0
1
1
kg/ha per °C
HORIZONTAL

SLIDER
785
890
995
923
grains-tmax-beta
grains-tmax-beta
-10000
10000
-1000.0
1
1
kg/ha per °C
HORIZONTAL

SLIDER
785
930
995
963
grains-prec-beta
grains-prec-beta
-1000
1000
20.0
1
1
kg/ha per mm
HORIZONTAL

SLIDER
785
970
995
1003
grains-lat-beta
grains-lat-beta
-10000
10000
-200.0
1
1
kg/ha per deg.
HORIZONTAL

SLIDER
785
1010
995
1043
grains-lon-beta
grains-lon-beta
-10000
10000
50.0
1
1
kg/ha per deg.
HORIZONTAL

SLIDER
785
1050
995
1083
grains-random-threshold
grains-random-threshold
0
1
0.2
0.1
1
NIL
HORIZONTAL

SWITCH
330
1175
540
1208
add-random?
add-random?
0
1
-1000

CHOOSER
330
1020
540
1065
start-month
start-month
"January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December"
0

INPUTBOX
330
1070
540
1130
start-year
2016.0
1
0
Number

BUTTON
560
1120
770
1155
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
560
1160
770
1220
logoclim-path
../../logoclim/nlogo/logoclim.nlogo
1
0
String

BUTTON
455
500
555
535
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
565
500
665
535
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
675
500
775
535
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
785
500
885
535
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
560
820
770
853
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
560
860
770
893
patch-px-size
patch-px-size
0
10
2.0
0.01
1
px
HORIZONTAL

INPUTBOX
560
900
770
960
background-color
9.0
1
0
Color

SLIDER
560
965
770
998
black-value
black-value
0
1000
0.0
10
1
NIL
HORIZONTAL

SWITCH
560
1003
770
1036
black-min
black-min
1
1
-1000

SLIDER
560
1041
770
1074
white-value
white-value
0
10000
1000.0
1000
1
NIL
HORIZONTAL

SWITCH
560
1079
770
1112
white-max
white-max
0
1
-1000

BUTTON
900
500
1005
535
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
ifelse-value\n  ((settings = 0))\n  [\"NA\"]\n  [year]
0
1
11

MONITOR
1130
10
1230
55
Month
ifelse-value\n  ((settings = 0))\n  [\"NA\"]\n  [month]
0
1
11

PLOT
1020
60
1450
240
Kilogram per Hectare
Months
log10(Mean)
0.0
0.0
0.0
0.0
true
true
"set-plot-y-range 1 plot-max-y-log" "set-plot-x-range 0 plot-x-max-range"
PENS
"Grains" 1.0 0 -955883 true "" "let pen-color orange\n\nif (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color pen-color + 3\n]\n\nplot log (mean [grains-yield] of patches with [\nnot is-missing? grains-yield \n]) 10"
"Protein" 1.0 0 -8630108 true "" "let pen-color violet\n\nif (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color pen-color + 3\n]\n\nplot log (mean [protein-yield] of patches with [\n  not is-missing? protein-yield \n]) 10"
"Dairy" 1.0 0 -13345367 true "" "let pen-color blue\n\nif (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color pen-color + 3\n]\n\nplot log (mean [dairy-yield] of patches with [\n not is-missing? dairy-yield \n]) 10"
"Non-leafy veg." 1.0 0 -13840069 true "" "let pen-color lime\n\nif (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color pen-color + 3\n]\n\nplot log (mean [non-leafy-veg-yield] of patches with [\n not is-missing? non-leafy-veg-yield \n]) 10"
"Leafy veg." 1.0 0 -14835848 true "" "let pen-color turquoise\n\nif (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color pen-color + 3\n]\n\nplot log (mean [leafy-veg-yield] of patches with [\n  not is-missing? leafy-veg-yield \n]) 10"
"Fruits" 1.0 0 -2674135 true "" "let pen-color red\n\nif (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color pen-color + 3\n]\n\nplot log (mean [fruits-yield] of patches with [\n not is-missing? fruits-yield \n]) 10"
"(Year indicator)" 1.0 0 -16777216 false "" "ifelse (\n  (start-month = month) or\n  ((index = 1) and (flip-index = 0))\n) [\n  set-plot-pen-color black\n] [\n  set-plot-pen-color white\n]\n\nplot 1"

MONITOR
1020
480
1230
525
Mean (world-view)
mean [value] of patches with [not is-missing? value]
5
1
11

MONITOR
1020
530
1230
575
Minimum (world-view)
min [value] of patches with [not is-missing? value]
5
1
11

PLOT
1020
295
1450
475
Relative Yield (Mean)
Months
yield / base.
0.0
0.0
0.0
0.0
true
true
"set-plot-y-range 0 2" "set-plot-x-range 0 plot-x-max-range"
PENS
"Grains" 1.0 0 -955883 true "" "let pen-color orange\n\nif (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color pen-color + 3\n]\n\nplot mean [grains-yield-baseline-rel] of patches with [not is-missing? grains-yield-baseline-rel]"
"Protein" 1.0 0 -8630108 true "" "let pen-color violet\n\nif (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color pen-color + 3\n]\n\nplot mean [protein-yield-baseline-rel] of patches with [\n not is-missing? protein-yield-baseline-rel \n]"
"Dairy" 1.0 0 -13345367 true "" "let pen-color blue\n\nif (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color pen-color + 3\n]\n\nplot mean [dairy-yield-baseline-rel] of patches with [\n  not is-missing? dairy-yield-baseline-rel \n]"
"Non-leafy veg." 1.0 0 -13840069 true "" "let pen-color lime\n\nif (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color pen-color + 3\n]\n\nplot mean [non-leafy-veg-yield-baseline-rel] of patches with [\n not is-missing? non-leafy-veg-yield-baseline-rel \n]"
"Leafy veg." 1.0 0 -14835848 true "" "let pen-color turquoise\n\nif (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color pen-color + 3\n]\n\nplot mean [leafy-veg-yield-baseline-rel] of patches with [\n not is-missing? leafy-veg-yield-baseline-rel \n]"
"Fruits" 1.0 0 -2674135 true "" "let pen-color red\n\nif (\n  (flip-data-series? = true) and\n  (data-series != \"Future climate data\") and\n  ([data-series] ls:of tmin-ls-model = \"Future climate data\")\n  )[\n  set-plot-pen-color pen-color + 3\n]\n\nplot mean [fruits-yield-baseline-rel] of patches with [\n not is-missing? fruits-yield-baseline-rel \n]"
"(Year indicator)" 1.0 0 -16777216 false "" "ifelse (\n  (start-month = month) or\n  ((index = 1) and (flip-index = 0))\n) [\n  set-plot-pen-color black\n] [\n  set-plot-pen-color white\n]\n\nplot 0"

MONITOR
1240
480
1450
525
Standard deviation (world-view)
standard-deviation [value] of patches with [not is-missing? value]
5
1
11

MONITOR
1240
530
1450
575
Maximum (world-view)
max [value] of patches with [not is-missing? value]
5
1
11

CHOOSER
330
820
540
865
data-series
data-series
"Historical monthly weather data" "Future climate data"
0

CHOOSER
330
870
540
915
data-resolution
data-resolution
"30 seconds (~1 km2  at the equator)" "2.5 minutes (~21 km2 at the equator)" "5 minutes (~85 km2 at the equator)" "10 minutes (~340 km2 at the equator)"
3

CHOOSER
330
920
540
965
global-climate-model
global-climate-model
"ACCESS-CM2" "BCC-CSM2-MR" "CMCC-ESM2" "EC-Earth3-Veg" "FIO-ESM-2-0" "GFDL-ESM4" "GISS-E2-1-G" "HadGEM3-GC31-LL" "INM-CM5-0" "IPSL-CM6A-LR" "MIROC6" "MPI-ESM1-2-HR" "MRI-ESM2-0" "UKESM1-0-LL"
2

CHOOSER
330
970
540
1015
shared-socioeconomic-pathway
shared-socioeconomic-pathway
"SSP-126" "SSP-245" "SSP-370" "SSP-585"
3

TEXTBOX
970
770
1260
790
Parameters for Food Group Yield Response
14
0.0
1

SLIDER
785
1090
995
1123
protein-intercept
protein-intercept
-100000
100000
1200.0
1
1
kg/ha
HORIZONTAL

CHOOSER
455
540
665
585
world-view
world-view
"Grains" "Protein" "Dairy" "Non-leafy vegetables" "Leafy vegetables" "Fruits"
0

SLIDER
785
1130
995
1163
protein-tmin-beta
protein-tmin-beta
-10000
10000
80.0
1
1
kg/ha per °C
HORIZONTAL

SLIDER
785
1170
995
1203
protein-tmax-beta
protein-tmax-beta
-10000
10000
-100.0
1
1
kg/ha per °C
HORIZONTAL

SLIDER
785
1205
995
1238
protein-prec-beta
protein-prec-beta
-1000
1000
15.0
1
1
kg/ha per mm
HORIZONTAL

SLIDER
785
1245
995
1278
protein-lat-beta
protein-lat-beta
-10000
10000
-20.0
1
1
kg/ha per deg.
HORIZONTAL

SLIDER
785
1285
995
1318
protein-lon-beta
protein-lon-beta
-10000
10000
10.0
1
1
kg/ha per deg.
HORIZONTAL

SLIDER
785
1320
995
1353
protein-random-threshold
protein-random-threshold
0
1
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
1015
1090
1225
1123
non-leafy-veg-intercept
non-leafy-veg-intercept
-100000
100000
70000.0
0.1
1
kg/ha
HORIZONTAL

SLIDER
1015
1130
1225
1163
non-leafy-veg-tmin-beta
non-leafy-veg-tmin-beta
-10000
10000
3000.0
1
1
kg/ha per °C
HORIZONTAL

SLIDER
1015
1170
1225
1203
non-leafy-veg-tmax-beta
non-leafy-veg-tmax-beta
-10000
10000
-2500.0
1
1
kg/ha per °C
HORIZONTAL

SLIDER
1015
1210
1225
1243
non-leafy-veg-prec-beta
non-leafy-veg-prec-beta
-1000
1000
60.0
1
1
kg/ha per mm
HORIZONTAL

SLIDER
1015
1245
1225
1278
non-leafy-veg-lat-beta
non-leafy-veg-lat-beta
-10000
10000
-500.0
1
1
kg/ha per deg.
HORIZONTAL

SLIDER
1015
1280
1225
1313
non-leafy-veg-lon-beta
non-leafy-veg-lon-beta
-10000
10000
100.0
1
1
kg/ha per deg.
HORIZONTAL

SLIDER
1015
1320
1225
1353
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
1240
820
1450
853
leafy-veg-intercept
leafy-veg-intercept
-100000
100000
35000.0
0.1
1
kg/ha
HORIZONTAL

SLIDER
1240
860
1450
893
leafy-veg-tmin-beta
leafy-veg-tmin-beta
-10000
10000
1500.0
1
1
kg/ha per °C
HORIZONTAL

SLIDER
1240
900
1450
933
leafy-veg-tmax-beta
leafy-veg-tmax-beta
-10000
10000
-1200.0
1
1
kg/ha per °C
HORIZONTAL

SLIDER
1240
940
1450
973
leafy-veg-prec-beta
leafy-veg-prec-beta
-1000
1000
40.0
1
1
kg/ha per mm
HORIZONTAL

SLIDER
1240
980
1450
1013
leafy-veg-lat-beta
leafy-veg-lat-beta
-10000
10000
-300.0
1
1
kg/ha per deg.
HORIZONTAL

SLIDER
1240
1015
1450
1048
leafy-veg-lon-beta
leafy-veg-lon-beta
-10000
10000
50.0
1
1
kg/ha per deg.
HORIZONTAL

SLIDER
1240
1050
1450
1083
leafy-veg-random-threshold
leafy-veg-random-threshold
0
1
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
1240
1090
1450
1123
fruits-intercept
fruits-intercept
-100000
100000
20000.0
0.1
1
kg/ha
HORIZONTAL

SLIDER
1240
1130
1450
1163
fruits-tmin-beta
fruits-tmin-beta
-10000
10000
2000.0
1
1
kg/ha per °C
HORIZONTAL

SLIDER
1240
1170
1450
1203
fruits-tmax-beta
fruits-tmax-beta
-10000
10000
-500.0
1
1
kg/ha per °C
HORIZONTAL

SLIDER
1240
1210
1450
1243
fruits-prec-beta
fruits-prec-beta
-1000
1000
80.0
1
1
kg/ha per mm
HORIZONTAL

SLIDER
1240
1250
1450
1283
fruits-lat-beta
fruits-lat-beta
-10000
10000
-400.0
1
1
kg/ha per deg.
HORIZONTAL

SLIDER
1240
1285
1450
1318
fruits-lon-beta
fruits-lon-beta
-10000
10000
100.0
1
1
kg/ha per deg.
HORIZONTAL

SLIDER
1240
1320
1450
1353
fruits-random-threshold
fruits-random-threshold
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
1015
820
1225
853
dairy-intercept
dairy-intercept
-100000
100000
6000.0
0.1
1
kg/ha
HORIZONTAL

SLIDER
1015
860
1225
893
dairy-tmin-beta
dairy-tmin-beta
-10000
10000
200.0
1
1
kg/ha per °C
HORIZONTAL

SLIDER
1015
900
1225
933
dairy-tmax-beta
dairy-tmax-beta
-10000
10000
-301.0
1
1
kg/ha per °C
HORIZONTAL

SLIDER
1015
940
1225
973
dairy-prec-beta
dairy-prec-beta
-1000
1000
25.0
1
1
kg/ha per mm
HORIZONTAL

SLIDER
1015
975
1225
1008
dairy-lat-beta
dairy-lat-beta
-10000
10000
-30.0
1
1
kg/ha per deg.
HORIZONTAL

SLIDER
1015
1010
1225
1043
dairy-lon-beta
dairy-lon-beta
-10000
10000
10.0
1
1
kg/ha per deg.
HORIZONTAL

SLIDER
1015
1050
1225
1083
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
540
1005
573
shock-threshold
shock-threshold
0
5
1.0
0.1
1
NIL
HORIZONTAL

SWITCH
330
1135
540
1168
flip-data-series?
flip-data-series?
0
1
-1000

SLIDER
330
1215
540
1248
raise-lower-tmin
raise-lower-tmin
-5
5
0.0
0.1
1
ºC
HORIZONTAL

SLIDER
330
1255
540
1288
raise-lower-tmax
raise-lower-tmax
-5
5
0.0
0.1
1
ºC
HORIZONTAL

SLIDER
330
1295
540
1328
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
540
790
573
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
ifelse-value \n  ((settings = 0))\n  [\"NA\"]\n  [data-series]
0
1
11

MONITOR
1020
245
1450
290
Baseline period
ifelse-value (baseline-period = 0) [\"NA\"] [baseline-period]
0
1
11

MONITOR
1020
580
1230
625
Baseline mean (world-view)
mean [value-baseline] of patches with [\n  not is-missing? value-baseline \n]
5
1
11

MONITOR
1240
580
1450
625
Baseline mean rel yield (world-view)
mean [value-baseline-rel] of patches with [\n not is-missing? value-baseline-rel \n]
5
1
11

PLOT
10
10
440
135
Grains (Kilogram per Hectare)
Months
Mean
0.0
0.0
0.0
0.0
true
true
"set-plot-y-range 0 (plot-max-y \"grains\")" "set-plot-x-range 0 plot-x-max-range"
PENS
"Estimate" 1.0 0 -955883 true "" "set-plot-pen-color plot-pen-color orange\n\nplot mean [grains-yield] of patches with [not is-missing? grains-yield]"
"Real" 1.0 0 -7500403 true "" "plot mean [grains-yield-baseline-1] of patches with [\n  not is-missing? grains-yield-baseline-1\n]"

PLOT
10
140
440
265
Protein (Kilogram per Hectare)
Months
Mean
0.0
0.0
0.0
0.0
true
true
"set-plot-y-range 0 (plot-max-y \"protein\")" "set-plot-x-range 0 plot-x-max-range"
PENS
"Estimate" 1.0 0 -8630108 true "" "set-plot-pen-color plot-pen-color violet\n\nplot mean [protein-yield] of patches with [not is-missing? protein-yield]"
"Real" 1.0 0 -7500403 true "" "plot mean [protein-yield-baseline-1] of patches with [\n  not is-missing? protein-yield-baseline-1\n]"

PLOT
10
270
440
395
Dairy (Kilogram per Hectare)
Months
Mean
0.0
0.0
0.0
0.0
true
true
"set-plot-y-range 0 (plot-max-y \"dairy\")" "set-plot-x-range 0 plot-x-max-range"
PENS
"Estimate" 1.0 0 -13345367 true "" "set-plot-pen-color plot-pen-color blue\n\nplot mean [dairy-yield] of patches with [not is-missing? dairy-yield]"
"Real" 1.0 0 -7500403 true "" "plot mean [dairy-yield-baseline-1] of patches with [\n  not is-missing? dairy-yield-baseline-1\n]"

PLOT
10
400
440
525
Non-leafy vegetables (Kilogram per Hectare)
Months
Mean
0.0
0.0
0.0
0.0
true
true
"set-plot-y-range 0 (plot-max-y \"non-leafy-veg\")" "set-plot-x-range 0 plot-x-max-range"
PENS
"Estimate" 1.0 0 -10899396 true "" "set-plot-pen-color plot-pen-color green\n\nplot mean [non-leafy-veg-yield] of patches with [not is-missing? non-leafy-veg-yield]"
"Real" 1.0 0 -7500403 true "" "plot mean [non-leafy-veg-yield-baseline-1] of patches with [\n  not is-missing? non-leafy-veg-yield-baseline-1\n]"

PLOT
10
530
440
655
Leafy Veg. (Kilogram per Hectare)
Months
Mean
0.0
0.0
0.0
0.0
true
true
"set-plot-y-range 0 (plot-max-y \"leafy-veg\")" "set-plot-x-range 0 plot-x-max-range"
PENS
"Estimate" 1.0 0 -14835848 true "" "set-plot-pen-color plot-pen-color turquoise\n\nplot mean [leafy-veg-yield] of patches with [not is-missing? leafy-veg-yield]"
"Real" 1.0 0 -7500403 true "" "plot mean [leafy-veg-yield-baseline-1] of patches with [\n  not is-missing? leafy-veg-yield-baseline-1\n]"

PLOT
10
660
440
785
Fruits (Kilogram per Hectare)
Months
Mean
0.0
0.0
0.0
0.0
true
true
"set-plot-y-range 0 (plot-max-y \"fruits\")" "set-plot-x-range 0 plot-x-max-range"
PENS
"Estimate" 1.0 0 -2674135 true "" "set-plot-pen-color plot-pen-color red\n\nplot mean [fruits-yield] of patches with [not is-missing? fruits-yield]"
"Real" 1.0 0 -7500403 true "" "plot mean [fruits-yield-baseline-1] of patches with [\n  not is-missing? fruits-yield-baseline-1\n]"

@#$#@#$#@
# FOODCLIM: SIMULATING FOOD YIELD RESPONSES TO CLIMATE CHANGE IN NETLOGO

You are currently using the developer version of `FoodClim`.

### TO DO

- Fix interface proportions.
- Implemenent string response functions.

## HOW TO USE IT

Refer to the [`LogoClim`](https://github.com/sustentarea/logoclim) installation guide for detailed steps on installing the required dependencies.

Once `LogoClim` is installed, you can run the `FoodClim` model by specifying the path to your `LogoClim` installation in the `FoodClim` interface. This allows `FoodClim` to access climate data provided by `LogoClim` during simulations.

### BEHAVIOR NOTES

#### ORDER OF EVENTS

Due to the use of empirical data, the world and charts may experience some delay. However, it's important to note the order of events: the world will always update **before** the charts.

#### CHARTS

The starting month of the one-year baseline cycle is indicated by a black line on the bottom of the charts. The relative yield will always take into account the starting year and starting month.

If `flip-series?` is on, the color of the chart series will slightly fade at the point where the flip occurs to the `Future climate data` series.

##### `raise-lower-*` SLIDERS

These sliders adjust the global value of a variable by proportionally scaling each patch's value. Specifically, a proportionality constant (alpha) is applied to each patch so that the overall mean changes by the desired amount:

alpha = ΔTmean / Tmean

Where:

- alpha = Proportionality constant
- ΔTmean = Desired change in the global mean
- Tmean = Current mean temperature across all patches

This ensures that patches with higher initial values receive proportionally larger adjustments, while the system's overall mean changes by exactly the specified amount.

## HOW TO CITE

If you use this model in your research, please cite it to acknowledge the effort invested in its development and maintenance. Your citation helps support the ongoing improvement of the model.

To cite `FoodClim` in publications please use the following format:

Vartanian, D., Garcia, L., & Carvalho, A. M. (2025). *FoodClim: Simulating food yield responses to climate change in NetLogo* [Computer software, NetLogo model]. <https://doi.org/10.17605/OSF.IO/ZGVMP>

A BibTeX entry for LaTeX users is:

```latex
@Misc{vartanian2025,
  title = {FoodClim: Simulating food yield responses to climate change in NetLogo},
  author = {{Daniel Vartanian} and {Leandro Garcia} and {Aline Martins de Carvalho}},
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

- OSF repository: https://doi.org/10.17605/OSF.IO/ZGVMP
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

Firpo, M. Â. F., Guimarães, B. dos S., Dantas, L. G., Silva, M. G. B. da, Alves, L. M., Chadwick, R., Llopart, M. P., & Oliveira, G. S. de. (2022). Assessment of CMIP6 models' performance in simulating present-day climate in Brazil. *Frontiers in Climate*, *4*. <https://doi.org/10.3389/fclim.2022.948499>

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
