pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
c={0,1,2,8,14,15,7}
fillp(0xa5a5)
timer = 0
fouls = 0
attack = 0
reaction = 0
offset = 0
transition = 0

-- particles
function particleinit()
	-- called once to initialize the particle system
	particles = {}
end

function updateparticles()
 -- called once per frame
 for p in all(particles) do
 	if (p.life <= 0) then
 		-- dead
 		del(particles,p)
 	end
 	p.x += p.xvel
 	p.y += p.yvel
 	p.life -= 1
 end
end

function drawparticles()
	-- called once per frame
	for p in all(particles) do
		spr(p.sprite, p.x, p.y)
	end
end

function spawnparticle(p)
	--[[ particle format:
	{
		x, y, xvel, yvel, life, sprite
	}
	]]
	add(particles, p)
end

function _init()
 titleinit()
 particleinit()
 resettimer()
end

function titleinit()
 scene = 0
 sfx(-1)
 music(-1)
end

function gameinit()
 scene = 1
end

function titleupdate()
 if(btnp(5)) then
  gameinit()
  music(1, 0, 1)
 end
end

function endupdate()
 if btnp(4) then
  titleinit()
 end
end

function resettimer()
 timer = rnd(210) + 60
end

function transitionupdate()
 if btnp(4) then
  scene += 1
  resettimer()
  fouls = 0
  reaction = 0
  transition = 0
  
  if scene > 4 then
   scene = 99
   sfx(-1)
   music(-1)
   sfx(2, -1, 1)
  end
 end
end

function gameupdate()
 timer -= 1
 
 if timer <= 0 and timer >= -1 then
  sfx(6)
 end
 if timer < 0 then
  reaction += 1
 end
 
 -- if button pressed before flash and out of fouls
 if btnp(5) and timer > 0 then
  fouls += 1
  -- todo display foul occured reset stage
 end

 -- button pressed after flash
 if btnp(5) and timer <= 0 then
  sfx(0)
  sfx(1)
  offset=1.5
  transition = 1
 end
 
 -- player too slow
 if timer < (-30 * (1/scene)) then
  scene = 100
  sfx(-1)
  music(-1)
  sfx(3, -1, 1)
  resettimer()
  fouls = 0
 end

 if fouls > 2 then
  sfx(-1)
  music(01)
  sfx(3,-1, 1)
  scene = 100
  resettimer()
  fouls = 0
 end

 -- cheating :)
 if btnp(4) then
 	scene += 1
 end
 
 if scene == 4 then
 	-- skull
 	-- left eye
		spawnparticle({ 
			x=84+rnd(2)+4*sin(timer/24),
			y=48, xvel=0, yvel=-1, 
			life=16+rnd(10), sprite=48+rnd(4)
		})
		-- right eye
		spawnparticle({ 
			x=100+rnd(2)+4*sin(timer/24),
			y=48, xvel=0, yvel=-1, 
			life=16+rnd(10), sprite=48+rnd(4)
		}) 
 end
 
 -- particles
 updateparticles()
end

function f(i)
 return c[flr(1.5+abs(6-i%12))]
end

function tunnel()
 -- tunnel animation "borrowed" from luca harris
 -- from this tweet https://twitter.com/lucatron_/status/1096168653735657472
 for w=3,68,.1 do
  a=4/w+t()/4
  k=145/w
  x=64+cos(a)*k
  y=64+sin(a)*k
  i=35/w+2+t()*3
  rect(x-w,y-w,x+w,y+w,f(i)*16+f(i+.5))
 end
end

function titledraw()
 tunnel()
 print("press x after the flash", 17, 60, 12)
 print("press x to start game", 20, 70, 12)
end

function victorydraw()
 cls(10)
 print("you win! press c to continue", 5, 60, 0)
end

function defeatdraw()
 cls(8)
 print("you lose! press c to continue", 3, 60, 0)
end

function screen_shake()
 local fade = 0.70
 local offset_x=16-rnd(32)
 local offset_y=16-rnd(32)
 
 offset_x*=offset
 offset_y*=offset
 
 camera(offset_x,offset_y)

 offset*=fade
 if offset < 0.05 then
  offset=0
 end
