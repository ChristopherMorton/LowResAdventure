roomDatabase = {


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
         { id = "lock", class = "lock", locks = 2, x = 11, y = 36, width = 8, height = 3 },
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
         { id = "lock", class = "lock", locks = 4, x = 52, y = 11 , width = 3, height = 10 },
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
         { id = "lock", class = "lock", locks = 2, x = 41, y = 15 , width = 3, height = 10 },
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


   -- HOME-CENTERED

   home = { width = 64, height = 64,
      darkness = 60,
      doors = {
         { side = "left", start = 26, finish = 37, to = "menagerie", to_y = 12 },
         { side = "up", start = 26, finish = 37, to = "magnetpassage1", to_x = 4 },
         { side = "right", start = 26, finish = 37, to = "miasma1" },
         { side = "down", start = 26, finish = 37, to = "darkpassage1", to_x = 4 },
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

   -- Left

   menagerie = { width = 100, height = 144,
      doors = {
         { side = "right", start = 9, finish = 20, to = "home", to_y = 30 },
         { side = "left", start = 5, finish = 16, to = "magnetpuzzle1", to_y = 30 },
         { side = "left", closed_on = 1, start = 111, finish = 122, to = "bossentry1", to_y = 13 },
         { side = "down", start = 87, finish = 94, to = "home", to_y = 30 },
      },
      floor = {
         { style = "rectangle", mark = "wall", x = 2, y = 20, width = 12, height = 2 },
         { style = "rectangle", mark = "wall", x = 12, y = 127, width = 86, height = 3 },
         -- Cage 1
         { style = "rectangle", mark = "wall", x = 26, y = 24, width = 2, height = 26 },
         { style = "rectangle", mark = "wall", x = 86, y = 24, width = 2, height = 26 },
         -- Cage 2
         { style = "rectangle", mark = "wall", x = 12, y = 58, width = 2, height = 26 },
         { style = "rectangle", mark = "wall", x = 72, y = 58, width = 2, height = 26 },
         -- Cage 3
         { style = "rectangle", mark = "wall", x = 20, y = 92, width = 2, height = 26 },
         { style = "rectangle", mark = "wall", x = 80, y = 92, width = 2, height = 26 },
      },
      objects = {
         { id = "redblock", class = "block", color = "red", magnetic = true, x = 10, y = 2, width = 4, height = 18 },
         -- Cage 1
         { id = "cagelock1", class = "lock", locks = 1, x = 28, y = 24 , width = 58, height = 3 },
         { id = "cagelock2", class = "lock", locks = 1, x = 28, y = 47 , width = 58, height = 3 },
         -- Cage 2
         { id = "cagelock3", class = "lock", locks = 1, x = 14, y = 58 , width = 58, height = 3 },
         { id = "cagelock4", class = "lock", locks = 1, x = 14, y = 81 , width = 58, height = 3 },
         -- Cage 3
         { id = "cagelock5", class = "lock", locks = 1, x = 22, y = 92 , width = 58, height = 3 },
         { id = "cagelock6", class = "lock", locks = 1, x = 22, y = 115 , width = 58, height = 3 },

         { id = "lock7", class = "lock", locks = 1, x = 2, y = 127 , width = 10, height = 3 },

         { id = "hiddenlock1", class = "hiddenlock", locks = 1, x = 96, y = 7, width = 3, height = 16 },
         { id = "hiddenlock2", class = "hiddenlock", locks = 1, x = 1, y = 3, width = 3, height = 16 },
         { id = "hiddenlock3", class = "hiddenlock", locks = 1, x = 85, y = 140, width = 16, height = 3 }
      },
      enemies = {
         { id = "violetblob1", class = "blob", color = "violet", swordable = true, targets = { "hiddenlock1", "hiddenlock2", "hiddenlock3" }, x = 30, y = 4 },
         { id = "blueblob1", class = "blob", color = "blue", bombable = true, targets = { "hiddenlock1", "hiddenlock2", "hiddenlock3" }, x = 40, y = 4 },
         { id = "redblob1", class = "blob", color = "red", magnetic = true, targets = { "hiddenlock1", "hiddenlock2", "hiddenlock3" }, x = 50, y = 4 },
      },
      triggers = {
         { id = "unlock", class = "button", targets = { "cagelock1", "cagelock2", "cagelock3", "cagelock4", "cagelock5", "cagelock6", "lock7", "hiddenlock1", "hiddenlock2", "hiddenlock3" }, color = "black", x = 68, y = 132, width = 8, height = 8 },

      },

   },

   bossentry1 = { width = 64, height = 29,
      doors = {
         { side = "right", start = 10, finish = 18, to = "menagerie", to_y = 114 },
         { side = "left", start = 10, finish = 18, to = "boss1", to_y = 30 },
      },
      floor = {
         { style = "rectangle", mark = "drawing", x = 1, y = 11, width = 62, height = 7 },
      },
      objects = {
         { id = "torch1", class = "torch", on=true, x = 2, y = 2, power = 1 },
         { id = "torch2", class = "torch", on=true, x = 2, y = 22, power = 1 },

         { id = "b1", class = "block", color = "black", pushable = true, resistance = 2, x = 22, y = 2, width = 5, height = 5 },
         { id = "b2", class = "block", color = "black", pushable = true, resistance = 2, x = 27, y = 2, width = 5, height = 5 },
         { id = "b3", class = "block", color = "black", pushable = true, resistance = 2, x = 42, y = 2, width = 5, height = 5 },

         { id = "b4", class = "block", color = "black", pushable = true, resistance = 2, x = 12, y = 7, width = 5, height = 5 },
         { id = "b5", class = "block", color = "black", pushable = true, resistance = 2, x = 17, y = 7, width = 5, height = 5 },
         { id = "b6", class = "block", color = "black", pushable = true, resistance = 2, x = 32, y = 7, width = 5, height = 5 },
         { id = "b7", class = "block", color = "black", pushable = true, resistance = 2, x = 37, y = 7, width = 5, height = 5 },
         { id = "b8", class = "block", color = "black", pushable = true, resistance = 2, x = 42, y = 7, width = 5, height = 5 },

         { id = "b9", class = "block", color = "black", pushable = true, resistance = 2, x = 12, y = 12, width = 5, height = 5 },
         { id = "b10", class = "block", color = "black", pushable = true, resistance = 2, x = 22, y = 12, width = 5, height = 5 },
         { id = "b11", class = "block", color = "black", pushable = true, resistance = 2, x = 27, y = 12, width = 5, height = 5 },
         { id = "b12", class = "block", color = "black", pushable = true, resistance = 2, x = 37, y = 12, width = 5, height = 5 },
         { id = "b13", class = "block", color = "black", pushable = true, resistance = 2, x = 47, y = 12, width = 5, height = 5 },

         { id = "b14", class = "block", color = "black", pushable = true, resistance = 2, x = 17, y = 17, width = 5, height = 5 },
         { id = "b15", class = "block", color = "black", pushable = true, resistance = 2, x = 32, y = 17, width = 5, height = 5 },
         { id = "b16", class = "block", color = "black", pushable = true, resistance = 2, x = 37, y = 17, width = 5, height = 5 },
         { id = "b17", class = "block", color = "black", pushable = true, resistance = 2, x = 47, y = 17, width = 5, height = 5 },

         { id = "b18", class = "block", color = "black", pushable = true, resistance = 2, x = 17, y = 22, width = 5, height = 5 },
         { id = "b19", class = "block", color = "black", pushable = true, resistance = 2, x = 22, y = 22, width = 5, height = 5 },
         { id = "b20", class = "block", color = "black", pushable = true, resistance = 2, x = 27, y = 22, width = 5, height = 5 },
         { id = "b21", class = "block", color = "black", pushable = true, resistance = 2, x = 37, y = 22, width = 5, height = 5 },
         { id = "b22", class = "block", color = "black", pushable = true, resistance = 2, x = 42, y = 22, width = 5, height = 5 },
      },
   },
   
   boss1 = { width = 100, height = 64,
      doors = {
         { side = "right", closed_on = 0, start = 26, finish = 37, to = "bossentry1" },
         { side = "up", start = 44, finish = 55, to = "magnetthrone", to_x = 30 },
      },
      floor = {
         { style = "bomb", mark="drawing", x = 48, y = 30 },

         { style = "spottedrectangle", mark = "drawing", x = 10, y = 25, width = 88, height = 3 },
         { style = "spottedrectangle", mark = "drawing", x = 10, y = 28, width = 36, height = 8 },
         { style = "spottedrectangle", mark = "drawing", x = 54, y = 28, width = 44, height = 8 },
         { style = "spottedrectangle", mark = "drawing", x = 10, y = 36, width = 88, height = 3 },
         { style = "line", mark = "drawing", x = 97, y = 25,
            moves = { { dir = "left", dist = 87 }, 
                      { dir = "down", dist = 13 }, 
                      { dir = "right", dist = 87 } } },

         { style = "rectangle", mark = "wall", x = 27, y = 12, width = 3, height = 5 },
         { style = "rectangle", mark = "wall", x = 26, y = 13, width = 5, height = 3 },

         { style = "rectangle", mark = "wall", x = 27, y = 47, width = 3, height = 5 },
         { style = "rectangle", mark = "wall", x = 26, y = 48, width = 5, height = 3 },

         { style = "rectangle", mark = "wall", x = 48, y = 12, width = 3, height = 5 },
         { style = "rectangle", mark = "wall", x = 47, y = 13, width = 5, height = 3 },

         { style = "rectangle", mark = "wall", x = 48, y = 47, width = 3, height = 5 },
         { style = "rectangle", mark = "wall", x = 47, y = 48, width = 5, height = 3 },

         { style = "rectangle", mark = "wall", x = 69, y = 12, width = 3, height = 5 },
         { style = "rectangle", mark = "wall", x = 68, y = 13, width = 5, height = 3 },

         { style = "rectangle", mark = "wall", x = 69, y = 47, width = 3, height = 5 },
         { style = "rectangle", mark = "wall", x = 68, y = 48, width = 5, height = 3 },

         { style = "rectangle", mark = "wall", x = 81, y = 30, width = 3, height = 5 },
         { style = "rectangle", mark = "wall", x = 80, y = 31, width = 5, height = 3 },

         { style = "rectangle", mark = "wall", x = 8, y = 28, width = 2, height = 8 },
         { style = "rectangle", mark = "wall", x = 7, y = 29, width = 1, height = 6 },
      },
      objects = {
         { id = "bombtrap1", class = "bombtrap", x = 43, y = 25 },
         { id = "bombtrap2", class = "bombtrap", x = 50, y = 25 },
         { id = "bombtrap3", class = "bombtrap", x = 43, y = 32 },
         { id = "bombtrap4", class = "bombtrap", x = 50, y = 32 },
         { id = "torch1", class = "torch", on=true, x = 2, y = 2, power = 1 },
         { id = "torch2", class = "torch", on=true, x = 2, y = 57, power = 1 },
         { id = "torch3", class = "torch", on=true, x = 93, y = 2, power = 1 },
         { id = "torch4", class = "torch", on=true, x = 93, y = 57, power = 1 },
         { id = "lock", class = "lock", locks = 1, x = 42, y = 1, width = 16, height = 3 },
      },
      enemies = {
         { id = "boss1", class = "boss1", x = 10, y = 28 }
      },
      triggers = {
         { id = "startfight", class = "area", targets = { "boss1" }, x = 0, y = 0, width = 80, height = 64 },
         { id = "button1", class = "button", targets = { "bombtrap1", "bombtrap2", "bombtrap3", "bombtrap4" }, color = "black", x = 8, y = 8, width = 6, height = 6 },
         { id = "button2", class = "button", targets = { "bombtrap1", "bombtrap2", "bombtrap3", "bombtrap4" }, color = "black", x = 86, y = 8, width = 6, height = 6 },
         { id = "button3", class = "button", targets = { "bombtrap1", "bombtrap2", "bombtrap3", "bombtrap4" }, color = "black", x = 8, y = 50, width = 6, height = 6 },
         { id = "button4", class = "button", targets = { "bombtrap1", "bombtrap2", "bombtrap3", "bombtrap4" }, color = "black", x = 86, y = 50, width = 6, height = 6 },

      },
   },

   magnetthrone = { width = 64, height = 64,
      regenerate = true,
      doors = {
         { side = "right", hidden = true, start = 26, finish = 37, to = "magnetpuzzle1" },
         { side = "down", closed_on = 0, start = 26, finish = 37, to = "boss1", to_y = 58 },
      },
      floor = {
         { style = "magnet", mark = "drawing", x = 7, y = 14 },
         { style = "magnet", mark = "drawing", x = 49, y = 14 },
         { style = "image", source = "res/magnet_explanation.png", x = 7, y = 44 },
         { style = "text", text = "[space]", x = 17, y = 51 },
         { style = "altar" },
      },
      objects = {
         { id = "magnet", class = "magnet", x = 28, y = 18, width = 8, height = 8 },
         { id = "torch1", class = "torch", on=true, x = 2, y = 2, power = 1 },
         { id = "torch2", class = "torch", on=true, x = 2, y = 57, power = 1 },
         { id = "torch3", class = "torch", on=true, x = 57, y = 2, power = 1 },
         { id = "torch4", class = "torch", on=true, x = 57, y = 57, power = 1 },
         { id = "altartorch1", class = "torch", on=true, x = 23, y = 35, power = 1 },
         { id = "altartorch2", class = "torch", on=true, x = 36, y = 35, power = 1 },
         { id = "block", class = "block", color = "red", magnetic = true, x = 59, y = 24, width = 3, height = 16 },
      }
   },

   magnetpuzzle1 = { width = 64, height = 64,
      doors = {
         { side = "left", closed_on = 1, start = 26, finish = 37, to = "magnetthrone" },
         { side = "right", start = 26, finish = 37, to = "menagerie", to_y = 12 }
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
      },
   },

   -- Up

   magnetpassage1 = { width = 12, height = 40,
      doors = {
         { side = "up", start = 3, finish = 8, to = "magnetpuzzle2", to_x = 9 },
         { side = "down", start = 3, finish = 8, to = "home", to_x = 30 }
      },
      floor = {
      },
      objects = {
         { id = "b1", class = "block", color = "black", pushable = true, resistance = 2, x = 2, y = 16, width = 4, height = 4 },
         { id = "b2", class = "block", color = "black", pushable = true, resistance = 2, x = 6, y = 16, width = 4, height = 4 },
         { id = "m1", class = "block", color = "red", magnetic = true, x = 2, y = 12, width = 4, height = 4 },
         { id = "m2", class = "block", color = "red", magnetic = true, x = 6, y = 12, width = 4, height = 4 },
         { id = "m3", class = "block", color = "red", magnetic = true, x = 2, y = 20, width = 4, height = 4 },
         { id = "m4", class = "block", color = "red", magnetic = true, x = 6, y = 20, width = 4, height = 4 },

      }
   },

   magnetpuzzle3 = { width = 64, height = 48,
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

   lampthrone = { width = 64, height = 64,
      regenerate = true,
      darkness = 105,
      doors = {
         { side = "right", hidden = true, start = 26, finish = 37, to = "home" },
         { side = "down", closed_on = 0, start = 26, finish = 37 },
      },
      floor = {
         { style = "lamp", mark = "drawing", x = 7, y = 12 },
         { style = "lamp", mark = "drawing", x = 49, y = 12 },
         { style = "lamp", mark = "drawing", x = 7, y = 24 },
         { style = "lamp", mark = "drawing", x = 49, y = 24 },
         { style = "image", source = "res/lamp_explanation.png", x = 23, y = 45 },
         { style = "altar" },
      },
      objects = {
         { id = "lamp", class = "lamp", x = 28, y = 18, width = 8, height = 8 },
         { id = "lock", class = "lock", locks = 2, targets = { "altartorch1", "altartorch2" }, x = 59, y = 24, width = 3, height = 16 },
         { id = "torch1", class = "torch", on=true, x = 2, y = 2, power = 20 },
         { id = "torch2", class = "torch", on=true, x = 2, y = 57, power = 20 },
         { id = "torch3", class = "torch", on=true, x = 57, y = 2, power = 20 },
         { id = "torch4", class = "torch", on=true, x = 57, y = 57, power = 20 },
         { id = "altartorch1", class = "torch", on=false, to_timeout=80, targets = { "lock" }, x = 23, y = 35, power = 20 },
         { id = "altartorch2", class = "torch", on=false, to_timeout=80, targets = { "lock" }, x = 36, y = 35, power = 20 },
      }
   },

   -- Down

   darkpassage1 = { width = 12, height = 30,
      darkness = 180,
      doors = {
         { side = "up", start = 3, finish = 8, to = "home", to_x = 30 },
         { side = "down", start = 3, finish = 8, to = "darkroom1", to_x = 9 }
      },
      floor = {
      }
   },

   darkroom1 = { width = 75, height = 75,
      darkness = 245,
      doors = {
         { side = "up", start = 8, finish = 13, to = "darkpassage1", to_x = 4 },
         { side = "down", start = 58, finish = 69, to = "home", to_x = 30 },
      },
      floor = {
         { style = "rectangle", mark = "wall", x = 12, y = 36, width = 51, height = 3 },
         { style = "rectangle", mark = "wall", x = 36, y = 12, width = 3, height = 51 },
      },
      objects = {
         { id = "lock", class = "lock", locks = 5, targets = { "torch1", "torch2", "torch3", "torch4", "torch5" }, x = 56, y = 71 , width = 16, height = 3 },
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

   bombthrone = { width = 64, height = 64,
      regenerate = true,
      doors = {
         { side = "right", hidden = true, start = 26, finish = 37, to = "home" },
         { side = "down", closed_on = 0, start = 26, finish = 37 },
      },
      floor = {
         { style = "bomb", mark = "drawing", x = 7, y = 12 },
         { style = "bomb", mark = "drawing", x = 49, y = 10 },
         { style = "bomb", mark = "drawing", x = 7, y = 24 },
         { style = "image", source = "res/bomb_explanation.png", x = 10, y = 45 },
         { style = "altar" },
         { style = "line", mark = "black", x = 61, y = 21, 
            moves = { { dir = "left", dist = 9 }, 
                      { dir = "down", dist = 21 },
                      { dir = "right", dist = 4 } } },
         { style = "line", mark = "black", x = 61, y = 20, 
            moves = { { dir = "left", dist = 8 }, 
                      { dir = "down", dist = 23 },
                      { dir = "right", dist = 3 } } },
      },
      objects = {
         { id = "bigbomb", class = "bigbomb", x = 29, y = 18, width = 6, height = 8 },
         { id = "block", class = "block", color = "blue", bombable = true, x = 59, y = 24, width = 3, height = 16 },
         { id = "blackblock", class = "block", color = "black", pushable = true, resistance = 2, x = 57, y = 40, width = 5, height = 5 },
         { id = "torch1", class = "torch", on=true, x = 2, y = 2, power = 20 },
         { id = "torch2", class = "torch", on=true, x = 2, y = 57, power = 20 },
         { id = "torch3", class = "torch", on=true, x = 57, y = 2, power = 20 },
         { id = "torch4", class = "torch", on=true, x = 57, y = 57, power = 20 },
         { id = "altartorch1", class = "torch", on=true, x = 23, y = 35, power = 20 },
         { id = "altartorch2", class = "torch", on=true, x = 36, y = 35, power = 20 },
      }
   },

   -- Right

   miasma1 = { width = 64, height = 64,
      regenerate = true,
      doors = {
         { side = "left", start = 26, finish = 37, to = "home" },
         { side = "down", start = 26, finish = 37, to = "miasma2" },
      },
      floor = {
         { style = "line", mark = "black", x = 2, y = 38, 
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

   miasma2 = { width = 64, height = 22,
      regenerate = true,
      doors = {
         { side = "up", start = 26, finish = 37, to = "miasma1" },
         { side = "left", start = 7, finish = 14, to = "home", to_y = 30 },
         { side = "right", start = 7, finish = 14, to = "miasma3", to_y = 8 },
      },
      floor = {
         { style = "rectangle", mark = "wall", x = 10, y = 10, width = 44, height = 2 },
         { style = "miasmamark", mark = "drawing", x = 31, y = 15 },
      },
      objects = {
         { class = "miasma", x = 31, y = 15, width = 2, height = 2 },
         { id = "block", class = "block", color = "blue", bombable = true, x = 10, y = 2, width = 8, height = 8 },
      }
   },

   miasma3 = { width = 64, height = 39,
      regenerate = true,
      doors = {
         { side = "left", start = 6, finish = 13, to = "miasma2", to_y = 9 },
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

         { id = "toplock", class = "lock", locks = 1, x = 14, y = 14, width = 48, height = 3 },
         { id = "botlock", class = "lock", locks = 1, x = 14, y = 22, width = 48, height = 3 },
         { id = "doorlock", class = "lock", locks = 1, x = 1, y = 23, width = 3, height = 12 },
      },
      triggers = {
         { id = "button", class = "button", targets = { "toplock", "botlock", "doorlock" }, color = "black", x = 57, y = 17, width = 5, height = 5 },
      },
   },

   -- Wherever

   warpthrone = { width = 64, height = 64,
      regenerate = true,
      darkness = 80,
      doors = {
         { side = "right", hidden = true, start = 26, finish = 37, to = "home" },
         { side = "down", closed_on = 0, start = 26, finish = 37 },
      },
      floor = {
         { style = "fish", mark = "drawing", x = 6, y = 15 },
         { style = "scarab", mark = "drawing", x = 49, y = 10 },
         { style = "image", source = "res/warp_explanation.png", x = 9, y = 45 },
         { style = "altar" },
      },
      objects = {
         { id = "warp", class = "warp", x = 29, y = 19, width = 5, height = 5 },
         { id = "lock", class = "lock", locks = 2, targets = { "torch1", "torch4" }, x = 59, y = 24, width = 3, height = 16 },
         { id = "torch1", class = "torch", on=false, to_timeout = 80, targets = { "lock" }, x = 2, y = 2, power = 20 },
         { id = "torch2", class = "torch", on=true, x = 2, y = 57, power = 20 },
         { id = "torch3", class = "torch", on=true, x = 57, y = 2, power = 20 },
         { id = "torch4", class = "torch", on=false, to_timeout = 80, targets = { "lock" }, x = 57, y = 57, power = 20 },
         { id = "altartorch1", class = "torch", on=true, x = 23, y = 35, power = 20 },
         { id = "altartorch2", class = "torch", on=true, x = 36, y = 35, power = 20 },
      }
   },

   swordthrone = { width = 64, height = 64,
      regenerate = true,
      doors = {
         { side = "right", hidden = true, start = 26, finish = 37, to = "home" },
         { side = "down", closed_on = 0, start = 26, finish = 37 },
      },
      floor = {
         { style = "sword", mark = "drawing", x = 6, y = 13 },
         { style = "sword", mark = "drawing", x = 49, y = 13 },
         { style = "miasmamark", mark = "drawing", x = 56, y = 30 },
         { style = "image", source = "res/bomb_explanation.png", x = 9, y = 45 },
         { style = "rectangle", mark = "wall", x = 50, y = 24, width = 12, height = 2 },
         { style = "rectangle", mark = "wall", x = 50, y = 24, width = 2, height = 17 },
         { style = "rectangle", mark = "wall", x = 2, y = 24, width = 12, height = 2 },
         { style = "rectangle", mark = "wall", x = 2, y = 38, width = 12, height = 2 },
         { style = "altar" },
      },
      objects = {
         { class = "miasma", x = 56, y = 30, width = 2, height = 2 },
         { id = "sword", class = "sword", x = 28, y = 18, width = 8, height = 8 },
         { id = "lock", class = "lock", locks = 1, x = 52, y = 38, width = 10, height = 3 },
         { id = "block", class = "block", color = "violet", swordable = true, x = 10, y = 26, width = 4, height = 12 },

         { id = "torch1", class = "torch", on=true, x = 2, y = 2, power = 20 },
         { id = "torch2", class = "torch", on=true, x = 2, y = 57, power = 20 },
         { id = "torch3", class = "torch", on=true, x = 57, y = 2, power = 20 },
         { id = "torch4", class = "torch", on=true, x = 57, y = 57, power = 20 },
         { id = "altartorch1", class = "torch", on=true, x = 23, y = 35, power = 20 },
         { id = "altartorch2", class = "torch", on=true, x = 36, y = 35, power = 20 },
      },
      triggers = {
         { id = "button1", class = "button", targets = { "lock" }, color = "black", x = 2, y = 28, width = 6, height = 8 },
      },
   },
}
