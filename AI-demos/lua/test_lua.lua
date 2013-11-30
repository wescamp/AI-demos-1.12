-- This is the manual 'AI handler'
-- Want this in a separate file, so that it can be changed on the fly
-- It loads the AI from another file which can then be executed by right-click menu

-- Start test scenario from command line with
-- /Applications/Wesnoth-1.11.app/Contents/MacOS/Wesnoth -d -l AI-demos-test.gz

-- Include all these, just in case (mostly not needed)
local H = wesnoth.require "lua/helper.lua"
local W = H.set_wml_action_metatable {}
local AH = wesnoth.dofile "~/add-ons/AI-demos/lua/ai_helper.lua"
local BC = wesnoth.dofile "~/add-ons/AI-demos/lua/battle_calcs.lua"
local LS = wesnoth.dofile "lua/location_set.lua"
local DBG = wesnoth.dofile "~/add-ons/AI-demos/lua/debug.lua"
H.set_wml_var_metatable(_G)

-- Clean up the screen
wesnoth.clear_messages()
AH.clear_labels()
print('\n---- Side ', wesnoth.current.side, '------------')

-- Check for debug mode and quit if it is not activated
if (not wesnoth.game_config.debug) then
    wesnoth.message("***** This option requires debug mode. Activate by typing ':debug' *****")
    return
end

-- Add shortcut to debug ai table
local ai = wesnoth.debug_ai(wesnoth.current.side).ai
--DBG.dbms(ai)

-- Load the custom AI into array 'my_ai'
fn = "~add-ons/AI-demos/lua/grunt_rush_Freelands_S1_engine.lua"
local my_ai = wesnoth.dofile(fn).init(ai)
my_ai.data = {}
--DBG.dbms(my_ai)

-----------------------------------------------------------------

local test_CA, exec_also = false, false

if test_CA then  -- Test a specific CA ...

    if (wesnoth.current.side == 1) then
        local start_time = wesnoth.get_time_stamp() / 1000.
        wesnoth.message('Start time:', start_time)
        local eval = my_ai:zone_control_eval()
        wesnoth.message('Eval score:', eval)
        wesnoth.message('Time after eval:', wesnoth.get_time_stamp() / 1000., wesnoth.get_time_stamp() / 1000. - start_time)
        if (exec_also) and (eval > 0) then
            my_ai:zone_control_exec()
            wesnoth.message('Time after exec:', wesnoth.get_time_stamp() / 1000., wesnoth.get_time_stamp() / 1000. - start_time)
        end
    else
        wesnoth.message("This only works when you're in control of Side 1")
    end

else  -- ... or do manual testing

    local leader = wesnoth.get_units{ side = 1, canrecruit = 'yes' }[1]
    local units = wesnoth.get_units{ side = 1, canrecruit = 'no' }
    local enemies = wesnoth.get_units{ side = 2, canrecruit = 'no' }
    print(#units,#enemies)

    local start_time = wesnoth.get_time_stamp() / 1000.
    wesnoth.message('Start time:', start_time)

    local map = LS.create()
    local path_map = LS.create()
    for i,u in ipairs(units) do
        local reach = wesnoth.find_reach(u)
        for j,r in ipairs(reach) do
            map:insert(r[1], r[2], 0)
            path_map:insert(r[1], r[2], 0)
        end
    end


for i,e in ipairs(enemies) do
    local ec = wesnoth.copy_unit(e)
    wesnoth.message(ec.id)

    local path, cost = wesnoth.find_path(ec, leader.x, leader.y, { ignore_units = true } )
    print(cost)

    map:iter( function( x, y, v )
        ec.x, ec.y = x, y

        local p1, c1 = wesnoth.find_path(ec, leader.x, leader.y, { ignore_units = true } )
        local p2, c2 = wesnoth.find_path(ec, e.x, e.y, { ignore_units = true } )

        local movecost = wesnoth.unit_movement_cost(ec, wesnoth.get_terrain(x,y))

        local value = c1+c2-cost+movecost-1

        if (value <= 2) then
            map:insert(x, y, map:get(x,y) + 1)
        end

        path_map:insert(x, y, path_map:get(x, y) + c1)

    end)

    ec = nil
end
    AH.put_labels(map)
    W.message{ speaker = 'narrator', message = '1' }
    AH.put_labels(path_map)

    wesnoth.message('Finish time:', wesnoth.get_time_stamp() / 1000. .. '  ' .. tostring(wesnoth.get_time_stamp() / 1000. - start_time))

















end
