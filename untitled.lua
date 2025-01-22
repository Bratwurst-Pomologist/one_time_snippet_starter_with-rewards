----run----
local rewards = {
  {name = "default:diamond", count = 5}
}

local function get_random_reward()
  return rewards[math.random(#rewards)]
end

local function starting_snippets(playername)
  minetest.chat_send_all(playername .. " started the mods for the community and got a small present. Thank you " .. playername .. "!")
  snippets.run("A_run_all")

  local reward = get_random_reward()
  local player = minetest.get_player_by_name(playername)
  if player then
    local inv = player:get_inventory()
    inv:add_item("main", reward)
    minetest.chat_send_player(playername, "Thank you for your support " .. playername .. "! You got " .. reward.count .. " " .. reward.name .. ".")
  end
end

local function find_closest_player_to_spawn()
  local closest_player = nil
  local closest_distance = nil
  local spawn_pos = minetest.setting_get_pos("static_spawnpoint") or {x=0, y=0, z=0}

  for _, current_player in ipairs(minetest.get_connected_players()) do
    local pos = current_player:get_pos()
    local distance = vector.distance(pos, spawn_pos)

    if not closest_distance or distance < closest_distance then
      closest_distance = distance
      closest_player = current_player
    end
  end

  if closest_player then
    starting_snippets(closest_player:get_player_name())
  else
    return false, "No closest player could be found"
  end
end

find_closest_player_to_spawn()

----chk----
if _G.NAME and _G.NAME.running_snippets then
    minetest.chat_send_all("Snippets are already running. You can't get a reward. Thank you for your support.")
else
    snippets.run("bin")
end

----bin----
_G.NAME = _G.NAME or {}
_G.NAME.running_snippets = true
snippets.run("run")
