pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico hell
-- by cpiod
-- this code is licensed gpl3 at https://github.com/pfgimenez/picohell

-- state:
-- 0: player turn
-- 1: player aim
-- 2: enemy turn
-- 100: title screen
-- 101: controls
-- 102: game over screen

-- flag: 0: non-walkable
-- 1: bullet-opaque

-- sfx: 0: pistol
-- 1: shotgun
-- 2: rifle
-- 3: explosion
-- 4: player hurt
-- 5: get ammo
-- 6: reload
-- 7: medkit used
-- 8: error
-- 9: level up

function _init()
 level=0
 color_mode=1
-- poke(0x5f2d, 1) -- mouse debug
 unset_unseen_color()
-- menuitem(2,"show controls",show_ctrl)
 o_pressed=nil
 visibility_radius=5
 -- light direction
	light_x,light_y=1,1
	-- player sprite direction
	facing=1
	maxhp=100
	maxarm=100
	warn_low=false
	mesgs={}
	cam_x=0
	cam_y=0
	cam_xc=0
	cam_yc=0
	cam_dx=0
	cam_dy=0
	title_cam_y=0
	state=100
	wait=0
 anim=false
 xp_goal={10,50,200,500}
 player={hp=maxhp,ent=9,deltatime=rnd(),wpn=make_weapon(3),arm=0,lvl=1,xp=0,def=0}
 ammo={12,0,0}
 max_ammo={200,50}
end

function restart()
 printh("reload!")
 reload()
 _init()
end

function show_ctrl()
 title_cam_y=128
 old_state=state
 state=101
end

-->8
-- draw

function _draw()
 if(state<100) _draw_game()
 if(state==100) _draw_title()
 if(state==102) _draw_gameover()
 if state==101 then
  title_cam_y+=1
  _draw_title()
  if title_cam_y>=128 then
   state=1
   show_ctrl()
  end
 end
end

pentacle={{"o",0,0,47},
{"o",0,0,39},
{"l",38,-8,-24,31},
{"l",-24,31,3,-39},
{"l",3,-39,20,32},
{"l",20,32,-34,-16},
{"l",-34,-16,38,-8},
{"o",38,-8,8},
{"o",3,-39,4},
{"o",-34,-16,6},
{"o",-24,31,4},
{"o",20,32,6},
{"l",35,-17,10,-11},
{"l",35,-17,26,-9},
{"o",35,-17,3},
{"o",110-64,55-64,1},
{"l",34,19,-36,16},
{"o",-36,16,3},
{"p",-36,16},
{"l",34,19,19,5},
{"o",34,19,5},
{"p",35,-17},
{"l",-39,-2,-47,-3},
{"l",-39,-2,-22,-5},
{"l",-39,-2,-14,6},
{"o",-39,-2,2},
{"o",-47,-3,2},
{"l",-25,-30,-30,-36},
{"o",-30,-36,3},
{"p",-30,-36},
{"l",-25,-30,-18,-14},
{"l",-25,-30,7,-4},
{"o",7,-4,2},
{"l",-15,-22,-12,-30},
{"o",-15,-22,3},
{"o",-12,-30,3},
{"l",12,45,10,38},
{"o",12,45,2},
{"l",10,38,1,17},
{"l",10,38,10,23},
{"o",1,17,2},
{"o",-27,-38,1},
{"l",12,-45,11,-37},
{"o",12,-45,2},
{"l",11,-37,5,-30},
{"l",11,-37,8,-17}
}

function draw_pentacle(c)
 for v in all(pentacle) do
--  local c=2
  if v[1]=="l" then
   local x,y=rotate(v[2],v[3])
   local x2,y2=rotate(v[4],v[5])
   if(v[6]!=nil) c=v[6]
   line(x,y,x2,y2,c)
  elseif v[1]=="o" then
   local x,y=rotate(v[2],v[3])
   circfill(x,y,v[4]*mul,0)
   circ(x,y,v[4]*mul,c)
  elseif v[1]=="p" then
   local x,y=rotate(v[2],v[3])
   pset(x,y)
  end
 end
end

function rotate(x,y)
 return mul*(x*cosa-y*sina)+x0,mul*(x*sina+y*cosa)+y0
end

function _draw_gameover()
 cls()
 anim=false
 print("oups...")
end

function _draw_title()
cls()
camera()
local a=t()/300
--local a=0
cosa,sina=cos(a),sin(a)
mul=min(t()/50+0.8,1.5)
x0=64
y0=64
draw_pentacle(9)
camera(0, title_cam_y)
--spr(64,40,45,7,4)
pal(8,2)
for i=0,1 do
 t1x=13+1-i
 ty=55+1-i
 -- p
 sspr(0,33,10,14,t1x,ty)
 -- i
 sspr(10,33,3,14,t1x+13,ty)
 -- c
 sspr(10,33,10,14,t1x+19,ty)
 -- o
 sspr(20,33,10,14,t1x+32,ty)
 -- h
 sspr(0,49,10,14,t1x+49,ty)
 -- e
 sspr(10,49,10,14,t1x+62,ty)
 -- l
 sspr(20,49,10,14,t1x+75,ty)
 -- l
 sspr(20,49,10,14,t1x+88,ty)
 pal(8,8)
end
print_center("a jupiter hell demake by cpiod",15*8+1,6,0)
local y,d=168,7
print_center("press 🅾️ to start",80,7,1)
print_center("controls",y-2*d,7,0)
print_center("press ⬅️⬆️⬇️➡️ to move",y,6,4)
print_center("press 🅾️ to shoot",y+2*d,6,1)
print_center("hold 🅾️ to aim",y+3*d,6,1)
print_center("press ❎ to reload",y+5*d,6,1)
print_center("hold ❎ to pick up",y+6*d,6,1)
print_center("kill all the demons!",y+9*d,8,0)
--print((stat(32)-64).." "..(stat(33)-64),0,0,11)
--pset(stat(32),stat(33),11)
end

