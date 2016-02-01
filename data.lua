require("_tools.prototypes.debug")

data:extend(
{
  {
    type = "item",
    name = "test",
    icon = "__test__/_tools/graphics/dbg-overlay-blue.png",
    flags = {"goes-to-quickbar"},
    subgroup = "transport",
    order = "b[personal-transport]-a[car]",
    place_result = "m2k-dbg-small-blue",
    stack_size = 100
  },

})