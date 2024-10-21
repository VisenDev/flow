Flow = Flow

Flow:registerBindings("vim", {
  ["normal"] = {
    {["pattern"] = "j", ["action"] = {["command"] = "move_down"}},
    {["pattern"] = "k", ["action"] = {["command"] = "move_up"}},
    {["pattern"] = "h", ["action"] = {["command"] = "move_right_vim"}},
    {["pattern"] = "l", ["action"] = {["command"] = "move_left_vim"}},
  },
  ["insert"] = {
    {["pattern"] = "<else>", ["action"] = {["insert"] = ""}},
  }
})
