globals [
  seat-color          ;; Economy class seat color
  galley-color        ;; Color representing the galley area
  toilet-color        ;; Color of the toilet area
  pax-color           ;; Color of pax
  crew-color          ;; Color of crew
  total_sections      ;; Total number of sections o the Y-class
  total_rows          ;; Total number of rows per section
  seats-coord         ;; List that contains the coordinate of all the seats in the aircraft
  mid-galley-coord    ;; List that contains the coordinate for patches of the mid galley
  aft-galley-coord    ;; List that contains the coordinate for patches of the aft galley
  patience-randomness ;; Different level of patience passengers can take
  max-trays           ;; Max number of trays a crew can carry
  _A
  _B
  _C
  _D
  _E
  _F
  _G
  _H
  _J
  _K

  LHS_aisle_x     ;;X coordinate of LHS aisle
  RHS_aisle_x     ;;X coordinate of RHS aisle

  total-eaten     ;; Total number of PAX that have eaten (stop criteria)
]

breed [paxs pax]
paxs-own [
           patience
           eaten?
           happy?
         ]

breed [crews crew]
crews-own [
            total-trays
            target-row            ;; Indicate row where crew should be
            current-serving-seat  ;; Indicate which is the current seat letter that the crew should serve
            mission               ;; Indicate what the crew should be doing: serving pax, moving to position or restocking trays.
            side                  ;; Indicate which side the crew should start serving
          ]

;; Mission: what the crew is doing
;; - Moving to position = 1
;; - Serving Pax = 2
;; - Re-stocking trays = 3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                          ;
;    Simulation Functions  ;
;                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; 1 Crew - Start RHS when finished
;; 2 Crew - Each one at one side
;; + 2 crew even - start from where other crew started + 39
;; 2 crew odd -

to go
  update-crew
  update-pax
  tick
  set total-eaten show count paxs with [eaten? =  True]

end

to update-crew
    ; 1 Crew:
    ;- Moves to its star-row
    ;- Folowing the order Outboard (window-middle-aisle) and Inboard(middle-aisle)
           ;- Check if there is passengers and if you have trays left
              ;- If there is, serve the passenger.
              ;- If there is not, return to load more trays in the galley.



  ask crews
  [
    ;; Moving to position
    ifelse(mission = 1)[ move-crew-to-position ]
    [
      ;; Serving PAX
      ifelse (mission = 2) [ serve-pax ]
      [
        ;; Re-stocking trays
        ifelse (mission = 3) [ restock-trays ]
        [
          ;; POSSIBLY SOME OTHER CREW ACTION
        ]
      ]
    ]


  ]


end

;; Mission 1: move crew to position
to move-crew-to-position

  ifelse(side = "LHS")
  [
    ;;LHS crew
    ifelse (xcor > LHS_aisle_x)
    [ set xcor xcor - 1 ]
    [
      ifelse (ycor < target-row)
      [ set ycor ycor + 1 ]
      [
         ;;Position arrived, change mission to "Feed pax"
         set mission 2
      ]
   ]
  ]
  [
    ;;RHS crew
    ifelse (xcor < RHS_aisle_x)
    [ set xcor xcor + 1 ]
    [
      ifelse (ycor < target-row)
      [ set ycor ycor + 1 ]
      [
         ;;Position arrived, change mission to "Feed pax"
         set mission 2
      ]
   ]
  ]


end

;; Mission 2: feed pax
to serve-pax
 ;;If still have trays
  ifelse (total-trays > 0)
  [
    ;;Serve pax
    let crew_x xcor ;;Current X crew coordinate to check for pax
    let crew_y ycor ;; Current Y crew coordinate to check for pax
    let tray_delivered? False ;;Flas that indicates that a paxhas been fed
    let seat_x current-serving-seat;; Indicate that a new seat letter

     ;;Checking if there exists a pax to feed
     if any? paxs with [xcor = crew_x + seat_x and ycor = crew_y]
     [
       ask paxs with [xcor = crew_x + seat_x and ycor = crew_y]
       [
         ;; Feed the pax
         if (not eaten?)[ set eaten? true set tray_delivered? True]
       ]
     ]
     ;; Update tray count from the crew
     if (tray_delivered? = True) [set total-trays total-trays - 1 ]

     ;;update current serving seat
     update-serving-seat
  ]
  ;; If no more trays, change mission to 3 (re-stock trays)
  [
    set mission 3
  ]
end