end

function gamedraw()
 -- clear screen and draw player
 cls(1)
 
 -- final stage pallete
 if scene == 4 then
 	pal(7, 9)
 	pal(1, 2)
 	pal(13,8)
 else
 	pal()
 end
 
 map(0,0)
 pal()
 spr(16,10,58,2,2)

 -- draw reaction counter
 if timer < 0 then
  print(reaction, 62, 5, 0) 
 end
  
 -- draw fouls
 if scene >=1 and scene <= 4 then
  if fouls == 1 then
   spr(1, 8, 8)
  elseif fouls == 2 then
   spr(1, 8, 8)
   spr(1, 18, 8)
  end
 end

 -- figure out which enemy to draw
 if scene == 1 then
  spr(18,100,58,2,2)
 elseif scene == 2 then
  spr(20,100,58,2,2)
 elseif scene == 3 then
  spr(22,100,58+2*sin(timer/30),2,2)
 elseif scene == 4 then
  spr(8,80+4*sin(timer/24)+timer%2,40,4,4)
  end

	-- draw particles
	drawparticles()
	
	if offset == 0 and transition == 1then
  camera(0,0)
  print("press c to continue",25,35,0)
 end

 if timer <= 0 and timer >= -2 then
  cls(7)
 end
end

function _update()
 if scene == 0 then
  titleupdate()
 elseif scene == 99 or scene == 100 then
  endupdate()
 elseif transition == 1 then
  transitionupdate()
 else
  gameupdate()
 end
end

function _draw()
 screen_shake()
 if scene == 0 then
  titledraw()
 elseif scene == 99 then
  victorydraw()
 elseif scene == 100 then
  defeatdraw()
 else
  gamedraw()
 end