function print_center(s,y,c,d)
-- d because there are "double" symbols (such as ❎)
local x=64-(#s+d)*2
rectfill(x-1,y-1,x+(#s+d)*4-1,y+5,0)
print(s,x,y,c)
end

-- x0,y0,mul,a0
pentacles_pos={{64,64,1.5,0}}
--{rnd()*128,rnd()*128,rnd(0.5)+0.5,rnd()}}

function _draw_game()
 printh("draw")
 cls()
 camera()
-- clip(0,8,128,112)
 for p in all(pentacles_pos) do
  local a=t()/300+p[4]
  cosa,sina=cos(a),sin(a)
  mul=p[3]
  x0=p[1]
  y0=p[2]
	 draw_pentacle(2)
	end

 camera(cam_x+cam_dx+player.ox-64,cam_y+cam_dy+player.oy-64) 
 -- unseen map
 set_unseen_color()
 local x,y=ceil((cam_x+cam_dx+player.ox-72)/8),ceil((cam_y+cam_dy+player.oy-72)/8)
 map(x,y,8*x,8*y,min(32-x,17),min(32-y,17))

 unset_unseen_color()
 
--  camera()
--    	 print(stat(0).."kb "..(stat(1)*100).."%",1,20,9)
-- camera(cam_x+cam_dx+player.ox-64,cam_y+cam_dy+player.oy-64) 

 
 for x=max(0,player.x-visibility_radius),min(player.x+visibility_radius,31) do
  for y=max(0,player.y-visibility_radius),min(player.y+visibility_radius,31) do
   if(dist(player.x,player.y,x,y)<=visibility_radius and is_seen({x=x,y=y})) map(x,y,8*x,8*y,1,1)
  end
 end

-- for d in all(soot) do
--  if(is_seen(d)) set_color(d) spr(d.sprnb,8*d.x,8*d.y-2)
-- end
 for d in all(decor) do
  if(is_seen(d)) set_color(d) spr(d.sprnb,8*d.x,8*d.y,1,1,d.mh,d.mv)
 end
 for e in all(entities) do --shadow
  if(is_seen(e)) set_color(e) spr(2,e.ox,e.oy,1,1,e.x<=player.x)
 end
 for e in all(floor_weapons) do
  if(is_seen(e)) set_color(e) spr(e.sprnb,8*e.x,8*e.y-2)
 end
 for e in all(entities) do
  if(is_seen(e)) set_color(e) spr(e.sprnb+get_sprite_delta(e),e.ox,e.oy-2,1,1,e.x<=player.x)
 end
 for b in all(barrels) do
  if(is_seen(b)) set_color(b) spr(b.sprnb,8*b.x,8*b.y-2)
 end
 
 unset_unseen_color()
 -- player
 d=get_sprite_delta(player)
 local s=32
 spr(s+d,player.ox,player.oy-2,1,1,facing>0)

 -- aim
 if state==1 then
  local s=17
  -- aim on player
  if(a_x==player.x and a_y==player.y) s=19
  -- no los
  if(not is_visible(a_x,a_y,true)) s=19
  spr(s,a_x*8,a_y*8-2)
 end
 
 animate()
-- clip()
 camera()

 -- health bar
-- rectfill(2,2,39,16,1)
-- rect(2,2,39,16,6)
 local c=player.hp>20 and 9 or 8
 print("♥"..lpad(tostr(player.hp),3).."/"..maxhp,3,4,c) 
 print("웃"..lpad(tostr(player.arm),3).."/"..maxarm,3,10,9)
-- rectfill(93,2,80+43,16,0)
-- rect(93,2,80+43,16,6)
 print("level "..player.lvl,95,4,9)
 print("depth "..level,95,10,9)
 local s=weapon_name[player.wpn.typ].." "
 ..player.wpn.amm
 .."/"..player.wpn.mag
 .." ("..ammo[player.wpn.ammtyp]..")"
 local x=64-#s*2
 local y=15*8+1
-- rectfill(x-2,y-2,x+#s*4,y+6,0)
-- rect(x-2,y-2,x+#s*4,y+6,6)
 print(s,x,y,9)
 print((stat(1)*100).."%",1,17,3)
 print(stat(7).."fps",1,23,3)
end

function lpad(s,l)
 if(#s<l) return lpad(" "..s,l)
 return s
end

function animate()
 anim=false
 cam_dx,cam_dy=0,0
 for bul in all(bullets) do
  anim=draw_bullets(bul) or anim
 end
 for e in all(explosion) do
  anim=explode(e) or anim
 end
 anim=animate_camera() or anim
 for e in all(entities) do
  anim=animate_ent(e) or anim
 end
 anim=animate_ent(player) or anim
 for tim in all(medkits_used) do
  animate_medkit(tim) -- non-blocking
 end
 for e in all(blood) do
  anim_blood(e) -- non-blocking
 end
 for e in all(mesgs) do
  print_float(e)
 end
 if(wait>0) wait-=1 anim=true
end

function animate_medkit(med)
 if t()-med.tim<=0.25 then
  r=300/4-(t()-med.tim)*300
  for i=r,r+med.lvl/25 do
   circ(player.ox+4,player.oy+2,i,med.col)
  end
  return true
 end
 del(medkit_used,med)
 return false
end

function animate_camera()
 if(cam_x<cam_xc) cam_x+=ceil((cam_xc-cam_x)/8)
 if(cam_x>cam_xc) cam_x-=ceil((cam_x-cam_xc)/8)
 if(cam_y<cam_yc) cam_y+=ceil((cam_yc-cam_y)/8)
 if(cam_y>cam_yc) cam_y-=ceil((cam_y-cam_yc)/8)
 if(cam_x!=cam_xc or cam_y!=cam_yc) printh("animate camera")
 return cam_x!=cam_xc or cam_y!=cam_yc
end

function animate_ent(e)
 local x=e.x*8
 local y=e.y*8
 local d=(e==player) and 2 or 1
 if e.ox!=x or e.oy!=y then
  if(x-1>e.ox) e.ox+=d
  if(x+1<e.ox) e.ox-=d
  if(y-1>e.oy) e.oy+=d
  if(y+1<e.oy) e.oy-=d
  if(abs(x-e.ox)==1) e.ox=x
  if(abs(y-e.oy)==1) e.oy=y
  printh("animate ent")
  return true
 end
 return false
end

function draw_bullets(bul)
 for b in all(bul[1]) do
  printh("animate bullets")
  if b.delay>0 then
   b.delay-=1
  else
   if b.bulspr then
    spr(b.bulspr,b.x0-4,b.y0-4,1,1,flr(shr(b.dur,1)%2)==0,flr(shr(b.dur,2)%2)==0)
   else
    pset(b.x0,b.y0,6)
   end
   b.x0+=b.vx
   b.y0+=b.vy
   b.dur-=1
   if(b.dur<=0) del(bul[1],b)
  end
 end
 if #bul[1]==0 then
  for param in all(bul[2]) do
   damage(param[1],param[2])
  end
  del(bullets,bul)
 end
 return #bullets>0
end

function get_sprite_delta(e)
 local d=0
 local t=t()--+e.deltatime
 if 8*e.x==e.ox and 8*e.y==e.oy then
  -- still
  if(t%(1.4)>0.7) d=1
 else
  -- moving
  d=2
  if(flr(t*10)%2==0) d=3
 end
 return d
end

function anim_blood(e)
 if e[5]<t() then
  del(blood,e)
  return false
 else
  e[4]+=0.1
  e[1]+=e[3]
  e[2]+=e[4]
  pset(e[1],e[2],2)
  return true
 end
end

function explode(ex)
 cam_dx=rnd(6)-3
 cam_dy=rnd(6)-3
 for e in all(ex[1]) do
  circfill(e.x,e.y,min(e.rad,100*(t()-e.t)),8)
  circfill(e.x,e.y,min(e.rad,100*(t()-e.t-0.1)),9)
  circfill(e.x,e.y,min(e.rad,100*(t()-e.t-0.3)),0)
  if 100*(t()-e.t-0.3)>e.rad then
   del(ex[1],e)
  end
 end
 if #ex[1]==0 then
  for param in all(ex[2]) do
   damage(param[1],param[2])
  end
  del(explosion,ex)
  return false
 end
 printh("animate explosion")
 return true
end

function set_unseen_color()
 if color_mode==0 then
	 for i=0,1 do
	  pal(i,0)
	 end
	 for i=2,15 do
	  pal(i,5)
	 end
	 color_mode=1
 end
end

function unset_unseen_color()
	if color_mode==1 then
	 pal()
	 palt(0, false)
	 palt(14, true)
	 color_mode=0
 end
end

function add_msg(msg,c,c2,x,y,v)
 if(c==nil) c=7
 if(x==nil) x=player.ox
 if(y==nil) y=player.oy
 if(v==nil) v=0.5
 if(c2==nil) c2=1
 add(mesgs,{msg,16,c,x,y,v,c2})
end

function print_float(msg)
 if msg[2]<=0 then
  del(mesgs,msg)
 else
  local x,y=msg[4],msg[5]
  msg[2]-=msg[6]
  for i=1,0,-1 do
   for j=1,0,-1 do
    local c=msg[7]
    if(i+j==0) c=msg[3]
    print(msg[1],x+4-#msg[1]*2+i,y-10+msg[2]/2+j,c)
   end
  end
 end
end

function set_color(e)
 if e.vis then
  unset_unseen_color()
 else
  set_unseen_color()
 end
end
-->8
-- entity

-- entity type:
-- 0: weapon
-- 1: enemy
-- 2: barrel
-- 3: decoration
-- 4: wall
-- 5: ammo
-- 6: medkit
-- 7: armor
-- 9: player

-- weapons type:
-- 0: pistol
-- 1: shotgun
-- 2: rifle

ammo_name={"bullets","shells"}
weapon_name={"pistol","combat shotgun","assault rifle"}
-- weapon struct:
-- x,y: position (if on floor)
-- amm: current ammo in magazine
-- mag: magazine size
-- ammtyp: ammo type
-- bul: bullet per shot
-- used: ammo per shot
-- rng: max range
-- dmg: damage
-- disp: dispersion
-- sprnb: sprite number
-- delay: delay between to bullets in the same attack
function make_weapon(typ)
	if(typ==1) return {typ=1,ammtyp=1,mag=6,amm=6,bul=1,rng=5,dmg=3,disp=1,ent=0,sprnb=71,used=1,maxrng=9,delay=0,drp=true}
	if(typ==2) return {typ=2,ammtyp=2,mag=1,amm=1,bul=5,rng=3,dmg=5,disp=5,ent=0,sprnb=72,used=1,maxrng=4,delay=0,drp=true}
	if(typ==3) return {typ=3,ammtyp=1,mag=24,amm=24,bul=4,rng=5,dmg=3,disp=2,ent=0,sprnb=73,used=4,maxrng=9,delay=3,drp=true}
	if(typ==4) return {typ=4,ammtyp=0,mag=100,amm=100,bul=1,rng=5,dmg=10,disp=1,ent=0,used=1,maxrng=9,delay=0,bulspr=10}
	assert(false,typ)
end

function make_floor_weapon(x,y,typ)
 w=make_weapon(typ-70)
 w.x=x
 w.y=y
 w.vis=is_visible(x,y)
 add(floor_weapons,w)
end

function make_floor_ammo(x,y,typ)
 typ-=73
 add(floor_weapons,make_ammo(x,y,typ))
end

function make_ammo(x,y,typ)
 if(typ==1) return {typ=1,ammo=12,sprnb=74,ent=5,x=x,y=y,vis=is_visible(x,y)}
 if(typ==2) return {typ=2,ammo=4,sprnb=75,ent=5,x=x,y=y,vis=is_visible(x,y)}
end

-- enemy struct:
-- sprnb: sprite number
-- x,y: pos
-- facing: sprite direction
-- ox,oy: temporary pos (for anim)
-- hp: health point
-- wpn: weapon struct
-- rng: preferred range
 
function make_enemy(x,y,typ)
 typ-=12
 typ/=16
 if(typ==0) add(entities,{facing=1,sprnb=12+16*typ,x=x,y=y,ox=8*x,oy=8*y,hp=10,wpn=make_weapon(1),ent=1,rng=3,deltatime=rnd(),xp=3})
 if(typ==1) add(entities,{facing=1,sprnb=12+16*typ,x=x,y=y,ox=8*x,oy=8*y,hp=10,wpn=make_weapon(2),ent=1,rng=3,deltatime=rnd(),xp=20})
 if(typ==2) add(entities,{facing=1,sprnb=12+16*typ,x=x,y=y,ox=8*x,oy=8*y,hp=10,wpn=make_weapon(4),ent=1,rng=3,deltatime=rnd(),xp=50})
end

-- barrel struct:
-- x,y: pos
-- dmg: damage
function make_barrel(x,y)
	add(barrels,{x=x,y=y,hp=1,dmg=50,ent=2,sprnb=8+flr(rnd(2))})
end

-- x,y: pos
-- hp: hp gain
function make_medkit(x,y,n)
 if(n==103) add(floor_weapons,{x=x,y=y,hp=50,sprnb=n,ent=6})
 if(n==104) add(floor_weapons,{x=x,y=y,hp=5,sprnb=n,ent=6})
end

-- x,y: pos
-- arm: arm gain
function make_armor(x,y,n)
 if(n==3) add(floor_weapons,{x=x,y=y,sprnb=n,ent=7,arm=50})
 if(n==4) add(floor_weapons,{x=x,y=y,sprnb=n,ent=7,arm=5})
end

function make_blood(x,y,n)
 add(decor,{x=x,y=y,sprnb=n,ent=3,mv=rnd()<0.5,mh=rnd()<0.5,vis=is_visible(x,y)})
end

-- decorative struct:
-- x,y: pos
-- sprnb: sprite number
function add_blood(x,y)
 local found=false
 for e in all(decor) do
  if(e.x==x and e.y==y) e.sprnb=min(90,e.sprnb+1) found=true break
 end
 if not found then
  make_blood(x,y,88)
 end
end

function add_soot(x,y)
 add(soot,{x=x,y=y,sprnb=24+flr(rnd(4)),ent=3})
end

function add_enemy(i,j,n)
 local typ
 if(n==12) typ=0
 if(n==28) typ=1
 if(n==44) typ=2
 add(entities,make_enemy(typ,i,j))
end
-->8
-- gameloop

dep={{-1,0},{1,0},nil,{0,-1},
nil,nil,nil,{0,1}}

function _update60()
 -- no update during animation
 --printh("anim="..tostr(anim))
 printh("new frame")
 
 if state==100 then
  if(btnp()!=0) state=101 return
 elseif state==101 then
  if btnp()!=0 then
   make_level()
   state=0
   return
  end
 elseif state==102 then
  if(btnp()!=0) restart() return
 end
 
 -- check movment (except during aim) 
 if(state!=1 and not depl) depl=dep[btnp()]
 if(anim) return
 
 -- player turn
 if state==0 then
  if not warn_low and player.hp<20 then
   add_msg("low hp!",8,9)
   warn_low=true
  end
  player_turn()
 -- player aim
 elseif state==1 then
  player_aim()
 -- enemy turn  
 elseif state==2 then
  enemy_turn()
 end
end


function player_move(d)
 local next_x=player.x+d[1]
 local next_y=player.y+d[2]
 update_facing(d[1],d[2])
 -- check collision
 if can_go(next_x,next_y) then
  -- update coordinates
  player.x=next_x
  player.y=next_y
  state=2 -- end of turn
  -- update camera
  cam_xc=d[1]*16
  cam_yc=d[2]*16
  -- pick up medkits
  use_medkit()
  -- pick up armor
  pickup_armor()
  -- pick up ammo
  pickup_ammo()
  update_seen()
  update_visibility()
  if mget(player.x,player.y)==5 then
   --stairs
   make_level()
   state=0
   return
  end
 else
  -- bump animation
  player.ox+=4*d[1]
  player.oy+=4*d[2]
 end
end

function pickup_armor()
 for e in all(floor_weapons) do
  if e.ent==7 and e.x==player.x and e.y==player.y and player.arm<maxarm then
   del(floor_weapons,e)
   add(medkits_used,{col=11,lvl=e.arm,tim=t()})
   sfx(5)
   local old=player.arm
   player.arm=min(maxarm,player.arm+e.arm)
   add_msg("+"..tostr(player.arm-old).." armor",11,3)
  end
 end
end

function pickup_ammo()
 local a=get_floor_weapon(player.x,player.y)
 if a and a.ent==5 and ammo[a.typ]<max_ammo[a.typ] then
  sfx(5)
  del(floor_weapons,a)
  local old=ammo[a.typ]
  ammo[a.typ]=min(max_ammo[a.typ],ammo[a.typ]+a.ammo)
  add_msg("+"..tostr(ammo[a.typ]-old).." "..ammo_name[a.typ])
 end
end

function use_medkit()
 for e in all(floor_weapons) do
  if e.ent==6 and e.x==player.x and e.y==player.y and player.hp<maxhp then
   del(floor_weapons,e)
   add(medkits_used,{col=12,lvl=e.hp,tim=t()})
   sfx(7)
   local old=player.hp
   player.hp=min(maxhp,player.hp+e.hp)
   add_msg("+"..tostr(player.hp-old).." hp",12,1)
   if(player.hp>=20) warn_low=false
  end
 end
end

function player_start_aim()
 if player.wpn.amm<player.wpn.used then
  -- no ammo !
  add_msg("reload!")
  sfx(8)
 else
  state=1 -- start aim
  local e=closest_enemy(player.x,player.y)
  if(e==nil or dist(player.x,player.y,e.x,e.y)>10) e=player
  a_x,a_y=e.x,e.y
  update_facing(a_x-player.x,a_y-player.y)
 end
end

function player_turn()
 local d=depl or dep[btnp()]
 depl=nil
 -- move
 if d!=nil then
  player_move(d)
 -- start aim
 elseif btnp(❎) then
  player_start_aim()
 elseif btnp(🅾️) and not o_pressed then
  o_pressed=t()
 elseif o_pressed and t()-o_pressed>0.4 then 
  local w=player.wpn
  local w2=get_floor_weapon(player.x,player.y)
  if w2==nil or w2.ent!=0 then
   add_msg("no weapon!")
  else
   w.x=player.x
   w.y=player.y
   add(floor_weapons,w)
   player.wpn=w2
   del(floor_weapons,w2)
   w3=get_floor_weapon(player.x,player.y)
   add_msg("got "..weapon_name[player.wpn.typ])
  end
	 o_pressed=nil
 elseif o_pressed and not btn(🅾️) then
  -- reload
  local w=player.wpn
  if w.mag!=w.amm and ammo[player.wpn.ammtyp]>0 then
   local amount=min(ammo[player.wpn.ammtyp],w.mag-w.amm)
   ammo[player.wpn.ammtyp]-=amount
   w.amm+=amount
   pickup_ammo()
   state=2 -- end of turn
   wait=15
   sfx(6)
  elseif w.mag==w.amm then
   add_msg("full!")
   sfx(8)
  else
    add_msg("no ammo!")
    sfx(8)
  end 
	 o_pressed=nil
 end
end

function player_aim()
 local d=dep[band(btnp(),15)]
 -- aim
 if d!=nil then
  a_x+=d[1]
  a_y+=d[2]
  -- orient lamp according to aim
  update_facing(a_x-player.x,a_y-player.y)
 end
 -- no more hold
 if not btn(❎) then
  -- no self-shot
  if a_x==player.x and a_y==player.y then
   add_msg("no target")
   sfx(8)
   state=0
  else
   -- successful shot
   local w=player.wpn
   w.amm-=w.used
   shoot(player.x,player.y,a_x,a_y,player.wpn)
   state=2 -- end of turn
   sfx(player.wpn.typ-1)
  end
 end
end

function enemy_turn()
-- printh("enemy turn")
 state=0-- end turn
 for e in all(entities) do
  local moved=false
  local d=dist(player.x,player.y,e.x,e.y)
  if not e.vis then
   -- do nothing if player not seen
   moved=true
  elseif d>e.rng then
   moved=enemy_move(e)
  end
  if not moved and d<=e.rng+3 then
   if e.wpn.amm>=e.wpn.used then
    e.wpn.amm-=e.wpn.used
   	shoot(e.x,e.y,player.x,player.y,e.wpn)   	sfx(e.wpn.typ-1)
   else
    -- reload (infinite ammo)
    e.wpn.amm=e.wpn.mag
   end
  end
 end
end

function enemy_move(e)
 local dx,dy
 if player.x>e.x then
  dx=1
 elseif player.x<e.x then
  dx=-1
 end
 if player.y>e.y then
  dy=1
 elseif player.y<e.y then
  dy=-1
 end
 local next_x,next_y=e.x,e.y
 if dx!=nil and abs(player.x-e.x)>=d/2 and can_go(e.x+dx,e.y) then
  next_x+=dx
 elseif dy!=nil and abs(player.y-e.y)>=d/2 and can_go(e.x,e.y+dy) then
  next_y+=dy
 end
 if can_go(next_x,next_y) then
  e.x=next_x
  e.y=next_y
  return true
 end
 return false
end

function euc_dist(x1,y1,x2,y2)
 printh("euc_dist")
 return sqrt((x2-x1)^2+(y2-y1)^2)
end

-- shoot from x1,y1 to x2,y2
function shoot(x1,y1,x2,y2,w)
 local d=euc_dist(x1,y1,x2,y2)
 cosa=(x2-x1)/d
 sina=(y2-y1)/d
 x2=flr(x1+cosa*w.maxrng+0.5)
 y2=flr(y1+sina*w.maxrng+0.5)
 for i=0,w.bul-1 do
  local dmg=w.dmg
  if(w.rng<d) dmg=ceil(dmg/3)
  local dx,dy=0,0
  if(rnd(w.disp*w.maxrng)>7) dx=1
  if(rnd()>0.5) dx*=-1
  if(rnd(w.disp*w.maxrng)>7) dy=1
  if(rnd()>0.5) dy*=-1
  x3=x2+dx
  y3=y2+dy
  local b={{},{}}
  e=los_line(x1,y1,x3,y3,chk_ent_and_wall,false)
  if e then
   x3=e.x
   y3=e.y
   add(b[2],{e,dmg})
  end
  local speed=5
  x3+=(rnd(6)-3)/8
  y3+=(rnd(6)-3)/8
  local d=sqrt((x3-x1)^2+(y3-y1)^2)
  local vx=speed*(x3-x1)/d
  local vy=speed*(y3-y1)/d
  add(b[1],{x0=8*x1+4,y0=8*y1+4,vx=vx,vy=vy,dur=d*8/speed,delay=w.delay*i,bulspr=w.bulspr})
  add(bullets,b)
 end
end

function damage(e,dmg)
 -- can't die (wall) or already dead
 if(not e.hp or e.hp<=0) return
 if(e==player) dmg=max(1,dmg-player.def)
 if e.ent==1 or e==player then
  add_msg("-"..tostr(dmg).." hp",9,1,e.ox,e.oy,1)
  add_blood(e.x,e.y)
 end
 if e.arm then -- armor
  local arm_dmg=min(e.arm,dmg)
  e.arm-=arm_dmg
  dmg-=arm_dmg
 end
 e.hp-=dmg
 -- may be saved by medkit or armor
 if e==player then
  if(dmg>20) cls(8) -- red flash when serious damage
  use_medkit()
  pickup_armor()
 end

 if e.hp<=0 then
  -- if dead, project blood
  if e==player or e.ent==1 then
   for i=1,5 do
    local v=0.5+rnd(0.5)
    local a=rnd(0.5)
    add(blood,{e.ox+4+rnd(2)-1,e.oy+rnd(2)-1,
    cos(a)*v,sin(a)*v,t()+0.3+rnd(0.1)})
   end
  end
  if e==player then
   state=102 --game over
--   wait=120
  elseif(e.ent==1) then
   add_xp(e.xp)
   del(entities,e)
   if e.wpn.drp then
    local x,y=get_empty_tile(e.x,e.y)
    e.wpn.x=x
    e.wpn.y=y
    e.wpn.vis=is_visible(x,y)
    add(floor_weapons,e.wpn)
    x,y=get_empty_tile(e.x,e.y)
    add(floor_weapons,make_ammo(x,y,e.wpn.ammtyp))
   end
  elseif e.ent==2 then -- barrel
   local ex={{},{}}
   add(explosion,ex)
   sfx(3)
   for i=1,8 do
    add(ex[1],{x=8*e.x+rnd(16)-8,y=8*e.y+rnd(16)-8,rad=5+rnd(20),t=t()+rnd(0.3)})
   end
   del(barrels,e)
   for i=-3,3 do
    for j=-3,3 do
     local dmg=flr(e.dmg/(abs(i)+abs(j)+1))
     local x3,y3=e.x+i,e.y+j
     if(in_map(x3,y3) and not chk_wall(x3,y3) and rnd()>0.4) add_soot(x3,y3)
     e2=chk_ent(x3,y3)
     if(e2) add(ex[2],{e2,dmg})--damage(e2,dmg)
    end
   end
  end
 end
end

function dist(x1,y1,x2,y2)
 return abs(x1-x2)+abs(y1-y2)
end

function can_go(next_x,next_y)
 return fget(mget(next_x,next_y))%2==0
      and not chk_ent(next_x,next_y)
end

function add_xp(xp)
 -- level max
 if(player.lvl==5) return
 player.xp+=xp
 if player.xp>=xp_goal[player.lvl] then
  sfx(9)
  player.def+=1
  player.lvl+=1
  maxhp+=20
  player.hp+=20
  if player.lvl<5 then
   add_msg("level up!",11,3,nil,nil,0.25)
  else
   add_msg("level max!",11,3,nil,nil,0.25)
  end   

 end
end

function closest_enemy(x,y)
 local e2=nil
 local m=0
 for e in all(entities) do
  if e.vis and is_seen(e,0) then
   local d=dist(player.x,player.y,e.x,e.y)
   if e2==nil or d<m then
    e2=e
    m=d
   end
  end
 end
 return e2
end

function update_facing(a,b)
 if(a!=0) facing=a
 if(a>abs(b)) light_x,light_y=1,0
 if(b>abs(a)) light_x,light_y=0,1
 if(a<-abs(b)) light_x,light_y=-1,0
 if(b<-abs(a)) light_x,light_y=0,-1
end

function get_floor_weapon(x,y)
 local out=nil
 for e in all(floor_weapons) do
  if e.x==x and e.y==y then
   assert(out==nil,"two objects on the same tile!") -- only one
   out=e
  end
 end
 return out
end

function get_empty_tile(x,y)
 for i=0,10 do
  for x2=-i+x,i+x do
   for y2=-i+y,i+y do
    if(not chk_wall(x2,y2) and not get_floor_weapon(x2,y2)) return x2,y2
   end
  end
 end
end

function init_seen()
 seen={}
 for x=0,31 do
  seen[x+1]={}
  for y=0,31 do
   seen[x+1][y+1]=false
  end
 end
end

function update_seen()
 local r=visibility_radius
 for x=max(0,player.x-r),min(31,player.x+r) do
  for y=max(0,player.y-r),min(31,player.y+r) do
   if dist(x,y,player.x,player.y)<=visibility_radius and not seen[x+1][y+1] then
    seen[x+1][y+1]=is_visible(x,y,false)
   end
  end
 end
end

function is_seen(e,m)
 return seen[e.x+1][e.y+1] and is_in_screen(e,m)
end

function is_in_screen(e,m)
 m=m or 8
 return 8*e.x>=cam_x+cam_dx+player.ox-64-m
 and 8*e.x<=cam_x+cam_dx+player.ox+64+m
 and 8*e.y>=cam_y+cam_dy+player.oy-64-m
 and 8*e.y<=cam_y+cam_dy+player.oy+64+m
end
-->8
-- line of sight

function update_visibility()
 printh("update_visibility")
 list={decor,floor_weapons,entities,barrels}
 for l in all(list) do
  for e in all(l) do
   if(is_in_screen(e)) e.vis=is_visible(e.x,e.y)
  end
 end
end

function in_map(x,y)
 return x>0 and y>0 and x<32 and y<32
end

-- check collision with entities
function chk_ent(x1,y1)
 if(x1==player.x and y1==player.y) return player
 for e in all(entities) do
  if(e.x==x1 and e.y==y1) return e
 end
 for e in all(barrels) do
  if(e.x==x1 and e.y==y1) return e
 end
end

function chk_ent_and_wall(x,y)
 local e=chk_ent(x,y)
 if(e) return e
 if(chk_wall(x,y)) return {ent=4,x=x,y=y}
end

function chk_wall(x,y)
 return band(fget(mget(x,y)),1)!=0
end

function chk_opaque(x,y)
 return band(fget(mget(x,y)),2)!=0
end

function is_visible(x2,y2,chk_last)
 printh("is_visible "..t())
 return not los_line(x2,y2,player.x,player.y,chk_opaque,chk_last)
end

function los_line(x1, y1, x2, y2, chk, chk_first)
 delta_x = x2 - x1
 ix = delta_x > 0 and 1 or -1
 delta_x = 2 * abs(delta_x)

 delta_y = y2 - y1
 iy = delta_y > 0 and 1 or -1
 delta_y = 2 * abs(delta_y)
 
 local b=chk(x1,y1)
 if(chk_first and b) return b
-- fun(x1, y1)
 
 if delta_x >= delta_y then
  error = delta_y - delta_x / 2
 
  while x1 != x2 do
   if (error > 0) or ((error == 0) and (ix > 0)) then
    error = error - delta_x
    y1 = y1 + iy
   end
 
   error = error + delta_y
   x1 = x1 + ix

   local b=chk(x1,y1)
   if(b) return b
--   fun(x1, y1)
  end
 else
  error = delta_x - delta_y / 2
 
  while y1 != y2 do
   if (error > 0) or ((error == 0) and (iy > 0)) then
    error = error - delta_y
    x1 = x1 + ix
   end
 
   error = error + delta_x
   y1 = y1 + iy
   local b=chk(x1,y1)
   if(b) return b
--   fun(x1, y1)
  end
 end
end


-->8
-- level

function make_level()
 level+=1
 bullets={}
 floor_weapons={}
 decor={}
 soot={}
 explosion={}
 blood={}
 medkits_used={}
 entities={}
 barrels={}
 init_seen()
 
 local l={[12]=make_enemy,
 [28]=make_enemy,
 [44]=make_enemy,
 [8]=make_barrel,
 [103]=make_medkit,
 [104]=make_medkit,
 [3]=make_armor,
 [4]=make_armor,
 [71]=make_floor_weapon,
 [72]=make_floor_weapon,
 [73]=make_floor_weapon,
 [74]=make_floor_ammo,
 [75]=make_floor_ammo,
 [88]=make_blood,
 [89]=make_blood,
 [90]=make_blood}
 -- todo: adapt to difficulty
 for i=0,3 do
  for j=0,3 do
   x0=4+flr(rnd(2))
   y0=flr(rnd(2))
   for x=0,7 do
    for y=0,7 do
     mset(8*i+x,8*j+y,mget(8*x0+x,8*y0+y))
    end
   end
  end
 end

 for i=0,31 do
  for j=0,3 do
   if(j==0) mset(i,0,1)
   if(j==1) mset(i,31,1)
   if(j==2) mset(0,i,1)
   if(j==3) mset(31,i,1)
  end
	end
		
	local x,y=get_empty_place()
	if(level<9)	mset(x,y,5) -- last level
	 
 local x,y=get_empty_place()
 player.x=x
 player.y=y
 player.ox=8*x
 player.oy=8*y
	mset(player.x,player.y,6)

 
 local s,d
 for i=0,31 do
  for j=0,31 do
   local n=mget(i,j)
   local f=l[n]
   if f then
    f(i,j,n)
    mset(i,j,0)
   end
   
   -- add floor pattern
   if mget(i,j)==0 then
    d=0
    if j%2==1 then
     s=36
    else
     s=52
    end
    d+=i-1-2*flr((j-1)/2)
    d%=8
    mset(i,j,s+d)
   end
  end
 end
 
 update_seen()
 update_visibility()
end

function get_empty_place()
 while true do
  x=flr(rnd(31))
  y=flr(rnd(31))
  if(mget(x,y)==0) return x,y
 end
end
__gfx__
0000000077777721eeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000ee888eeeee999eeeeeeeeeee00000000ee5555eeeeeeeeeeee5555eeee5555ee
00000000776666d2eeeeeeee333ee333eeeeeeee03000000000000d000000000e82228eee90009eeeee88eee00000000ee8585eeee5555eeee8585eeee8585ee
00700700766667d2eeeeeeee3eeeeee3eeee3eee03033000000dd0d000000000e822281ee900091eee8998ee00000000ee55522eee8585eeee55522eee55522e
00077000766766d1eeeeeeeeee3eebeeeee333ee03033033dd0dd0d000000000e888981ee999a91ee88aa88e00000000ee66659eee55522eee66659eee66659e
00077000767666d1eeeeeeeee3333b3eeee3b3ee00033033dd0dd00000000000e888881ee999991ee899a98e00000000ee95999eee66659eee95999ee995999e
00700700766666d1ee11111ee333333eeee333ee03000033dd0000d000000000e888981ee999a91eee8898ee00000000ee9555eeee95999eee9555eeeee555ee
000000002dddddd1e1111111ee3333eeeeee3eee03033000000dd0d000000000e888981ee999a91eeee88eee00000000eee5e5eeee9555eeeee5e5eeee5ee5ee
0000000022211111ee11111eeeeeeeeeeeeeeeee03033033dd0dd0d000000000ee8881eeee9991eeeeeeeeee00000000eee5e5eeeee5e5eeeeee55eeee5ee55e
00000000eee3eeeeeeeeeeeeeeeeeeee00000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5555eeeeeeeeeeee5555eeee5555ee
00000000ee333eeeee555eeeee888eee00000000000000000000000000000000eee5eeeeeeee5eeeeee5eeeeeeee5eeeee8585eeee5555eeee8585eeee8585ee
00000000e3eee3eee5eee5eee8eee8ee00000000000000000000000000000000ee515eeeeee515eeee5155eeee5515eeee55522eee8585eeee55522eee55522e
0000000033e3e33ee5e5e5eee8e8e8ee00000000000000000000000000000000e50115eeee51015ee511115ee501105e6666669eee55522e6666669e6666669e
00000000e3eee3eee5eee5eee8eee8ee00000000000000000000000000000000e510105ee510115ee51105eeee51105ee494499e6666669ee494499ee494499e
00000000ee333eeeee555eeeee888eee00000000000000000000000000000000ee5055eeee5515eeee515eeeeee515eeeee555eee494499eeee555eeeee555ee
00000000eee3eeeeeeeeeeeeeeeeeeee00000000000000000000000000000000eee5eeeeeeee5eeeeee5eeeeeeee5eeeeee5e5eeeee555eeeee5e5eeee5ee5ee
00000000eeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5e5eeeee5e5eeeeee55eeee5ee55e
eee555eeeeeeeeeeeee555eeeee555ee1111111011111110111111101111111111111110111111101000000000000010ee5555eeeeeeeeeeee5555eeee5555ee
ee5cc55eeee555eeee5cc55eee5cc55e1000001110000010100000111000000000000011100000101000000000000010ee8585eeee5555eeee8585eeee8585ee
ee5c5333ee5cc55eee5c5333ee5c53331000000000000010100000000000000000000000000000101000000000000010ee55522eee8585eeee55522eee55522e
666666ffee5c5333666666ff666666ff10000000000000101000000000000000000000000000001010000000000000106666669eee55522e6666669e6666669e
e49449ff666666ffe49449ffe49449ff1000000000000010100000000000000000000000000000101000000000000010e494499e6666669ee494499ee494499e
eee555eee49449ffeee555eeeee555ee1000000000000010100000000000000000000000000000101000000000000010eee555eee494499eeee555eeeee555ee
eee5e5eeeee555eeeee5e5eeee5ee5ee1100000000000110110000000000000000000000000001101100000000000110eee5e5eeeee555eeeee5e5eeee5ee5ee
eee5e5eeeee5e5eeeeee55eeee5ee55e0100000000000100010000000000000000000000000001000100000000000100eee5e5eeeee5e5eeeeee55eeee5ee55e
00000000000000000000000000000000110000000000011011000000000000000000000000000110110000000000011000000000000000000000000000000000
00000000000000000000000000000000100000000000001010000000000000000000000000000010100000000000001000000000000000000000000000000000
00000000000000000000000000000000100000000000001010000000000000000000000000000010100000000000001000000000000000000000000000000000
00000000000000000000000000000000100000000000001010000000000000000000000000000010100000000000001000000000000000000000000000000000
00000000000000000000000000000000100000000000001010000000000000000000000000000010100000000000001000000000000000000000000000000000
00000000000000000000000000000000100000000000001010000011100000000000001110000010100000111000001000000000000000000000000000000000
00000000000000000000000000000000100000000000001011111110111111111111111011111110111111101111111000000000000000000000000000000000
00000000000000000000000000000000100000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
888888888e8888888888ee88888888ee000000000000000000000000eeeeeeeeeeeeeeeeeee5eeeeee5eeeeeeeeeeeee00000000000000000000000000000000
8888888888888888888ee888888888ee000000000000000000000000eeeeeeeeeeeeeeeee555555ee696eeeeeeeeeeee00000000000000000000000000000000
888888888888888888ee8888888888ee000000000000000000000000ee6666ee6666644eeee5555eea9aeeeeeee9eeee00000000000000000000000000000000
888eeeee88888eeeeeee888eeee888ee000000000000000000000000eeee54eee4444e54eeee65eeea9aeeeee9e8eeee00000000000000000000000000000000
888eeeee88888eeeeeee888eeee888ee000000000000000000000000eeeee4eeeeeeeee4eeeee5eeeaeaeeeee8e8eeee00000000000000000000000000000000
888e888888888eeeeeee888eeee888ee000000000000000000000000eeeeeeeeeeeeeeeeeeeee5eeeeeeeeeee8ee889e00000000000000000000000000000000
888e888888888eeeeeee888eeee888ee000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeaaa6eeeeeeeee00000000000000000000000000000000
888ee88888888eeeeeee888eeee888ee00000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
888eeeeeee888eeeeeee888eeee888ee00000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
888eeeeeee888eeeeeee888eeee888ee00000000000000000000000000000000eeeeee2eeeeee2eeeee22e2e0000000000000000000000000000000000000000
888eeeeeee888eeeeeee888eeee888ee00000000000000000000000000000000eeeee22eeee2222eee22222e0000000000000000000000000000000000000000
888eeeeeee88888888888888888888ee00000000000000000000000000000000e2eeeeeeee2222eee22222ee0000000000000000000000000000000000000000
888eeeeeee888888888e888888888eee00000000000000000000000000000000eeee2eeeeeee2eeee222222e0000000000000000000000000000000000000000
888eeeeeee88888888ee88888888eeee00000000000000000000000000000000eeeeeeeeeeeeeeeeee22222e0000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000eeeeeeeeeeeeeeeeeeee2eee0000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
888eeee88e888888888e888eeeeeeeee000000000000000000000000e77777eeeeeeeeee00000000000000000000000000000000000000000000000000000000
888eeee8888888888888888eeeeeeeee000000000000000000000000e778775eee787eee00000000000000000000000000000000000000000000000000000000
888eeee8888888888888888eeeeeeeee000000000000000000000000e788875eee8885ee00000000000000000000000000000000000000000000000000000000
888eeee888888eeeeeee888eeeeeeeee000000000000000000000000e778775eee7875ee00000000000000000000000000000000000000000000000000000000
888eeee888888eeeeeee888eeeeeeeee000000000000000000000000e777775eeee555ee00000000000000000000000000000000000000000000000000000000
888eeee888888888888e888eeeeeeeee000000000000000000000000ee55555eeeeeeeee00000000000000000000000000000000000000000000000000000000
88888888888888888888888eeeeeeeee000000000000000000000000eeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
88888888888888888888888eeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888888888eeeeeee888eeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888eeee888888eeeeeee888eeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888eeee888888eeeeeee888eeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888eeee888888888888e8888888888ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888eeee888e888888888888888888eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e88eeee888ee8888888888888888eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ee9999ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ee2929ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000dd09090ee9999ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000dd0989a0eee889ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000ddd00980e88999ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000005d000000eee999ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000005d000000eee9e9ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000dbbbbb00eee9e9ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000009999999999999909000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000099990000000000000999900000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000099900000000009990000090099900000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000009900000000000090009000090000099000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000990000000000000900000900090000000990000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000099000000000000000900000900090000000009900000000000000000000000000000000000000000000
00000000000000000000000000000000000009990009900000000000000999900000990090000000000099000000000000000000000000000000000000000000
00000000000000000000000000000000000090009990000000000009999000090009009999000000000000900000000000000000000000000000000000000000
00000000000000000000000000000000000090909900000000009990000000009990000990999000000000090000000000000000000000000000000000000000
00000000000000000000000000000000000090009000000000990000000000009090009090000990000000009900000000000000000000000000000000000000
00000000000000000000000000000000000009999000000099000000000000090090009090000009900000000090000000000000000000000000000000000000
00000000000000000000000000000000000009009000000900009990000000090009090090000000090000000009000000000000000000000000000000000000
00000000000000000000000000000000000090000900099000090009000000900009900900000000009900000000900000000000000000000000000000000000
00000000000000000000000000000000000900000090900000090009000000900009000900000000000090000000090000000000000000000000000000000000
00000000000000000000000000000000000900000099000000090009000000900009000900000000000009000000090000000000000000000000000000000000
00000000000000000000000000000000009000000099990000009990000009000000900900000000000000900000009000000000000000000000000000000000
00000000000000000000000000000000090000000909009000009000000009000000900900000000000000090000000900000000000000000000000000000000
00000000000000000000000000000000900000009000900900009000000009000000900900000000000000009000000090000000000000000000000000000000
00000000000000000000000000000000900000090000900099999000000090000000090900000000000000000900000090000000000000000000000000000000
00000000000000000000000000000009000000900000090009000900000090000000090900000000000000000090000009000000000000000000000000000000
00000000000000000000000000000009000000900000090009000900000090000000099000000000000000000090000009000000000000000000000000000000
00000000000000000000000000000090009999000000009009000900000900000000099000000000000000000009990000900000000000000000000000000000
00000000000000000000000000000090990009900000009000999990000900000000009000000000000000000090009000900000000000000000000000000000
00000000000000000000000000000900900000900000000900000009009000000000009000000000000000000090909000090000000000000000000000000000
00000000000000000000000000000909000000090000000900000000909000000000009000000000000000099990009999090000000000000000000000000000
00000000000000000000000000009009000000099900000090000000099000000000000900000000000999900099990000909000000000000000000000000000
00000000000000000000000000009009000000090099999999999900090900000000000900000009999000000909000000099000000000000000000000000000
00000000000000000000000000009000900000900000000000000099999999999900000900099990000000009090000000009000000000000000000000000000
00000000000000000000000000090000990009990000000000000000090009000099999999999900000000090900000000000900000000000000000000000000
00000000000008888888880000888000888888888800000888888880900000888000088090088888888899998880000000000888000000000000000000000000
00000000000008888888888000888200888888888220008888888882900000888200088890088888888889008882000000000888200000000000000000000000
00000000000008888888888200888200888888882290088888888882900000888200088820088888888882008882000000000888200000000000000000000000
00000000000008882222288200888200888222222009988822228882000000888299088820088822222222008882000000000888200000000000000000000000
00000000000008882000088200888200888200000000088820008882000000888200988829088820000000008882000000009888200000000000000000000000
00000000000008882888888200888200888200000009988820008882000000888200988829088888888800008882000000090888200000000000000000000000
00000000000008882888888209888200888200999990088820008882000000888888888829088888888880098882900000900888200000000000000000000000
00000000000008882088888290888209888299000000088820008882000000888888888820988888888882908882099999000888200000000000000000000000
00000000000008882002222209888290888200000000088829908882000000888888888820988822222222008882000090000888200000000000000000000000
00000000000008882000000000888209888290000000088820098882000000888222288820988820009900008882000090000888200000000000000000000000
00000000000008882000000000888200888209990000088820008882000000888200088820988820090000008882000090000888200000000000000000000000
00000000000008882000000000888200888888888899088888888882000000888200088820088888888800008888888888000888888888800000000000000000
00000000000008882000000000888200888888888220988888888822000000888200088820098888888880008888888882200888888888220000000000000000
00000000000008882000000000888200888888882200088888888229900000088200088820099888888882008888888822000888888882200000000000000000
00000000000000222000000000922200922222222000002222222200090000002200002220090022222222000222222220000022222222000000000000000000
00000000000000000000000000900000090000000000000000090000009000000000000009909000009900000000000900000090000000000000000000000000
00000000000000000000000000090000090000000000000000090000000900000000000090009000000090000000000900000900000000000000000000000000
00000000000000000000000000090000090000000000000000900000000099000000009900009000000009000000000900000900000000000000000000000000
00000000000000000000000000090000090000000000000000900000000000900000990000000900000000900000000900000900000000000000000000000000
00000000000000000000000000090000009000000000000009000000000000090009000000000900000000090009999000000900000000000000000000000000
00000000000000000000000000009000099900000000000009000000000000009990000000000900000000009990009900009000000000000000000000000000
00000000000000000000000000009000900090000000000009000000000000009900000000000900000000000900000900009000000000000000000000000000
00000000000000000000000000009000909099999999999999999999999999999099000000000090000000009000000090009000000000000000000000000000
00000000000000000000000000000900900090000000000090000000000009009999999999999999999999999000000090090000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090000000000000000000000000000
00000000000000000000000000000077707770777007700770000007777700000077700770000007707770777077707770900000000000000000000000000000
00000000000000000000000000000070707070700070007000000077000770000007007070000070000700707070700700900000000000000000000000000000
00000000000000000000000000000077707700770077707770000077070770000007007070000077700700777077000700000000000000000000000000000000
00000000000000000000000000000070007070700000700070000077000770000007007070000000700700707070700700000000000000000000000000000000
00000000000000000000000000000070007070777077007700000007777700000007007700000077000700707070700700000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000090000000909990099000000000000000000900090000999000990090000000900000000000000000000000000000000
00000000000000000000000000000000009000000090009900000000000000000000090090000090000090900000009000000000000000000000000000000000
00000000000000000000000000000000000900000900000900000000000000000000090090000900000009000000090000000000000000000000000000000000
00000000000000000000000000000000000900000900000900000000000000000000009090000900000009000000090000000000000000000000000000000000
00000000000000000000000000000000000090000900000900000000000000000000009090000900000009000000900000000000000000000000000000000000
00000000000000000000000000000000000009000090009900000000000000000000009090000090000090000009000000000000000000000000000000000000
00000000000000000000000000000000000000900009990099000000000000000000000990000099000990000090000000000000000000000000000000000000
00000000000000000000000000000000000000099000000000990000000000000000000990000990999000009900000000000000000000000000000000000000
00000000000000000000000000000000000000000900000000009990000000000000000090999000000000090000000000000000000000000000000000000000
00000000000000000000000000000000000000000090000000000009999000000000009999000000000000900000000000000000000000000000000000000000
00000000000000000000000000000000000000000009900000000000000999999999990090000000000099000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000099000000000000000000000000009000000009900000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000990000000000000000000000009000000990000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000009900000000000000000000000900099000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000099900000000000000000009099900000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000099990000000000000999900000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000009999999999999000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660000066606060666066606660666066600000606066606000600000006600666066606660606066600000666060600000066066606660066066000000
00006060000006006060606006000600600060600000606060006000600000006060600066606060606060000000606060600000600060600600606060600000
00006660000006006060666006000600660066000000666066006000600000006060660060606660660066000000660066600000600066600600606060600000
00006060000006006060600006000600600060600000606060006000600000006060600060606060606060000000606000600000600060000600606060600000
00006060000066000660600066600600666060600000606066606660666000006660666060606060606066600000666066600000066060006660660066600000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0008000808000000000800000000000000000000000000000000000000000001000000000c00000001010101010100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000808080808080808080800000000000000000000000000000000000000000101000000000001000103004b004800010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080808080808080808080101000000000000000000000000000000000000010c000857080801000157004b4b5a5a010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010001010100000001000000000000000000000000000000000001010000086700010001010101010159010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000001000101000000000000000000000000000000000000000000000100000c0000000c0000000000000c58580000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010101000000000000000000000000000000000000000000000001000101010c000000000c000c000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000000000103570000000000000000000000000000000000000000000001000000000000000000000001010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004948474a4b4c0101010101010000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000000000000010100000000010000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010000010000000000000000000000000000000000000000000001000404040400000000000000676800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000800010000010000000000000000000000000000000000000000000001000008000800000000006868680000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010100000000000000000000000000000000000000000001000004040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000002c00002c0100000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000800002c2c000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000800000808000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000500000c2332f253152330621302203092030620304203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020309200
0006000014c561cc5624c5632c5608c0608c0608c5608c5608c0602c0602c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c0600c06
010600000d203202430d2030d2031f2530d2030d203202430d2030d203222430d2030d2030d2030d2030120301203012030020300203002030020300203002030020300203002030020300203002030020300203
010500002c6402e640116100c6100b620156302c6403f6403f6403e6403e6403e6403d6403b64036640326402f64026640216301e6301b63018620136200e6200961007610056100361000610006000060000600
000300000e3400b340093300733005320033200231000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000300001c020240402e0502e020023000e3000b30005300023000130001300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000700001b0532005310053111032e103281032e103381031810319103371031b1031d1031e103211032210324103291032a1032d1032f103301030b103091030a10300103001030010300103001030010300103
0008000038f3033f4038f4031f3038f3033f3038f2032f2038f1032f1032f0032f0032f0032f0032f0038f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f003ff0000f0000f0000f0000f0000f00
001200000d15300203032030220302203342030020300203142030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
000300001b0301b040230502304015040120201101011010140301c04021050300503c050000003c050000003c0503b0003e05000000000000000000000000000000000000000000000000000000000000000000
011c00000004500045000450504500045000450004500045000450004500045000450004500045060450004506045000450004500045000450004500045000450304500045000450004500045000450004500045
001a00000081300813008130081300813008130081300813008130081300813008130081300813008130081300813008130081300813008130081300813008130081300813008130081300813008130081300813
001e0000090001000010000070000e0000e0000c00009000090401000010000070000e0000e0000c040090400e0001000010000070400e040070000904015000170000c0000a0000c0400a0400a0400a0400a040
001e000004013000030401300003040130c113040030c113040130c1130c113000030401300003040130000304013000030401300003040130c113040030c113040130c1130c11300003040130c1130c11304013
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000220100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000002201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000022010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000220100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000002201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 0a4b4344
03 0c0d4344