;; Mission 3: Restock trays
to restock-trays
  ;; Move crew to the aft galley to replenish trays
  ifelse (ycor > max-pycor -(2 * total_rows) - 8)
  [ set ycor ycor - 1 ]
  [
    ;;Coming back from LHS
    ifelse(side = "LHS")[set xcor xcor + 1]
    ;;Coming back from RHS
    [ set xcor xcor - 1]
    set total-trays max-trays
    set mission 1
  ]
end

to update-serving-seat
  ifelse(side = "LHS")
  [
    ;;Servinh LHS
    ;; Checking end of outboard seats
    ifelse (current-serving-seat = _C)
    [ set current-serving-seat _D ]
    ;;Checking end of inboard seats
    [ ifelse (current-serving-seat = _E)
      ;;Crew finished the row
      [ set current-serving-seat _A
        set ycor ycor - 1]
      ;; Default case: serve the adjacent seat
      [ set current-serving-seat current-serving-seat + 1
        set target-row ycor]
    ]
  ]
  [
    ;;Servinh RHS
     ;; Checking end of outboard seats
    ifelse (current-serving-seat = _H)
    [ set current-serving-seat _G ]
    ;;Checking end of inboard seats
    [ ifelse (current-serving-seat = _F)
      ;;Crew finished the row
      [ set current-serving-seat _K
        set ycor ycor - 1]
      ;; Default case: serve the adjacent seat
      [ set current-serving-seat current-serving-seat - 1
        set target-row ycor]
    ]
  ]


end

to update-pax
  ask paxs
  [
    ifelse (eaten? = true)
    [
      set shape "face happy"
      set color green
      set happy? true
    ]
    [
      if(ticks > patience)
      [
        set shape "face sad"
        set color red
      ]
    ]
  ]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                              ;
;   Initialization Functions   ;
;                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



to setup
  clear-all

  ;; Initialize global variables
  initialize-globals

  ;; Creating the aircraft patches
  generate-seatmap
  generate-toilets
  generate-galleys

  ;; Creating PAXs agents
  generate-pax

  ;; Creting Crew agents
  generate-crew


  reset-ticks
end

to initialize-globals
  set seat-color blue
  set galley-color grey
  set toilet-color red
  set pax-color yellow
  set crew-color magenta

  set max-trays 39;
  set total_sections 2
  set total_rows 18
  set seats-coord []   ;; Empty list
  set mid-galley-coord [] ;; Empty list
  set aft-galley-coord [] ;; Empty list

  ;; X offset for the pax seat letters
  set _A -3
  set _B -2
  set _C -1
  set _D  1
  set _E  2
  set _F  -2
  set _G  -1
  set _H  1
  set _J  2
  set _K  3

  set LHS_aisle_x -2
  set RHS_aisle_x 3

  set patience-randomness 1000

end


;;
;; To setup the position of the pax, a list with the seat coordinates (seats-coord) generated from the "generate-seatmap" function is used.
;;      - For each pax, a random index to access seats-coord is generated with the current size of that list.
;;      - The item with the random index is removed from the list (updating its size for the next pax agent).
;;      - No pax can have the same seat using this logic and the index will always exist, since the length of the list is recalculated to generate the random index for the next pax.
;;
to generate-pax
  create-paxs total-pax
  ;; Chose a random number between 0 and 179 (180 seats)
  ;; If seats taken, chose another number
  ask paxs
  [
    set color pax-color
    set shape "face neutral"

    set patience 300 + random patience-randomness ;;
    set eaten? False
    set happy? True

    ;; Seat allocation
    let seat-coord-index random length seats-coord ;; Will indicate seat index in the list of seat coordinates (seats-coord)
    let new_pax_seat item seat-coord-index seats-coord ;; Retrieving pax new seat position
    set seats-coord remove-item seat-coord-index seats-coord ;; Remove from the list
    setxy first new_pax_seat last new_pax_seat

  ]
end

