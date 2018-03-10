pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- main functions (pico-8 stuff)
function _init()
	g_tl = tl_init( {
		{ log_update, log_draw, 1.5, log_init },
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

-- logo functions
function log_init()
	sfx(10)
	log_letters = {}

	-- initial pos
	for i=0,12 do
		add(log_letters, {
			ix=100*cos(i*27 / 360)+56,
			iy=100*sin(i*27 / 360)+56,
		})
	end

	for i=1,13 do
		log_letters[i].x = log_letters[i].ix
		log_letters[i].y = log_letters[i].iy
	end

	-- end pos
	local start_x = 88
	for i=1,8 do
		log_letters[i].sp = 8 - i
		log_letters[i].fx = start_x
		log_letters[i].fy = 54
		start_x -= 8
	end

	start_x = 44
	for i=9,13 do
		log_letters[i].sp = i+7
		log_letters[i].fx = start_x
		log_letters[i].fy = 66
		start_x += 8
	end

	-- time
	log_time = 0
end

function log_update()
	if log_time >= 61 then
		sfx(10, -2)
		return
	end

	for i=1,13 do
		local ll = log_letters[i]
		local exp = (log_time / 15) * (log_time / 15)
		ll.x = ll.ix + (ll.fx - ll.ix) * exp / 16
		ll.y = ll.iy + (ll.fy - ll.iy) * exp / 16
	end

	log_time += 1
end

function log_draw()
	cls()
	for i=1,13 do
		local ll = log_letters[i]
		spr(ll.sp, ll.x, ll.y)
	end
	--spr(0,  32, 54, 8, 1)
	--spr(16, 44, 66, 5, 1)
end

-- battle functions
function bat_init()
	music(0)
	zuzu = make_pcmn("zuzu", 5)
end

function bat_update()
	if btnp(0) then
		if g_select % 2 == 0 then
			g_select -= 1
		end
	end

	if btnp(1) then
		if g_select % 2 == 1 then
			g_select += 1
		end
	end

	if btnp(2) then
		if g_select > 2 then
			g_select -= 2
		end
	end

	if btnp(3) then
		if g_select < 3 then
			g_select += 2
		end
	end
end

g_select = 1

function bat_draw()
	cls(14)
	print("battling", 9, 9, 7)
	draw_box_bkgd(zuzu.moves)
	draw_selector_arrow(g_select)
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

function draw_selector_box(select)
	local box_w = 50
	local box_h = 8
	if select == 1 then
		rect(10, 103, 10 + box_w, 103 + box_h, 0)
	elseif select == 2 then
		rect(67, 103, 67 + box_w, 103 + box_h, 0)
	elseif select == 3 then
		rect(10, 112, 10 + box_w, 112 + box_h, 0)
	elseif select == 4 then
		rect(67, 112, 67 + box_w, 112 + box_h, 0)
	end
end

function draw_selector_arrow(select)
	if select == 1 then
		spr(32, 5, 103)
	elseif select == 2 then
		spr(32, 62, 103)
	elseif select == 3 then
		spr(32, 5, 112)
	elseif select == 4 then
		spr(32, 62, 112)
	end
end

-- other stuff, takes in an array of strings.
-- max length of each string is 12 characters.
function draw_box_bkgd(text_arr)
	palt(14, true)
	palt(0, false)

	line(2, 97,  125, 97,  0)
	line(2, 126, 125, 126, 0)

	line(1,   103,  1,  120,  0)
	line(126, 103, 126, 120, 0)

	rect(2, 98, 125, 125, 12)
	rectfill(4, 100, 123, 123, 7)
	rect(4, 100, 123, 123, 6)
	rect(3, 99, 124, 124, 0)

	spr(21, 0, 128 - 4*8)
	spr(21, 0, 128 - 1*8, 1, 1, false, true)
	spr(21, 128-8, 128 - 4*8, 1, 1, true, false)
	spr(21, 128-8, 128 - 1*8, 1, 1, true, true)

	print(text_arr[1], 12, 105, 0)
	print(text_arr[2], 69, 105, 0)
	print(text_arr[3], 12, 114, 0)
	print(text_arr[4], 69, 114, 0)
end


-- for now, just give the pcmn some basic stats.
function make_pcmn(name, lvl)
	local pcmn = {}

	pcmn.lvl = lvl
	if name == "zuzu" then
		-- max is 12 characters for a move
		pcmn.moves = {
			"tackle",
			"absorb",
			"harden",
			"tail wag",
		}
	end

	pcmn.hp = lvl * 5
	pcmn.att = lvl
	pcmn.def = lvl
	pcmn.spd = lvl
	pcmn.eva = lvl -- evasiveness
	pcmn.sp_att = lvl
	pcmn.sp_def = lvl

	pcmn.typ1 = "vanilla"
	pcmn.typ2 = nil -- to be implemented

	return pcmn
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

__gfx__
03333330088888800dddddd004444440088888800330000008888880033303307777777777777777777777777777777777777777777777777777777777777777
03300000088008800dddddd004400440088008800330000008800880033300307777777777777777777777777777777777777777777777777777777777777777
03000000080000800d0dd0d004000000080000800300000008000080030300307777777777777777711117777777777777777777777777777777777777777777
03000000080000800d0dd0d004440000080000800300000008000080030330307777777777777777111117777777777777777777777777777777777777777777
03000000088888800d0dd0d004444000088888800300000008888880030330307777777777777771111117777777777777777777777777777777777777777777
03000000088008800d0000d004000000088008800300000008800880030330307777777777777711111117777777777777777777777777777777777777777777
03300000080000800d0000d004400440080000800300033008000080030033307777777777771111111177777777777777777777777777777777777777777777
03333330080000800d0000d004444440080000800333333008000080033033307777777777711111111177777777777777777777777777777777777777777777
03333330088888800dddddd00cccccc003333330eee000ee70000770007777777777777777111111111177777777777777777777777777777777777777777777
03300330088008800dddddd00cc00cc003300030ee01110007770000770777777777777771111111111177777000077777777777777777777777777777777777
03000000080000800d0dd0d00c00000003000000e011dd0c07777007770777777777777771111111111177770fff077777777777777777777777777777777777
03000000080000800d0dd0d00ccc000003333330e01dd0c000077770000777777777777771111111111177700fff077777777777777777777777777777777777
03000000088888800d0dd0d00cccc00003333330e01d0c067070707077777777777777777111111111117770ffff077777777777777777777777777777777777
03003330088008800d0000d00c00000000000030ee00c0670777777707777777700007777111111111111700ffff077777777777777777777777777777777777
03300330080000800d0000d00cc00cc003000330ee0c0677077777770777777770ff0007711111111111170ffff0077777777777777777777777777777777777
03333330080000800d0000d00cccccc003333330e0c06777070070770777777770ffff0070fffffff111170fff00777777777777777777777777777777777777
000000000000000000000000000000000000000000000000707000707777777770fffff00fffffffffff000ff007777777777777777777777777777777777777
000000000000000000000000000000000000000000000000770777707777777770ffff00ffffffffffffff000077777777777777777777777777777777777777
0000000000000000000000000000000000000000000000007700000000777777770fff0fffffffffffffffff0777777777777777777777777777777777777777
00000000000000000000000000000000000000000000000077007777700007777770000fffffffffffffffff0077777777777777777777777777777777777777
0000000000000000000000000000000000000000000000007707777777770777777770ffff00fffffff00ffff077777777777777777777777777777777777777
0000000000000000000000000000000000000000000000007707000000000077777770ffff00fffffff00ffff007777777777777777777777777777777777777
0000000000000000000000000000000000000000000000007700007777707007777770ffffffffffffffffffff07777777777777777777777777777777777777
0000000000000000000000000000000000000000000000007707707777707707777070ffffffffffffffffffff00007777777777777777777777777777777777
000000000000000000000000000000000000000000000000000000000000000077770000ffffffffffffffff0007777777777777777777777777777777777777
0000000000000000000000000000000000000000000000000000000000000000777770ff00ffff000fffff00ff07777777777777777777777777777777777777
0000000000000000000000000000000000000000000000000000000000000000777770ffffffff000ffffffff077777777777777777777777777777777777777
0000000000000000000000000000000000000000000000000000000000000000777770fffffffff0fffffffff000000000000000000007777777777777777777
00000000000000000000000000000000000000000000000000000000000000007777700f00f0fff0fff0ff0000ffffffffffffffffff00000777777777777777
000000000000000000000000000000000000000000000000000000000000000077770000ffff00f0f00fffff00fffffffffffffffffffffff000777777777777
0000000000000000000000000000000000000000000000000000000000000000770000f0ffffff000ffffff0ff000ffffffffffffffffffffff0007777777777
00000000000000000000000000000000000000000000000000000000000000007700fff0ffffffffffffff00ffffffffffffffffffffffffffffff0777777777
0000000000000000000000000000000000000000000000000000000000000000770fffff0ffffffffffff00ffffffffffffffffffffffffffffffff007777777
0000000000000000000000000000000000000000000000000000000000000000770fffff000ffffffffff0ffffffffffffffffffffffffffffffffff00777777
0000000000000000000000000000000000000000000000000000000000000000770fffffff0fffffffff0ffffffffffffffffffffffffffffffffffff0777777
0000000000000000000000000000000000000000000000000000000000000000770fffffff00fffffff00fffffffffffffffffffffffffffffffffffff077777
0000000000000000000000000000000000000000000000000000000000000000700fffffffff000ff00ffffffffffffffffffffffffffffffffffffffff07777
000000000000000000000000000000000000000000000000000000000000000070ffffffffffff0000ffffffffffffffffffffffffffffffffffffffffff0777
000000000000000000000000000000000000000000000000000000000000000070ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0077
000000000000000000000000000000000000000000000000000000000000000070ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0077
0000000000000000000000000000000000000000000000000000000000000000700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff077
0000000000000000000000000000000000000000000000000000000000000000770ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff077
0000000000000000000000000000000000000000000000000000000000000000770fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff07
0000000000000000000000000000000000000000000000000000000000000000770fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff07
0000000000000000000000000000000000000000000000000000000000000000770fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff07
00000000000000000000000000000000000000000000000000000000000000007700ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff07
00000000000000000000000000000000000000000000000000000000000000007770ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff07
00000000000000000000000000000000000000000000000000000000000000007770ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff07
000000000000000000000000000000000000000000000000000000000000000077700fffffffffffffffffffffffffffffffffffffffffffffffffffffffff07
000000000000000000000000000000000000000000000000000000000000000077770fffffffffffffffffffffffffffffffffffffffffffffffffffffffff07
000000000000000000000000000000000000000000000000000000000000000077770fffffffffffffffffffffffffffffffffffffffffffffffffffffffff07
000000000000000000000000000000000000000000000000000000000000000077770fffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
000000000000000000000000000000000000000000000000000000000000000077770fffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
000000000000000000000000000000000000000000000000000000000000000077770fffffffffffffffffffffffffffffffffffffffffffffffffff00000077
000000000000000000000000000000000000000000000000000000000000000077770fffffffffffffffffffffffffffffffffffffffffffffff00000ffff077
0000000000000000000000000000000000000000000000000000000000000000777700000000000000000ffffffffffffffffffffffffff00000070ffffff077
000000000000000000000000000000000000000000000000000000000000000077777770fffffff07707000000fffffffffffff000000000ffff070ffffff077
000000000000000000000000000000000000000000000000000000000000000077777770fffffff07700fffff0000fffff00000077770fffffff0700fffff077
000000000000000000000000000000000000000000000000000000000000000077777700fffffff07770fffff077000000077777777700ffffff0770fffff077
00000000000000000000000000000000000000000000000000000000000000007777770ffffffff07770fffff077777007777777777770fffff00770fffff077
000000000000000000000000000000000000000000000000000000000000000077777700ffffff077770ffff0077777777777777777770fffff07770fffff077
000000000000000000000000000000000000000000000000000000000000000077777770ffffff077770ffff0777777777777777777770fffff077700fff0777
000000000000000000000000000000000000000000000000000000000000000077777770fffff00777700fff0777777777777777777770ffff0777770fff0777
000000000000000000000000000000000000000000000000000000000000000077777770ff000077777700ff0777777777777777777770ffff0777770ff07777
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
__sfx__
011e000021250152552125521250212552125521255212551c250102551c2551c2501c2551c2551c2551c2551d250112551d2551d2501d2551d2551d2551d255172500b255172551725017255172551725517255
011e00002d2502f2502d25000500185021500015000000002d2402f25034250000000000000000000000000034250352502f2501d0001c0001d0001f0001f0003025034250382503a0003a000000000000000000
011e00001536000000091630000015460000002166500000103600000010163000001046000000106650000011360000001116300000114600000011665000000b360000000b163000000b460000000b66500000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000514150e034100401205015050190501d0502005026050290502b0502e050330503305033050330503305033050330503305033050330503305033050330503305033050330503305033040330303302033015
__music__
00 00414344
01 00024344
00 00020144
02 00020144
02 40424344

