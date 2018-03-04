pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- main functions (pico-8 stuff)
function _init()
	g_tl = tl_init( {
		{ tit_update, tit_draw, nil },
		{ bat_update, bat_draw, nil, bat_init },
	} )
end

function _update60()
	tl_update(g_tl)
end

function _draw()
	tl_draw(g_tl)
end

-- battle functions
function bat_init()
	music(0)

end

function bat_update()
end

function bat_draw()
	cls()
	print("battling", 9, 9, 7)
end

-- title functions
function tit_update()
	if btn(4) or btn(5) then
		tl_next(g_tl)
	end
end

function tit_draw()
	cls()
	print("hello techmon", 0, 0, 8)
end

-- other stuff
function draw_box(move_arr, move)
	
end





-- alan's library thing
-- 150 tokens.

-- tl array fields:
--    update: callback for every frame.
--    draw:   callback for every frame.
--    timer:  t > 0: measured in seconds. t == 0: done. t == nil: disabled. t < 0: next frame will be finished
--    init:   optional reset callback. called right before the first update.

-- pass the array into this function.
function tl_init(tl_master)
	assert(#tl_master > 0)

	local tl = {
		master=tl_master,
		current=1,
		next=(1 % #tl_master)+1,
		time = tl_master[1][3]
	}

	-- init function
	tl_func(tl, 4)

	return tl
end

-- call a function if not nil
function tl_func(tl, num)
	if tl.master[tl.current][num] then
		tl.master[tl.current][num]()
	end
end

-- optional number of which state should be loaded next.
function tl_next(tl, num)
	tl.time=0
	if num then tl.next=num end
end

function tl_update(tl)
	-- switch the state
	if tl.time == 0 then
		tl.current = tl.next
		tl.next = (tl.current % #tl.master) + 1
		tl.time = tl.master[tl.current][3]
		tl_func(tl, 4) -- init func
	end

	tl_func(tl, 1) -- update func

	-- inc timer if enabled
	if tl.time then
		tl.time = max(0, tl.time - 1/60)
	end
end

function tl_draw(tl)
	tl_func(tl,2) -- draw func
end

__sfx__
011e000021250152552125521250212552125521255212551c250102551c2551c2501c2551c2551c2551c2551d250112551d2551d2501d2551d2551d2551d255172500b255172551725017255172551725517255
011e00002d2502f2502d25000500185021500015000000002d2402f25034250000000000000000000000000034250352502f2501d0001c0001d0001f0001f0003025034250382503a0003a000000000000000000
011e00001536000000091630000015460000002166500000103600000010163000001046000000106650000011360000001116300000114600000011665000000b360000000b163000000b460000000b66500000
__music__
00 00414344
01 00024344
00 00020144
02 00020144
02 40424344