to generate-crew
  create-crews total-crew

  let total-crew-mid 0
  let total-crew-aft 0

  ;; Determine ammount of crew in each galley
  ifelse (total-crew = 1)
  [
      ;;Crew = 1 - place back-galley
      set total-crew-aft 1
      set total-crew-mid 0
  ]
  [
     ifelse (total-crew = 2)
     [
       ;;Crew = 2 - place 1 mid and one back galley
        set total-crew-aft 1
        set total-crew-mid 1
     ]
     [
       ;; total-crew > 2
       set total-crew-aft ceiling (total-crew / 2)
       set total-crew-mid floor (total-crew / 2)
     ; set total-crew-aft 3
     ; set total-crew-mid 2
     ]
  ]

  ask crews
  [
    set color crew-color
    set shape "person"
    set target-row max-pycor - 4 ; First row LHS
    set total-trays max-trays
    set mission 1 ;;Moving to position

    ifelse (total-crew-mid > 0)
    [
      ;; Populating mid-galley

      ;; Crew random mid galley allocation
      let mid-coord-index random length mid-galley-coord ;; Will indicate mid-galley patch index in the list of mid-galley patches coordinates (mid-galley-coord)
      let new_crew_posn item mid-coord-index mid-galley-coord ;; Retrieving pax new seat position
      set mid-galley-coord remove-item mid-coord-index mid-galley-coord ;; Remove from the list

      setxy first new_crew_posn last new_crew_posn


      set total-crew-mid total-crew-mid - 1
      set side "LHS"
      set current-serving-seat _A
    ]
    [
      ;; Populating aft-galley

      ;; Crew random aft galley allocation
      let aft-coord-index random length aft-galley-coord ;; Will indicate mid-galley patch index in the list of mid-galley patches coordinates (mid-galley-coord)
      let new_crew_posn item aft-coord-index aft-galley-coord ;; Retrieving pax new seat position
      set aft-galley-coord remove-item aft-coord-index aft-galley-coord ;; Remove from the list

      setxy first new_crew_posn last new_crew_posn

      set total-crew-aft total-crew-aft - 1
      set side "RHS"
      set current-serving-seat _K
    ]

  ]




end


;; Generate seats LHS and RHS
to generate-seatmap

  let section_index 0
  let row_index 0
  let x_cord -6
  let y_cord max-pycor - 4


  ;; For each section of the Y Class
  while [ section_index != total_sections ] [
    set row_index 0
    ;; For each row of a section
    while [ row_index != total_rows ] [
      set x_cord -6
      ;; Seats A B C
      ask patches with [ pxcor = x_cord + 1 and pycor = y_cord ] [ set pcolor seat-color set plabel "A"]
      ask patches with [ pxcor = x_cord + 2 and pycor = y_cord ] [ set pcolor seat-color set plabel "B"]
      ask patches with [ pxcor = x_cord + 3 and pycor = y_cord ] [ set pcolor seat-color set plabel "C"]

      let seat_position_A (list (x_cord + 1) (y_cord)) set seats-coord lput seat_position_A seats-coord
      let seat_position_B (list (x_cord + 2) (y_cord)) set seats-coord lput seat_position_B seats-coord
      let seat_position_C (list (x_cord + 3) (y_cord)) set seats-coord lput seat_position_C seats-coord

      ;; Aisle


      ;; Seats D E F G
      ask patches with [ pxcor = x_cord + 5 and pycor = y_cord ] [ set pcolor seat-color set plabel "D"]
      ask patches with [ pxcor = x_cord + 6 and pycor = y_cord ] [ set pcolor seat-color set plabel "E"]
      ask patches with [ pxcor = x_cord + 7 and pycor = y_cord ] [ set pcolor seat-color set plabel "F"]
      ask patches with [ pxcor = x_cord + 8 and pycor = y_cord ] [ set pcolor seat-color set plabel "G"]


      let seat_position_D (list (x_cord + 5) (y_cord)) set seats-coord lput seat_position_D seats-coord
      let seat_position_E (list (x_cord + 6) (y_cord)) set seats-coord lput seat_position_E seats-coord
      let seat_position_F (list (x_cord + 7) (y_cord)) set seats-coord lput seat_position_F seats-coord
      let seat_position_G (list (x_cord + 8) (y_cord)) set seats-coord lput seat_position_G seats-coord

      ;; Aisle

      ;; Seats  H J K
      ask patches with [ pxcor = x_cord + 10 and pycor = y_cord ] [ set pcolor seat-color set plabel "H"]
      ask patches with [ pxcor = x_cord + 11 and pycor = y_cord ] [ set pcolor seat-color set plabel "J"]
      ask patches with [ pxcor = x_cord + 12 and pycor = y_cord ] [ set pcolor seat-color set plabel "K"]


      let seat_position_H (list (x_cord + 10) (y_cord)) set seats-coord lput seat_position_H seats-coord
      let seat_position_J (list (x_cord + 11) (y_cord)) set seats-coord lput seat_position_J seats-coord
      let seat_position_K (list (x_cord + 12) (y_cord)) set seats-coord lput seat_position_K seats-coord

      ;; Set row number label
      ask patches with [ (pxcor = -7 or pxcor = 8) and ( pycor = y_cord)] [set plabel (row_index + 1)  + (18 * section_index)] ; When first section (section_index = 0) the row number doesn't offset.

      set row_index row_index + 1
      set y_cord y_cord - 1


    ]

    ;; Leave empty space for galleys
    set y_cord y_cord - 4

    set section_index section_index + 1
  ]

