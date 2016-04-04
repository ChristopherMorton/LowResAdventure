roomDatabase = {

   home = { width = 64, height = 64,
      darkness = 60,
      doors = {
         { side = "left", start = 26, finish = 37, to = "magnetpuzzle1" },
         { side = "up", start = 26, finish = 37, to = "passage2", to_x = 74 },
         { side = "right", start = 26, finish = 37, to = "miasma1" },
         { side = "down", start = 26, finish = 37, to = "darkroom1", to_x = 13 },
         { side = "stairs", dir = "up", x = 28, y = 18, to = "passage3", to_x = 12, to_y = 6 },
      },
      floor = {
         { style = "ankh", mark = "drawing", x = 28, y = 27 },
         { style = "text", text = "Welcome", x = 16, y = 40 }
      },
      objects = {
         { id = "torch1", class = "torch", on=true, x = 6, y = 6, power = 20},
         { id = "torch2", class = "torch", on=true, x = 53, y = 6, power = 20},
         { id = "torch3", class = "torch", on=true, x = 6, y = 53, power = 20},
         { id = "torch4", class = "torch", on=false, to_timeout = 200, x = 53, y = 53, power = 20},
      },
   },


   -- INTRO ROOMS

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

   passage3 = { width = 21, height = 15,
      doors = {
         { side = "left", start = 5, finish = 9, to = "enemyroom1", to_y = 18 },
         { side = "stairs", dir = "down", x = 11, y = 4, to = "home", to_x = 30, to_y = 20 },
      },
      floor = {
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
         { id = "button1", class = "button", targets = { "lock" }, color = "black", x = 18, y = 12, width = 6, height = 6 },
         { id = "button2", class = "button", targets = { "lock" }, color = "black", x = 18, y = 24, width = 6, height = 6 },
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
         { id = "button1", class = "button", targets = { "lock" }, color = "black", x = 30, y = 6, width = 7, height = 7 },
         { id = "button2", class = "button", targets = { "lock" }, color = "black", x = 30, y = 18, width = 7, height = 7 },
         { id = "button3", class = "button", targets = { "lock" }, color = "black", x = 42, y = 6, width = 7, height = 7 },
         { id = "button4", class = "button", targets = { "lock" }, color = "black", x = 42, y = 18, width = 7, height = 7 },
      },
   },

   enemyroom1 = { width = 45, height = 40,
      doors = {
         { side = "left", start = 13, finish = 18, to = "blockpuzzle2" },
         { side = "right", start = 17, finish = 22, to = "passage3", to_y = 6 },
      },
      floor = {
         { style = "bomb", mark="drawing", x = 23, y = 18 },
      },
      objects = {
         { id = "lock", class = "lock", color = "white", locks = 2, x = 41, y = 15 , width = 3, height = 10 },
         { id = "bombtrap", class = "bombtrap", x = 22, y = 17 },
      },
      enemies = {
         { id = "blob1", class = "blob", color = "black", explodable = true, targets = { "lock" }, x = 12, y = 8 },
         { id = "blob2", class = "blob", color = "black", explodable = true, targets = { "lock" }, x = 24, y = 31 },
      },
      triggers = {
         { id = "button", class = "button", targets = { "bombtrap" }, color = "black", x = 32, y = 18, width = 5, height = 5 },
      }

   },


   -- END INTRO

   darkroom1 = { width = 75, height = 75,
      darkness = 245,
      doors = {
         { side = "up", start = 6, finish = 17, to = "home" },
         { side = "down", start = 58, finish = 69, to = "home", to_x = 30 },
      },
      floor = {
         { style = "rectangle", mark = "wall", x = 12, y = 36, width = 51, height = 3 },
         { style = "rectangle", mark = "wall", x = 36, y = 12, width = 3, height = 51 },
      },
      objects = {
         { id = "lock", class = "lock", color = "white", locks = 5, targets = { "torch1", "torch2", "torch3", "torch4", "torch5" }, x = 56, y = 71 , width = 16, height = 3 },
         { id = "torch1", class = "torch", on=false, to_timeout = 600, targets = { "lock" }, x = 15, y = 15, power = 15 },
         { id = "torch2", class = "torch", on=false, to_timeout = 600, targets = { "lock" }, x = 15, y = 55, power = 15 },
         { id = "torch3", class = "torch", on=false, to_timeout = 600, targets = { "lock" }, x = 55, y = 15, power = 15 },
         { id = "torch4", class = "torch", on=false, to_timeout = 600, targets = { "lock" }, x = 55, y = 55, power = 15 },
         { id = "torch5", class = "torch", on=false, to_timeout = 600, targets = { "lock" }, x = 35, y = 35, power = 15 },
      },
      enemies = {
         { id = "blob1", class = "blob", color = "black", x = 15, y = 62 },
         { id = "blob2", class = "blob", color = "black", x = 43, y = 21 },
         { id = "blob3", class = "blob", color = "black", x = 44, y = 45 },
         { id = "blob4", class = "blob", color = "black", x = 61, y = 60 },
      },
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
         { id = "b2", class = "block", color = "multicolor", color1 = "red", color2 = "blue", magnetic = true, resistance = 2, bombable = true, x = 10, y = 40, width = 6, height = 12 },
         { id = "b3", class = "block", color = "red", magnetic = true, resistance = 6, x = 40, y = 10, width = 16, height = 24 },
         { id = "b4", class = "block", color = "blue", bombable = true, x = 2, y = 20, width = 4, height = 24 },
      },
   },

   magnetpuzzle2 = { width = 64, height = 48,
      doors = {
         { side = "left", start = 26, finish = 37, to = "home" },
         { side = "up", start = 26, finish = 37, to = "home" },
      },
      floor = {
         { style = "rectangle", mark = "wall", x = 12, y = 30, width = 40, height = 2 },
         { style = "rectangle", mark = "wall", x = 50, y = 2, width = 2, height = 28 },
         { style = "deer", mark = "drawing", x = 28, y = 35 },
      },
      objects = {
         { id = "block", class = "block", color = "red", magnetic = true, resistance = 6, x = 12, y = 2, width = 10, height = 28 },
         { id = "block2", class = "block", color = "red", magnetic = true, resistance = 1, x = 44, y = 2, width = 6, height = 3 },
      },
      enemies = {
         { id = "blob1", class = "blob", color = "black", x = 24, y = 8 },
         { id = "blob2", class = "blob", color = "black", x = 28, y = 17 },
         { id = "blob3", class = "blob", color = "black", x = 36, y = 12 },
      },
      triggers = {
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
         { style = "miasmamark", mark = "drawing", x = 31, y = 31 },
      },
      objects = { 
         { class = "miasma", x = 31, y = 31, width = 2, height = 2 }
      }
   },

   miasma3 = { width = 64, height = 39,
      regenerate = true,
      doors = {
         { side = "left", start = 6, finish = 13, to = "home" },
         { side = "left", start = 25, finish = 32, to = "home" },
      },
      floor = {
         { style = "rectangle", mark = "wall", x = 12, y = 2, width = 2, height = 15 },
         { style = "rectangle", mark = "wall", x = 12, y = 22, width = 2, height = 15 },
         { style = "miasmamark", mark = "drawing", x = 23, y = 7 },
         { style = "miasmamark", mark = "drawing", x = 48, y = 7 },
         { style = "miasmamark", mark = "drawing", x = 23, y = 30 },
         { style = "miasmamark", mark = "drawing", x = 48, y = 30 },
         { style = "warpdot", mark = "drawing", x = 5, y = 17 },
      },
      objects = {
         { class = "miasma", x = 23, y = 7, width = 2, height = 2 },
         { class = "miasma", x = 48, y = 7, width = 2, height = 2 },
         { class = "miasma", x = 23, y = 30, width = 2, height = 2 },
         { class = "miasma", x = 48, y = 30, width = 2, height = 2 },

         { id = "toplock", class = "lock", color = "white", locks = 1, x = 14, y = 14, width = 48, height = 3 },
         { id = "botlock", class = "lock", color = "white", locks = 1, x = 14, y = 22, width = 48, height = 3 },
         { id = "doorlock", class = "lock", color = "white", locks = 1, x = 1, y = 23, width = 3, height = 12 },
      },
      triggers = {
         { id = "button", class = "button", targets = { "toplock", "botlock", "doorlock" }, color = "black", x = 57, y = 17, width = 5, height = 5 },
      },
   },
}
