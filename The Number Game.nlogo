breed [people person] ; create people

globals [
  all-words
  total-words
  mean-words
  std-words
  current-word
  num-success
  num-failure
  selected-sender
  selected-reciever
  neighbors-in-radius
]

people-own [
  words
  num-words
  interactions
  role
]

to setup
  clear-all
  initialize-people
  initialize-system
  reset-ticks
  ;; create-network
end

to initialize-system
  set selected-sender -1
  set selected-reciever -1
  set current-word ""
  set num-success 0
  set num-failure 0
  update-globals
end

to update-globals
  set all-words remove-duplicates [words] of people
  set total-words length all-words
  set mean-words mean [length words] of people
  set std-words standard-deviation [length words] of people
end

to initialize-people
  create-people num-agents [
    setxy random(world-width) random(world-height)
    set color black
    set shape "person"
    set size 1
    set interactions 0
    set words []
    set role "none"
    set num-words length words
  ]
end

to go-once
  sample-sender-reciever
  send-message
  update-globals
  tick
end


to sample-sender-reciever
  ; unset last sender and reciever
  if selected-sender != -1 [
    ask person selected-sender [
      set role "none"
      set color grey
    ]
  ]
  if selected-reciever != -1 [
    ask person selected-reciever [
      set role "none"
      set color grey
    ]
  ]
  ; select new sender and reciever
  set selected-sender random(num-agents)
  ifelse sample-neighbor [
    if is-agentset? neighbors-in-radius [
      ask neighbors-in-radius [
        if who != selected-reciever [set color grey]
      ]
    ]
    ask person selected-sender [
      set neighbors-in-radius people in-radius neighbor-radius
      ask neighbors-in-radius [
        set color green
      ]
      ask (one-of neighbors-in-radius) [
        set selected-reciever who
      ]
    ]
  ] [
    set selected-reciever random(num-agents)
    while [selected-reciever = selected-sender] [
      set selected-reciever random(num-agents)
    ]
  ]
  ; set new sender and reciever
  ask person selected-sender [
    set role "sender"
    set color red
    set interactions interactions + 1
  ]
  ask person selected-reciever [
    set role "reciever"
    set color blue
    set interactions interactions + 1
  ]
end


to-report sample-new-word
  let word-length random(max-word-length - 1) + 1
  let alphabet "abcdefghijklmnopqrstuvwxyz"
  let new-word reduce word n-values word-length [item random(length alphabet) alphabet]
  report new-word
end