end

to generate-galleys
  let x_cord -6
  ;; MID Galley
  ask patches with [ (pxcor >= x_cord + 5 and pxcor <= x_cord + 8) and (pycor <= max-pycor - total_rows - 4 and pycor >= max-pycor - total_rows - 7) ][ set pcolor galley-color ]

  ;; Save mid galley coordinates for crew creation
  let mid-index-x (x_cord + 5)
  let mid-index-y (max-pycor - total_rows - 4)
  while [mid-index-x <= (x_cord + 8)]
  [
    set mid-index-y (max-pycor - total_rows - 4)
    while [mid-index-y >= (max-pycor - total_rows - 7)]
    [
      set mid-galley-coord lput (list (mid-index-x) (mid-index-y)) mid-galley-coord ;; Save galley patch coordinate
      set mid-index-y mid-index-y - 1;
    ]
    set mid-index-x mid-index-x + 1;
  ]



  ;; AFT Galley
  ask patches with [ (pxcor >= x_cord + 5 and pxcor <= x_cord + 8) and (pycor <= max-pycor -(2 * total_rows) - 8 and pycor >= max-pycor - (2 * total_rows) - 11) ] [ set pcolor galley-color ]

  ;; Save aft galley coordinates for crew creation
  let aft-index-x (x_cord + 5)
  let aft-index-y ( max-pycor -(2 * total_rows) - 8)
  while [aft-index-x <= (x_cord + 8)]
  [
    set aft-index-y ( max-pycor -(2 * total_rows) - 8)
    while [aft-index-y >= (max-pycor - (2 * total_rows) - 11)]
    [
      set aft-galley-coord lput (list (aft-index-x) (aft-index-y)) aft-galley-coord ;; Save galley patch coordinate
      set aft-index-y aft-index-y - 1;
    ]
    set aft-index-x aft-index-x + 1;
  ]

end

to generate-toilets
  let x_cord -6
  ;; FWD Toilets
  ask patches with [ (pxcor >= x_cord + 1 and pxcor <= x_cord + 3) and (pycor <= max-pycor - 2 and pycor >= max-pycor - 3)][ set pcolor toilet-color]
  ask patches with [ (pxcor >= x_cord + 10 and pxcor <= x_cord + 12) and (pycor <= max-pycor - 2 and pycor >= max-pycor - 3)][ set pcolor toilet-color]

  ;; MID Toilets
  ask patches with [ (pxcor >= x_cord + 1 and pxcor <= x_cord + 3) and (pycor <= max-pycor - total_rows - 4 and pycor >= max-pycor - total_rows - 5)][ set pcolor toilet-color]
  ask patches with [ (pxcor >= x_cord + 10 and pxcor <= x_cord + 12) and (pycor <= max-pycor - total_rows - 4 and pycor >= max-pycor - total_rows - 5)][ set pcolor toilet-color]

  ;; AFT Toilets
  ;ask patches with [pxcor = and pycor = ][ set pcolor toilet-color]
  ask patches with [ (pxcor >= x_cord + 1 and pxcor <= x_cord + 3) and (pycor <= max-pycor - (2 * total_rows) - 8 and pycor >= max-pycor - (2 * total_rows) - 9)][ set pcolor toilet-color]
  ask patches with [ (pxcor >= x_cord + 10 and pxcor <= x_cord + 12) and (pycor <= max-pycor - (2 * total_rows) - 8 and pycor >= max-pycor - (2 * total_rows) - 9)][ set pcolor toilet-color]

end
@#$#@#$#@
GRAPHICS-WINDOW
327
10
896
580
-1
-1
11.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
24
21
87
54
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

SLIDER
22
66
194
99
total-crew
total-crew
1
18
4.0
1
1
NIL
HORIZONTAL

SLIDER
22
105
194
138
total-pax
total-pax
0
360
360.0
1
1
NIL
HORIZONTAL

BUTTON
129
20
192
53
go
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
0
@#$#@#$#@