end
__gfx__
000000000000999900999990999000999990000000000990000000000000000000000000888888888888888800000000dddddddd111111111d1d1d1d77777777
000000008888888808800888088000880880000000008888000000000000000000000088888888888888888888000000dddddddd11111111d1d1d1d177777777
007007009900000099000099099000990990000000009999000000000000000000000888888888888888888888800000dddddddd111111111d1d1d1d77777777
000770008800000088000088088000880880000000088800000000000000000000008888888888888888888888880000dddddddd11111111d1d1d1d177777777
000770009999990099000099099000990990000000990000000000000000000000028888888888888888888888882000dddddddd111111111d1d1d1d77777777
007007000888880088000088088000880880008800800000000000000000000000288888888888888888888888888200dddddddd11111111d1d1d1d177777777
000000000880000099900990009909990999999990000000000000000000000002288888888888888888888888888220dddddddd111111111d1d1d1d77777777
000000000990000008888800000888800888888088000000000000000000000022288888228888888888882288888222dddddddd11111111d1d1d1d177777777
0eeeeeeeeeeeeee008a80000000088a09900000000000099000001111110000022288822222888888888822222888222dddddddddddddddddddddddddddddddd
2ee1111eeeee111121aa3000000381aa44900000000009440001cccccccc100022288222222288888888222222288222dddddddddddddddddddddddddddddddd
2eeeeeeeeeeeeeee2112bb3333bb8112444900000000944401cccccccccccc102228222222222888888222222222822266666666666666666666666666666666
2ee111eeeeee111e211bbbbbbbbbb112444a9a9a9a9a94440cc00cccccc00cc02228222222222888888222222222822255555555555555555555555555555555
2ee788eeeeee788e0bbbbbbbbbbbbbb004aa9a9a9a9a9940ccc00cccccc00ccc2228222222222888888222222222822251115551115551115551115551115555
2ee781eee88e781e0bbffffffffffbb004aa416aa416aa40ccc00cccccc00ccc2228222222222888888222222222822251115551115551115551115551115555
2ee788ee8888788e00ffffffffffff0004aa414aa414aa40ccc00cc00cc00ccc2228822222228888888822222228822255551115551115551115551115551115
2ee11eee888811ee000ffffffffff000004aa14aa41aa400ccc00cc00cc00ccc2228882222888882288888222288822255551115551115551115551115551115
2eeeeeeeeeeeeeee000399999999300000a4aaaeeaaa4a00ccc0cc0000cc0ccc2228888888888822228888888888822251111111111111111111111111111115
2eeeeeeeeeeeeeee000b99999999b000444aaaa4aaaaa444ccccc000000ccccc2228888888888822228888888888822251111111111111111111111111111115
2eeeeee2222eeeee033bffffffffb3300094aaa4aaaa4900cccc00000000cccc0228888888888222222888888888822051111111115115111111111111111115
22eeeeeeeeeeeeee33bbffffffffbb330044999449994400ccc000cccc000ccc0228888888888222222888888888822051111111111551111111111111111115
022222222222222033888ffffff888330444999449994440c0000cccccc0000c0228888888882222222288888888822051111111111551111111111111111115
00200000000000202888888ff88888824994aaa44aaa4994cccccccccccccccc0228888888882222222288888888822051111111115115111111111111111115
02000000000002002288288338828822999aaaa44aaaa9991110ccc001110ccc0228888888888228822888888888822051111111111111111111111111111115
02200000000002200022022332202200999aaaa44aaaa99911000c00001000cc0022222888888888888888888222220051111111111111111111111111111115
000000000000000000000000000000007777777777777777777777777777777700000002888888888888888820000000dddddddd7777777777dddddddddddd77
0000a0000000000000000000000000007777777777777777777777777777777700000000888888888888888800000000dddddddd77777777777dddddddddd777
000990000099990000900900000000006666666666666666666666666666666600000000888888888888888800000000ddddddddd777777d7777dddddddd7777
00aa9a9009aa9a90000a9000000090005555555555555555555555555555555500000000888888888888888800000000dddddddddd7777dd7777dddddddd7777
09aaaa0009aaaa900009a000000a00005111555111555111555111555111555500000000828828882882882800000000dd7777dddddddddd7777dddddddd7777
0009900000a9990000a00900000000005111555111555111555111555111555500000000828828822882882800000000d777777ddddddddd7777dddddddd7777
00090000000000000000000000000000555511155511155511155511155511150000000022882882288288220000000077777777dddddddd777dddddddddd777
00000000000000000000000000000000555511155511155511155511155511150000000002222222222222200000000077777777dddddddd77dddddddddddd77
__map__
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c3f0f0f3e0c0c0c0c0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c0c0c0c0c0c0c3f0f0f3e0c0c0c0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f3c0c0c0c0c0c0c3d0c0c0c0c0c3c3c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f3c3c3c0c0c0c0c0c0c0c3c3c0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f3e0c0c0c0c0c3f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f343536351e1d1e1d1e1d1e3536370f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f2c2e2e2e2e2e2e2e2e2e2e2e2e2f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f2c2d2e2e2e2e2e2d2e2e2e2e2e2f3d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f2c2e2e2e2e2e2e2e2e2e2e2e2d2f0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3d2c2e2e2d2e2e2e2e2e2e2e2e2e2f0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c2c2e2e2e2e2d2e2e2d2e2e2e2e2f0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c2c2e2e2e2e2e2e2e2e2e2e2d2e2f0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010200000a6101d6102d610346103b6103f6103a610356102d61026610216101e6101a6101761013610116100f6100d6100b61009610076100561004610036100161001610000000000000000000000000000000
00060000123740c3740737401374013040b3040630405304053040130400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e000010150101500a1500f1500f1500c1500c1500f150111501315011150131501615013150181501b15024155241552a1002b7002a700287001a70016700167001970020700287002f70034700387003e700
00200000157501575018750147501375011750127501075010750127500f75002750027500270002700017000170001700257002a7002e7003070031700327003370033700337003270032700317002f70000700
012000000961407611066110661107611096110a6110b6110a6110961108611096110a6110c6110c6110c6110b6110961108611096110b6110d6110d6110c6110a6110a6110a6110b6110e6110f6110d61109611
012000000a61407611096110b6110a611086110a6110d6110d6110c6110d61111611156111a611246112a6112f611306112f6112e6112b61127611216111c61118611136110e6110b6110a6110c6110b6110a611
0001000028750347002a0002b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 40414344
01 04424344
02 05424345
04 01004344