to send-message
  let sender-word ""
  ask person selected-sender [
    ifelse length words < 1 [
      ;; sample new word as inventory is empty
      set sender-word sample-new-word
      set words lput sender-word words
    ] [
      ifelse shortest-word [
        let sorted-words sort-by [ [string1 string2] -> length string1 < length string2 ] words
        set sender-word first sorted-words
      ][
        set sender-word one-of words
      ]
    ]
  ]
  set current-word sender-word
  ask person selected-reciever [
    ifelse length words < 1 [
      ;; add word to reciever inventory
      set words lput sender-word words
      set num-success num-success + 1
    ] [
      ifelse member? sender-word words [
        ;; word agreement
        set words (list sender-word)
        set num-success num-success + 1
      ] [
        ;; failure
        set words lput sender-word words
        set num-failure num-failure + 1
      ]
    ]

  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
535
10
1218
694
-1
-1
20.455
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
13
17
76
50
setup
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
16
63
188
96
num-agents
num-agents
0
1000
115.0
1
1
NIL
HORIZONTAL

MONITOR
14
113
71
158
People
count people
17
1
11

MONITOR
77
114
157
159
Interactions
sum [interactions] of people
17
1
11

PLOT
13
165
495
334
Total Unique Words
Ticks
Words
0.0
10.0
-5.0
10.0
true
true
"" ""
PENS
"total-words" 1.0 0 -16777216 true "" "plot total-words"
"value-1" 1.0 0 -2674135 true "" "plot 1"
"active-people" 1.0 0 -14454117 true "" "plot count (people with [interactions > 0])"

BUTTON
78
16
155
49
NIL
go-once
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
194
63
366
96
max-word-length
max-word-length
0
100
58.0
1
1
NIL
HORIZONTAL

MONITOR
164
114
438
159
Current word
current-word
17
1
11

PLOT
14
337
495
487
Words per agent
NIL
NIL
0.0
10.0
0.0
5.0
true
true
"" ""
PENS
"mean-num-words" 1.0 0 -16777216 true "" "plot mean-words"
"mean-plus-std" 1.0 0 -2674135 true "" "plot mean-words + std-words"
"mean-minus-std" 1.0 0 -1604481 true "" "plot mean-words - std-words"
"max-num-words" 1.0 0 -14070903 true "" "plot max [length words] of people"
"min-num-words" 1.0 0 -8275240 true "" "plot min [length words] of people"

BUTTON
157
16
220
49
go
;; go-once\nifelse any? people with [length words != 1] [go-once][stop]
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
370
63
504
96
shortest-word
shortest-word
0
1
-1000

PLOT
14
491
496
641
Probability of success
ticks
P(success)
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"success" 1.0 0 -10899396 true "" "plot num-success / (max (list (num-success + num-failure) 1))"
"failure" 1.0 0 -7858858 true "" "plot num-failure / (max (list (num-success + num-failure) 1))"

SWITCH
222
16
369
49
sample-neighbor
sample-neighbor
1
1
-1000

SLIDER
370
17
516
50
neighbor-radius
neighbor-radius
3
30
5.0
1
1
NIL
HORIZONTAL

PLOT
1221
16
1589
230
Inventory Sizes
Inventory Size
Frequency
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"inventory-size" 1.0 1 -16777216 true "" "histogram [length words] of people"

@#$#@#$#@
## WHAT IS IT?

Implementation of **The Naming Game** model mentioned in the paper: 


> Baronchelli, A., Felici, M., Loreto, V., Caglioti, E., & Steels, L. (2006). Sharp transition towards shared vocabularies in multi-agent systems. Journal of Statistical Mechanics: Theory and Experiment, 2006(6), P06014–P06014. https://doi.org/10.1088/1742-5468/2006/06/p06014

This model is a way to study the evolution of words referring to an object in a closed world where a pair of people try to name an object by acting as a sender and reciever.
The sender selects a word from its inventory or generates a new word. The reciever compares the word to its own inventory. If the reciever adds the word to its inventory if the word is not present, otherwise it resets its inventory to only keep the sendor's word. The interaction is a success if the word selected by the sender is present in the reciever's inventory, otherwise it is a failure. The goal of the model is track how many unique words exist in the world, and on average how words are used by the people. 

## HOW IT WORKS


1. The model starts with `num-agents` number of people. Each person in initialized with an empty list of words. 
2. At each time step a random person is selected to be a sender.
3. Another person is selected as a reciever who is different from the sender. The selection of the reciever is based on two possible selection strategies. 
	- Random: Select a random person from the world as a reciever. 
	- Sample-neighbor: Select a random person from the neighborhood radius of size `neighbor-radius` of the sender. 
4. The sender selects a sender-word to send as a message to the reciever. This message is the word used by the sender to describe the object in the world. The word selection is based on the following strategies:
	- If the word inventory for the sender is empty create a new sender-word by sampling a random `word-length` between 1 and `max-word-length`. Then a word of length `word-length`is created by sampling a character between "a" and "z" for each position of the word. 
	- If the word inventory for the sender is non-empty, then the sender-word is selected by:
		* shortest word for the sender's word inventory, if `shortest-word` is ON
		* random word from the sender's word inventory, otherwise
5. Once the reciever recieves the message. It updates its inventory in the following ways:
	- If the word exists in the reciever's word inventory then the inventory is emptied and the sender-word is added to the inventory. This interaction is also considered a success, and `num-success` is incremented. 
	- If the word does not exists in the reciever's word inventory then the inventory the sender-word is added to the inventory. This interaction is also considered a failure, and `num-failure` is incremented. 
6. The global `all-words` list is set to all the unique words across all people. `total-words` is updated with the length of `all-words`. `mean-words` and `std-words` is also updated with the mean and standard deviation of number of words in each person's inventory.  


## HOW TO USE IT

SETUP button — sets up the model by creating the people.
GO button — runs the model
GO ONCE button — runs the model for one tick

The following inputs control how the model is setup:

SAMPLE-NEIGHBOR switch — weather to sample reciever from neighborhood of radius `neighbor-radius` of a sender
SHORTEST-WORD switch — weather to select the shortest word for the message by the sender or use a random word from the available word inventory of the sender
NUM-AGENTS slider - number of agents in the model
MAX-WORD-LENGTH slider - maximum allowed length for word used in a message


## THINGS TO NOTICE

Notice how the total unique words first rise to a max value and then converges to a very low value. If the `neighbor-radius` is very low then total unique words may converge to something small but not equal to 1. Also, notice that the mean number of words also rises  

## THINGS TO TRY

* Try different settings of `sample-neighbor`, `neighbor-radius`, `shortest-word`, `max-word-length`, and `num-agents`. 


## EXTENDING THE MODEL

* You may want to implement different ways of: sampling neighbors and sampling words for the sender
* The current world only has a single object. It would be interesting to change the code to allow multiple objects in the world. This will require keeping a seperate word list for each object within each person. 

## NETLOGO FEATURES

`in-radius` to sample from radius. 
`word` to create a new word. 

## CREDITS AND REFERENCES

If you are using this netlogo model file then please cite: 

Shubhanshu Mishra (2019). The Number Game. https://github.com/napsternxg/netlogo-models



The model was first presented in the paper: Baronchelli, A., Felici, M., Loreto, V., Caglioti, E., & Steels, L. (2006). Sharp transition towards shared vocabularies in multi-agent systems. Journal of Statistical Mechanics: Theory and Experiment, 2006(6), P06014–P06014. https://doi.org/10.1088/1742-5468/2006/06/p06014


## COPYRIGHT AND LICENSE

Copyright 2019 Shubhanshu Mishra.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Shubhanshu Mishra at https://twitter.com/TheShubhanshu.
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
NetLogo 6.0.2
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
