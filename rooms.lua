roomDatabase = {

   test1 = { width = 64, height = 64, 
      doors = { 
         { side = "right", start = 25, finish = 40, to = "test2" } 
      }
   },

   test2 = { width = 64, height = 64, 
      doors = { 
         { side = "left", start = 25, finish = 40, to = "test1" } 
      },
      floor = {
         { mark = "line", start = { x = 10, y = 10 }, moves = { { dir = "right", dist = 30 }, { dir = "down", dist = 30 }, { dir = "left", dist = 30 } } }
      }
   },




   -- Real rooms

   home = { width = 64, height = 64,
      doors = {
         { side = "left", start = 26, finish = 37, to = "magnetpuzzle1" },
         { side = "up", start = 26, finish = 37, to = "passage2", to_x = 87 },
         { side = "right", start = 26, finish = 37, to = "miasma1" },
         { side = "down", start = 26, finish = 37, to = "home" }
      }
   },

   passage1 = { width = 24, height = 24,
      doors = {
         { side = "up", start = 9, finish = 14, to = "passage2" }
      },
      floor = {
         { style = "points", mark = "drawing", 
            points = { 
               { x = 11, y = 11 },
               { x = 12, y = 11 },
               { x = 12, y = 12 },
               { x = 11, y = 12 },

               { x = 9, y = 11 },
               { x = 10, y = 10 },
               { x = 11, y = 10 },
               { x = 12, y = 10 },
               { x = 13, y = 10 },
               { x = 14, y = 11 },

               { x = 8, y = 12 },
               { x = 9, y = 13 },
               { x = 10, y = 14 },
               { x = 11, y = 14 },
               { x = 12, y = 14 },
               { x = 13, y = 14 },
               { x = 14, y = 13 }, 
               { x = 15, y = 12 }, 
            }
         }
      }
   },

   passage2 = { width = 100, height = 16,
      doors = {
         { side = "down", start = 9, finish = 14, to = "passage1" },
         { side = "down", start = 83, finish = 94, to = "home", to_x = 29 }
      },
      floor = {
      }
   },

   magnetpuzzle1 = { width = 64, height = 64,
      active = true,
      doors = {
         { side = "left", start = 26, finish = 37, to = "home" },
         { side = "right", start = 26, finish = 37, to = "home" }
      },
      
      floor = {
      },

      objects = {
         { id = "b1", class = "block", color = "red", magnetic = true, x = 30, y = 30, width = 4, height = 4 },
         { id = "b2", class = "block", color = "red", magnetic = true, resistance = 2, x = 10, y = 40, width = 6, height = 12 },
         { id = "b3", class = "block", color = "red", magnetic = true, resistance = 6, x = 40, y = 10, width = 16, height = 24 }
      }
   },

   miasma1 = { width = 64, height = 64,
      active = true,
      regenerate = true,
      doors = {
         { side = "left", start = 26, finish = 37, to = "home" },
         { side = "down", start = 26, finish = 37, to = "home" }
      },
      floor = {
         { style = "line", mark = "hole", 
            start = { x = 2, y = 38 }, 
            moves = { 
               { dir = "right", dist = 11 }, 
               { dir = "up", dist = 25 },
               { dir = "right", dist = 37 },
               { dir = "down", dist = 37 },
               { dir = "left", dist = 25 },
               { dir = "down", dist = 11 } } },
         --[[
         { style = "line", mark = "hole", 
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
