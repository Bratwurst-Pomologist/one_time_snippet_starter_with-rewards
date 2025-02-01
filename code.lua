--[[ This code is for three separate snippets which have to be registered separately. "run", "chk" and "bin". These codes manage the start for a fourth snippet ("A_run_all" - not included), which have to start just once after restart/crash. "chk" code can be placed in a snippet button at a public place so that every player can start all snippets just once per server run. The player receives a small gift as a thank you. This reward can be received once per server run.]]

----run----
local spam = 0
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
local function reset_spam()
  _G.spam.count = 0
end 

local function find_closest_player_to_spawn_to_kick()
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
    minetest.kick_player(closest_player:get_player_name(), "Kicked because of spaming chat.")
  else
    return false, "No closest player could be found"
  end
end

if _G.NAME and _G.NAME.running_snippets then
    minetest.chat_send_all("Snippets are already running. You can't get a reward. Thank you for your support.")
    _G.spam.count = _G.spam.count + 1
    if _G.spam.count > 3 then
      minetest.chat_send_all("STOP SPAMMING OR GET A KICK!")
    end
    if _G.spam.count > 5 then 
    find_closest_player_to_spawn_to_kick()
    end
    minetest.after(15, reset_spam)
else
    snippets.run("bin")
end

----bin----
_G.spam = _G.spam or {}
_G.spam.count = 0
_G.NAME = _G.NAME or {}
_G.NAME.running_snippets = true
snippets.run("run")
