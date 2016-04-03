roomDatabase = {

   home = { width = 64, height = 64,
      doors = {
         { side = "left", start = 26, finish = 37, to = "magnetpuzzle1" },
         { side = "up", start = 26, finish = 37, to = "passage2", to_x = 74 },
         { side = "right", start = 26, finish = 37, to = "miasma1" },
         { side = "down", start = 26, finish = 37, to = "blockpuzzle1", to_x = 13 }
      },
      floor = {
         { style = "ankh", mark = "drawing", x = 28, y = 27 },
         { style = "text", text = "Welcome", x = 16, y = 40 }
      },
   },

   passage1 = { width = 24, height = 24,
      doors = {
         { side = "up", start = 9, finish = 14, to = "passage2", to_x = 13 }
      },
      floor = {
         { style = "eye", mark = "drawing", x = 8, y = 10 }
      }
   },

   passage2 = { width = 90, height = 16,
      doors = {
         { side = "down", start = 12, finish = 17, to = "passage1" },
         { side = "down", start = 73, finish = 78, to = "blockpuzzle1", to_x = 13 }
      },
      floor = {
         { style = "cat", mark = "drawing", x = 80, y = 6 },
         { style = "deer", mark = "drawing", x = 40, y = 5 },
         { style = "spiral", mark = "drawing", x = 5, y = 5 },
      }
   },

   blockpuzzle1 = { width = 30, height = 40,
      doors = {
         { side = "up", start = 12, finish = 17, to = "passage2", to_x = 74 },
         { side = "down", start = 12, finish = 17, to = "blockpuzzle2" },
      },
      floor = {
      },
      objects = {
         { id = "block", class = "block", color = "black", pushable = true, resistance = 2, x = 6, y = 16, width = 4, height = 4 },
         { id = "lock", class = "lock", color = "white", locks = 2, x = 11, y = 36, width = 8, height = 3 },
      },
      triggers = {
         { id = "button1", class = "button", target = "lock", color = "black", x = 18, y = 12, width = 6, height = 6 },
         { id = "button2", class = "button", target = "lock", color = "black", x = 18, y = 24, width = 6, height = 6 },
      },
   },

   blockpuzzle2 = { width = 56, height = 31,
      doors = {
         { side = "up", start = 12, finish = 17, to = "blockpuzzle1" },
         { side = "right", start = 13, finish = 18, to = "enemyroom1" },
      },
      floor = {
         { style = "image", source = "res/reset_explanation.png", x = 15, y = 12 },
      },
      objects = {
         { id = "block1", class = "block", color = "black", pushable = true, resistance = 2, x = 2, y = 8, width = 5, height = 5 },
         { id = "block2", class = "block", color = "black", pushable = true, resistance = 2, x = 7, y = 8, width = 5, height = 5 },
         { id = "block3", class = "block", color = "black", pushable = true, resistance = 2, x = 7, y = 13, width = 5, height = 5 },
         { id = "block4", class = "block", color = "black", pushable = true, resistance = 2, x = 7, y = 18, width = 5, height = 5 },
         { id = "block5", class = "block", color = "black", pushable = true, resistance = 2, x = 2, y = 18, width = 5, height = 5 },
         { id = "lock", class = "lock", color = "white", locks = 4, x = 52, y = 11 , width = 3, height = 10 },
      },
      triggers = {
         { id = "button1", class = "button", target = "lock", color = "black", x = 30, y = 6, width = 7, height = 7 },
         { id = "button2", class = "button", target = "lock", color = "black", x = 30, y = 18, width = 7, height = 7 },
         { id = "button3", class = "button", target = "lock", color = "black", x = 42, y = 6, width = 7, height = 7 },
         { id = "button4", class = "button", target = "lock", color = "black", x = 42, y = 18, width = 7, height = 7 },
      },
   },

   enemyroom1 = { width = 45, height = 40,
      doors = {
         { side = "left", start = 13, finish = 18, to = "blockpuzzle2" },
         { side = "right", start = 17, finish = 22, to = "home", to_y = 30 },
      },
      floor = {
         { style = "bomb", mark="drawing", x = 23, y = 18 },
      },
      objects = {
         { id = "lock", class = "lock", color = "white", locks = 2, x = 41, y = 15 , width = 3, height = 10 },
         { id = "bombtrap", class = "bombtrap", x = 22, y = 17 },
      },
      enemies = {
         { id = "blob1", class = "blob", color = "black", explodable = true, deathtarget = "lock", x = 12, y = 8 },
         { id = "blob2", class = "blob", color = "black", explodable = true, deathtarget = "lock", x = 24, y = 31 },
      },
      triggers = {
         { id = "button", class = "button", target = "bombtrap", color = "black", x = 32, y = 18, width = 5, height = 5 },
      }

   },

   magnetpuzzle1 = { width = 64, height = 64,
      doors = {
         { side = "left", start = 26, finish = 37, to = "home" },
         { side = "right", start = 26, finish = 37, to = "home" }
      },
      
      floor = {
         { style = "companion", mark = "drawing", x = 4, y = 4 },
         { style = "apple", mark = "drawing", x = 48, y = 48 },
         { style = "scarab", mark = "drawing", x = 4, y = 48 },
         { style = "invader", mark = "drawing", x = 48, y = 4 },
      },

      objects = {
         { id = "b1", class = "block", color = "red", magnetic = true, x = 30, y = 30, width = 4, height = 4 },
         { id = "b2", class = "block", color = "red", magnetic = true, resistance = 2, x = 10, y = 40, width = 6, height = 12 },
         { id = "b3", class = "block", color = "red", magnetic = true, resistance = 6, x = 40, y = 10, width = 16, height = 24 },
         { id = "b4", class = "block", color = "blue", bombable = true, x = 2, y = 20, width = 4, height = 24 },
      },
   },

   miasma1 = { width = 64, height = 64,
      regenerate = true,
      doors = {
         { side = "left", start = 26, finish = 37, to = "home" },
         { side = "down", start = 26, finish = 37, to = "home" }
      },
      floor = {
         { style = "line", mark = "black", 
            start = { x = 2, y = 38 }, 
            moves = { 
               { dir = "right", dist = 11 }, 
               { dir = "up", dist = 25 },
               { dir = "right", dist = 37 },
               { dir = "down", dist = 37 },
               { dir = "left", dist = 25 },
               { dir = "down", dist = 11 } } },
         --[[
         { style = "line", mark = "black", 
            start = { x = 2, y = 39 }, 
            moves = { 
               { dir = "right", dist = 12 }, 
               { dir = "up", dist = 25 },
               { dir = "right", dist = 35 },
               { dir = "down", dist = 35 },
               { dir = "left", dist = 25 },
               { dir = "down", dist = 12 } } },
               --]]

         { style = "points", mark = "drawing", 
            points = { 
               { x = 31, y = 30 },
               { x = 32, y = 29 },
               { x = 31, y = 34 },
               { x = 32, y = 33 },
               { x = 29, y = 31 },
               { x = 30, y = 32 },
               { x = 33, y = 31 },
               { x = 34, y = 32 } }
         }
      },
      objects = { 
         { class = "miasma", x = 31, y = 31, width = 2, height = 2 }
      }
   }
}
