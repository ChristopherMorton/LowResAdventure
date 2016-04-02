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
         { side = "up", start = 26, finish = 37, to = "home" },
         { side = "right", start = 26, finish = 37, to = "miasma1" },
         { side = "down", start = 26, finish = 37, to = "home" }
      }
   },

   magnetpuzzle1 = { width = 64, height = 64,
      active = true,
      regenerate = true,
      doors = {
         { side = "left", start = 26, finish = 37, to = "home" },
         { side = "right", start = 26, finish = 37, to = "home" }
      },
      
      floor = {
      },

      objects = {
         { class = "block", color = "red", magnetic = true, x = 30, y = 30, width = 4, height = 4 }
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
