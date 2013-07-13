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

-- Load the custom AI into array 'my_ai'
fn = "~add-ons/AI-demos/lua/grunt-rush-Freelands-S1_engine.lua"
--fn = "ai/micro_ais/ais/mai_goto_engine.lua"
local my_ai = wesnoth.dofile(fn).init(ai)
my_ai.data = {}
--DBG.dbms(my_ai)

-- Clean up the screen
wesnoth.clear_messages()
AH.clear_labels()
print('\n---- Side ', wesnoth.current.side, '------------')

-----------------------------------------------------------------

local function best_perm(m,n,i_0,arr,max_rating)

    i_0 = i_0 or 1
    arr = arr or {}
    local r = #arr+1
    max_rating = max_rating or -9e99

    for i = i_0,n-m+r do
        print('r = ' .. r .. '   i = ' .. i)

        local rating = 0
        for j,v in ipairs(arr) do
            rating = rating
        end

        table.insert(arr,i)
        if (r == m) then
            DBG.dbms(arr)
            --print('\n---')
            --for j,k in ipairs(arr) do print(j,k) end
            --print('xxx')
        else
            best_perm(m,n,i+1,arr)

        end
        table.remove(arr)
    end


end

local test_CA, exec_also = false, false

if test_CA then  -- Test a specific CA ...
    my_ai.data = {}

    local cfg = {}
    cfg.goto_units = { type = 'Spearman' }
    cfg.goto_goals = { y = '28' }
    cfg.avoid_enemies = { true }


    if (wesnoth.current.side == 1) then
        local start_time = wesnoth.get_time_stamp() / 1000.
        wesnoth.message('Start time:', start_time)
        local eval = my_ai:goto_eval(cfg)
        wesnoth.message('Eval score:', eval)
        wesnoth.message('Time after eval:', wesnoth.get_time_stamp() / 1000., wesnoth.get_time_stamp() / 1000. - start_time)
        if (exec_also) and (eval > 0) then
            my_ai:goto_exec(cfg)
            wesnoth.message('Time after exec:', wesnoth.get_time_stamp() / 1000., wesnoth.get_time_stamp() / 1000. - start_time)
        end
    else
        wesnoth.message("This only works when you're in control of Side 1")
    end

else  -- ... or do manual testing

    local units = wesnoth.get_units{ side = 1, canrecruit = 'no' }
    local enemies = wesnoth.get_units{ side = 2, canrecruit = 'no' }
    --print(#units,#enemies)
    local attacker = units[1]
    local defender = enemies

    local start_time = AH.print_ts()

    local eval = 0

--    DBG.dbms(wesnoth.unit_types)
    print(attacker.id)

                for attack in H.child_range(wesnoth.unit_types[attacker.type].__cfg, "attack") do
                    for special in H.child_range(attack, 'specials') do
                        mod = H.get_child(special, 'chance_to_hit')
                        if mod then
DBG.dbms(mod)
print(mod.cumulative, mod.value)
                        end
                    end
                end


if 1 then return end

    local dst = { 20, 8 }
    local dsts = { {21, 10}, { 21, 9}, { 20, 8 } }
    --local dsts = { {21, 9}, { 21, 9}, { 21, 9 } }

    local start_time = wesnoth.get_time_stamp() / 1000.
    wesnoth.message('Start time:', start_time)

    local cache={}
    local cfg = {att_weapon = 2, def_weapon = 2, dst = dst}

    for i=1,1 do
        --att_stats,def_stats = BC.battle_outcome(attacker, defender, cfg, cache)
        --tmp = BC.attack_combo_stats(units, dsts, defender, cache)
    end
    --DBG.dbms(tmp)

    --DBG.dbms(def_stats)
    wesnoth.message('Time after loop:', wesnoth.get_time_stamp() / 1000. .. '  ' .. tostring(wesnoth.get_time_stamp() / 1000. - start_time))

    local r = BC.attack_rating(attacker, defender, dst, { att_weapon = 1, def_weapon = 1 })
    print('Rating weapon #1:', r)
    local r = BC.attack_rating(attacker, defender, dst)
    print('Rating best weapon',r)

    wesnoth.message('Finish time:', wesnoth.get_time_stamp() / 1000. .. '  ' .. tostring(wesnoth.get_time_stamp() / 1000. - start_time))
end
