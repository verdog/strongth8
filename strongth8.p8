pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
c={0,1,2,8,14,15,7}
fillp(0xa5a5)
timer = 0
fouls = 0

function _init()
 titleinit()
 resettimer()
end

function titleinit()
 scene = 0
end

function gameinit()
 scene = 1
end

function titleupdate()
 if(btnp(5)) then
  gameinit()
 end
end

function endupdate()
 if btnp(5) then
  scene = 0
 end
end

function resettimer()
 timer = rnd(210) + 30
end

function gameupdate()
 timer -= 1

 -- if button pressed before flash and out of fouls
 if btnp(5) and timer > 0 then
  fouls += 1
  -- todo display foul occured reset stage
 end

 -- button pressed after flash
 if btnp(5) and timer <= 0 then
  scene += 1
  resettimer()
  fouls = 0
  if scene > 4 then
   scene = 99
  end
 end
 -- player too slow
 if timer < -15 then
  scene = 100
  resettimer()
  fouls = 0
 end

 if fouls > 2 then
  scene = 100
  resettimer()
  fouls = 0
 end
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
 print("you win! press x to continue", 5, 60, 0)
end

function defeatdraw()
 cls(8)
 print("you lose! press x to continue", 3, 60, 0)
end

function gamedraw()
 -- clear screen and draw player
 cls(1)
 spr(16,10,58,2,2)

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
  spr(22,100,58,2,2)
 elseif scene == 4 then
  spr(8,80,40,4,4)
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
 else
  gameupdate()
 end
end

function _draw()
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
00000000000099990099999099900099999000000000099000000000000000000000000088888888888888880000000000000000000000000000000000000000
00000000888888880880088808800088088000000000888800000000000000000000008888888888888888888800000000000000000000000000000000000000
00700700990000009900009909900099099000000000999900000000000000000000088888888888888888888880000000000000000000000000000000000000
00077000880000008800008808800088088000000008880000000000000000000000888888888888888888888888000000000000000000000000000000000000
00077000999999009900009909900099099000000099000000000000000000000002888888888888888888888888200000000000000000000000000000000000
00700700088888008800008808800088088000880080000000000000000000000028888888888888888888888888820000000000000000000000000000000000
00000000088000009990099000990999099999999000000000000000000000000228888888888888888888888888822000000000000000000000000000000000
00000000099000000888880000088880088888808800000000000000000000002228888822888888888888228888822200000000000000000000000000000000
0eeeeeeeeeeeeee008a80000000088a0990000000000009900000111111000002228882222288888888882222288822200000000000000000000000000000000
2ee1111eeeee111121aa3000000381aa44900000000009440001cccccccc10002228822222228888888822222228822200000000000000000000000000000000
2eeeeeeeeeeeeeee2112bb3333bb8112444900000000944401cccccccccccc102228222222222888888222222222822200000000000000000000000000000000
2ee111eeeeee111e211bbbbbbbbbb112444a9a9a9a9a94440cc00cccccc00cc02228222222222888888222222222822200000000000000000000000000000000
2ee788eeeeee788e0bbbbbbbbbbbbbb004aa9a9a9a9a99401cc00cccccc00ccc2228222222222888888222222222822200000000000000000000000000000000
2ee781eee88e781e0bbffffffffffbb004aa416aa416aa401ccaaccccccaaccc2228222222222888888222222222822200000000000000000000000000000000
2ee788ee8888788e00ffffffffffff0004aa414aa414aa401cc9acc00cc9accc2228822222228888888822222228822200000000000000000000000000000000
2ee11eee888811ee000ffffffffff000004aa14aa41aa4001cc00cc00cc00ccc2228882222888882288888222288822200000000000000000000000000000000
2eeeeeeeeeeeeeee000399999999300000a4aaaeeaaa4a001cc0cc0000cc0ccc2228888888888822228888888888822200000000000000000000000000000000
2eeeeeeeeeeeeeee000b99999999b000444aaaa4aaaaa4441cccc000000ccccc2228888888888822228888888888822200000000000000000000000000000000
2eeeeee2222eeeee033bffffffffb3300094aaa4aaaa49001ccc00000000cccc0228888888888222222888888888822000000000000000000000000000000000
22eeeeeeeeeeeeee33bbffffffffbb3300449994499944001cc000cccc000ccc0228888888888222222888888888822000000000000000000000000000000000
022222222222222033888ffffff88833044499944999444010000cccccc0000c0228888888882222222288888888822000000000000000000000000000000000
00200000000000202888888ff88888824994aaa44aaa49941ccccccccccccccc0228888888882222222288888888822000000000000000000000000000000000
02000000000002002288288338828822999aaaa44aaaa9991110ccc001110ccc0228888888888228822888888888822000000000000000000000000000000000
02200000000002200022022332202200999aaaa44aaaa99911000c00001000cc0022222888888888888888888222220000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000288888888888888882000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000088888888888888880000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000088888888888888880000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000088888888888888880000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000082882882288288280000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000082882882288288280000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000022882882288288220000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000002222222222222200000000000000000000000000000000000000000
