pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico hell
-- by cpio
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

function _init()
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
--	music(1)
 anim=false
 player={hp=maxhp,ent=9,deltatime=rnd(),wpn=make_weapon(3),arm=0}
 bullets={}
 floor_weapons={}
 decor={}
 soot={}
 explosion={}
 blood={}
 medkits_used={}
 entities={}
 barrels={}
 ammo={12,0,0}
 max_ammo={50,30,100}
 init_seen()
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
spr(64,13,55,7,2)
spr(96,8+7*8,55,7,2)
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
 cls()
 camera()
 clip(0,8,128,112)
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
 map(0,0,0,0,32,32)

 unset_unseen_color()
 for x=max(0,player.x-visibility_radius),min(player.x+visibility_radius,31) do
  for y=max(0,player.y-visibility_radius),min(player.y+visibility_radius,31) do
   if(is_seen({x=x,y=y})) map(x,y,8*x,8*y,1,1)
  end
 end
 
 for d in all(soot) do
  if(is_seen(d)) set_color(d) spr(d.sprnb,8*d.x,8*d.y-2)
 end
 for d in all(decor) do
  if(is_seen(d)) set_color(d) spr(d.sprnb,8*d.x,8*d.y-2)
 end
 for e in all(entities) do
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
 clip()
 camera()
 -- health bar
 color(3)
 print("♥======== "..player.hp.."/"..maxhp,16,1)
 if(player.arm>0) print("armor "..player.arm,90,1)
 print(weapon_name[player.wpn.typ].." "
 ..player.wpn.amm
 .."/"..player.wpn.mag
 .." ("..ammo[player.wpn.ammtyp]..")",
 16,15*8+1)
 print(stat(0).."kb "..(stat(1)*100).."%",1,16)
 flip()

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

function animate_medkit(tim)
 if t()-tim<=0.25 then
  r=300/4-(t()-tim)*300
  circ(player.ox+4,player.oy+2,r,12)
  return true
 end
 del(medkit_used,tim)
 return false
end

function animate_camera()
 if(cam_x<cam_xc) cam_x+=ceil((cam_xc-cam_x)/4)
 if(cam_x>cam_xc) cam_x-=ceil((cam_x-cam_xc)/4)
 if(cam_y<cam_yc) cam_y+=ceil((cam_yc-cam_y)/4)
 if(cam_y>cam_yc) cam_y-=ceil((cam_y-cam_yc)/4)
 if(cam_x!=cam_xc or cam_y!=cam_yc) printh("animate camera")
 return cam_x!=cam_xc or cam_y!=cam_yc
end

function animate_ent(e)
 local x=e.x*8
 local y=e.y*8
 if e.ox!=x or e.oy!=y then
  if(x-1>e.ox) e.ox+=3
  if(x+1<e.ox) e.ox-=3
  if(y-1>e.oy) e.oy+=3
  if(y+1<e.oy) e.oy-=3
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
  if(t%(0.7)>0.35) d=1
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
  e[4]+=0.5
  e[1]+=e[3]
  e[2]+=e[4]
  pset(e[1],e[2],8)
  return true
 end
end

function explode(ex)
 cam_dx=rnd(6)-3
 cam_dy=rnd(6)-3
 for e in all(ex[1]) do
  circfill(e.x,e.y,min(e.rad,200*(t()-e.t)),8)
  circfill(e.x,e.y,min(e.rad,200*(t()-e.t-0.1)),9)
  circfill(e.x,e.y,min(e.rad,200*(t()-e.t-0.3)),0)
  if 200*(t()-e.t-0.3)>e.rad then
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
 for i=0,1 do
  pal(i,0)
 end
 for i=2,15 do
  pal(i,5)
 end
end

function unset_unseen_color()
 pal()  
 palt(0, false)
 palt(14, true)
end

function add_msg(msg,c,c2,x,y,v)
 if(c==nil) c=7
 if(x==nil) x=player.ox
 if(y==nil) y=player.oy
 if(v==nil) v=1
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
 if is_visible(e.x,e.y) then
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
	if(typ==3) return {typ=3,ammtyp=1,mag=24,amm=24,bul=4,rng=5,dmg=3,disp=2,ent=0,sprnb=73,used=4,maxrng=9,delay=1,drp=true}
	if(typ==4) return {typ=4,ammtyp=0,mag=100,amm=100,bul=1,rng=5,dmg=10,disp=1,ent=0,used=1,maxrng=9,delay=0,bulspr=10}
	assert(false,typ)
end

function make_floor_weapon(x,y,typ)
 w=make_weapon(typ-70)
 w.x=x
 w.y=y
 add(floor_weapons,w)
end

function make_floor_ammo(x,y,typ)
 typ-=73
 add(floor_weapons,make_ammo(x,y,typ))
end

function make_ammo(x,y,typ)
 if(typ==1) return {typ=1,ammo=12,sprnb=74,ent=5,x=x,y=y}
 if(typ==2) return {typ=2,ammo=4,sprnb=75,ent=5,x=x,y=y}
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
 if(typ==0) add(entities,{facing=1,sprnb=12+16*typ,x=x,y=y,ox=8*x,oy=8*y,hp=10,wpn=make_weapon(1),ent=1,rng=3,deltatime=rnd()})
 if(typ==1) add(entities,{facing=1,sprnb=12+16*typ,x=x,y=y,ox=8*x,oy=8*y,hp=10,wpn=make_weapon(2),ent=1,rng=3,deltatime=rnd()})
 if(typ==2) add(entities,{facing=1,sprnb=12+16*typ,x=x,y=y,ox=8*x,oy=8*y,hp=10,wpn=make_weapon(4),ent=1,rng=3,deltatime=rnd()})
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


-- decorative struct:
-- x,y: pos
-- sprnb: sprite number
function add_blood(x,y)
 local l=88
-- printh("add_blood")
 for e in all(decor) do
--  printh(e.x.." "..e.y.." "..x.." "..y.." "..e.sprnb)
  if(e.x==x and e.y==y) l=min(90,e.sprnb+1) --printh(e.sprnb)
 end
 add(decor,{x=x,y=y,sprnb=l,ent=3})
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
 else
  -- bump animation
  player.ox+=3*d[1]
  player.oy+=3*d[2]
 end
end

function pickup_armor()
 for e in all(floor_weapons) do
  if e.ent==7 and e.x==player.x and e.y==player.y and player.arm<maxarm then
   del(floor_weapons,e)
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
  add_msg("+"..tostr(ammo[a.typ]-old).." ammo")
 end
end

function use_medkit()
 for e in all(floor_weapons) do
  if e.ent==6 and e.x==player.x and e.y==player.y and player.hp<maxhp then
   del(floor_weapons,e)
   add(medkits_used,t())
   sfx(7)
   local old=player.hp
   player.hp=min(maxhp,player.hp+e.hp)
   add_msg("+"..tostr(player.hp-old).." hp",12,1)
   warn_low=false
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
 local d=dep[btnp()]
 -- move
 if d!=nil then
  player_move(d)
 -- start aim
 elseif btnp(❎) then
  player_start_aim()
 elseif btnp(🅾️) and not o_pressed then
  o_pressed=t()
 elseif o_pressed and t()-o_pressed>0.2 then 
  local w=player.wpn
  local w2=get_floor_weapon(player.x,player.y)
  if w2==nil or w2.ent!=0 then
   add_msg("no weapon!")
  else
   add_msg("got it!")
   w.x=player.x
   w.y=player.y
   add(floor_weapons,w)
   player.wpn=w2
   del(floor_weapons,w2)
   w3=get_floor_weapon(player.x,player.y)
  end
	 o_pressed=nil
 elseif o_pressed and not btn(🅾️) then
  -- reload
  local w=player.wpn
  if w.mag!=w.amm and ammo[player.wpn.ammtyp]>0 then
   local amount=min(ammo[player.wpn.ammtyp],w.mag-w.amm)
   ammo[player.wpn.ammtyp]-=amount
   w.amm+=amount
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
   add_msg("no")
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
  if not is_visible(e.x,e.y,true) then
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
  local speed=10
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
 if(e.ent==1 or e==player) add_msg("-"..tostr(dmg).." hp",9,1,e.ox,e.oy,2) add_blood(e.x,e.y)
 if e.arm then -- armor
  local arm_dmg=min(e.arm,dmg)
  e.arm-=arm_dmg
  dmg-=arm_dmg
 end
 e.hp-=dmg
 if e.hp<=0 then
  -- if dead, project blood
  if e==player or e.ent==1 then
   for i=1,5 do
    local v=1+rnd(1)
    local a=rnd(0.5)
    add(blood,{e.ox+4+rnd(2)-1,e.oy+rnd(2)-1,
    cos(a)*v,sin(a)*v,t()+0.2+rnd(0.1)})
   end
  end
  if e==player then
   state=102 --game over
--   wait=120
  elseif(e.ent==1) then
   del(entities,e)
   if e.wpn.drp then
    local x,y=get_empty_tile(e.x,e.y)
    e.wpn.x=x
    e.wpn.y=y
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

function closest_enemy(x,y)
 local e2=nil
 local m=0
 for e in all(entities) do
  if is_visible(e.x,e.y,true) then
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
   if euc_dist(x,y,player.x,player.y)<=5 and not seen[x+1][y+1] then
    seen[x+1][y+1]=is_visible(x,y,false)
   end
  end
 end
end

function is_seen(e)
 return seen[e.x+1][e.y+1]
end
-->8
-- line of sight

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
 [75]=make_floor_ammo}
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
 player["x"]=x
 player["y"]=y
 player["ox"]=8*x
 player["oy"]=8*y
 
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
00000000776666d2eeeeeeee333ee333eeeeeeee000000000000000000000000e82228eee90009eeeee88eee00000000ee8585eeee5555eeee8585eeee8585ee
00700700766667d2eeeeeeee3eeeeee3eeee3eee000000000000000000000000e822281ee900091eee8998ee00000000ee55522eee8585eeee55522eee55522e
00077000766766d1eeeeeeeeee3eebeeeee333ee000000000000000000000000e888981ee999a91ee88aa88e00000000ee66659eee55522eee66659eee66659e
00077000767666d1eeeeeeeee3333b3eeee3b3ee000000000000000000000000e888881ee999991ee899a98e00000000ee95999eee66659eee95999ee995999e
00700700766666d1ee11111ee333333eeee333ee000000000000000000000000e888981ee999a91eee8898ee00000000ee9555eeee95999eee9555eeeee555ee
000000002dddddd1e1111111ee3333eeeeee3eee000000000000000000000000e888981ee999a91eeee88eee00000000eee5e5eeee9555eeeee5e5eeee5ee5ee
0000000022211111ee11111eeeeeeeeeeeeeeeee000000000000000000000000ee8881eeee9991eeeeeeeeee00000000eee5e5eeeee5e5eeeeee55eeee5ee55e
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
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
eee888888888eeee888eee8888888888eeeee88888888eeeeeeeeeeeeeeeeeeeeeeeeeeeeee5eeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
eee8888888888eee8882ee88888888822eee8888888882eeeeeeeeeeeeeeeeeeeeeeeeeee555555eeee5e5eeeee0eeee00000000000000000000000000000000
eee88888888882ee8882ee8888888822eee88888888882eeeeeeeeeeee6666ee6666644eeee5555eee69696ee0090eee00000000000000000000000000000000
eee88822222882ee8882ee888222222eeee88822228882eeeeeeeeeeeeee54eee4444e54eeee65eeeea9a9ae09080eee00000000000000000000000000000000
eee8882eeee882ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeeeeeeee4eeeeeeeee4eeeee5eeeea9a9ae0808000e00000000000000000000000000000000
eee88828888882ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5eeeeaeaeae0800889000000000000000000000000000000000
eee88828888882ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0ee000e00000000000000000000000000000000
eee8882e888882ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
eee8882ee22222ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeee00000000eeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee8882eeeeeeeee8882eee8882eeeeeeeeee00000000eeeeee8eeeeeeeeeeee88e8e0000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee8882eeeeeeeee8882eee8882eeeeeeeeee00000000eeeeeeeeeeee888eee88888e0000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee8888888888eee88888888882eeeeeeeeee00000000e8eeeeeeee8888eee88888ee0000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee88888888822ee88888888822eeeeeeeeee00000000eeee8eeeeeee8eeee888888e0000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee8888888822eee8888888822eeeeeeeeeee00000000eeeeeeeeeeeeeeeeee88888e0000000000000000000000000000000000000000
eeee222eeeeeeeeee222eee22222222eeeee22222222eeeeeeeeeeee00000000eeeeeeeeeeeeeeeeeeee8eee0000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
e888eeee88eeee888888888eeee888eeeeeeeee888eeeeeeeeeeeeeee77777eeeeeeeeee00000000000000000000000000000000000000000000000000000000
e8882eee888eee8888888888eee8882eeeeeeee8882eeeeeeeeeeeeee778775eee787eee00000000000000000000000000000000000000000000000000000000
e8882eee8882ee88888888882ee8882eeeeeeee8882eeeeeeeeeeeeee788875eee8885ee00000000000000000000000000000000000000000000000000000000
e8882eee8882ee88822222222ee8882eeeeeeee8882eeeeeeeeeeeeee778775eee7875ee00000000000000000000000000000000000000000000000000000000
e8882eee8882ee888eeeeeeeeee8882eeeeeeee8882eeeeeeeeeeeeee777775eeee555ee00000000000000000000000000000000000000000000000000000000
e8882eee8882ee888888888eeee8882eeeeeeee8882eeeeeeeeeeeeeee55555eeeeeeeee00000000000000000000000000000000000000000000000000000000
e88888888882ee8888888888eee8882eeeeeeee8882eeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000
e88888888882ee88888888882ee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e88888888882ee88822222222ee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e88822228882ee888eeeeeeeeee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e8882eee8882ee888eeeeeeeeee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e8882eee8882ee888888888eeee8888888888ee8888888888eeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e8882eee8882eee8888888882ee88888888822e88888888822eeeeee000000000000000000000000000000000000000000000000000000000000000000000000
ee882eee8882eeee888888882ee8888888822ee8888888822eeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee22eeee222eeeee22222222eee22222222eeee22222222eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
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
0550500000000000000000000000000000000000ee9999ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
90000000000bb7bb0aa744440000835000000000ee2929ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
98b80000000bbbbb00004440000012c00dd09090ee9999ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
99880000000777770000444000007cf0dd0989a0eee889ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
088899880000000b0000444000009df0ddd00980e88999ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
000809800000000b000044400000aa605d000000eee999ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
000888800000000b00000000000099b05d000000eee9e9ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00080080000000000000000000000000dbbbbb00eee9e9ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888777777888eeeeee888eeeeee888eeeeee888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88778877788ee888ee88ee888ee88ee8e8ee88888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8777787778eeeee8ee8eeeee8ee8eee8e8ee88888e88888888888888888888888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8777787778eee888ee8eeee88ee8eee888ee8888eee8888888888888888888888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee8777787778eee8eeee8eeeee8ee8eeeee8ee88888e88888888888888888888888888888ff888ff888822228888228222888882282888222288888
888eee888ee8777888778eee888ee8eee888ee8eeeee8ee888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8777777778eeeeeeee8eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116161661116616661666111116161661116616661666166111111166116616111166166611711171111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616161116111161111116161616161116111611161611111611161616111616161617111117111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116161616166616611161111116161616166616611661161611111611161616111616166117111117111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616111616111161111116161616111616111611161611111611161616111616161617111117111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111111661616166116661161166611661616166116661666161616661166166116661661161611711171111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1b111171117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b1b1b1b1b111711111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1b111711111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b1b1b111711111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111b111b1b1bbb1171117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1b111bbb11711ccc111111111ccc1ccc1c1111cc1ccc117111111111111111111111111111111111111111111111111111111111111111111111
11111b1b1b1b1b1111b117111c1c111111111c111c1c1c111c111c11111711111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1b1111b117111c1c111111111cc11ccc1c111ccc1cc1111711111111111111111111111111111111111111111111111111111111111111111111
11111b111b1b1b1111b117111c1c117111111c111c1c1c11111c1c11111711111111111111111111111111111111111111111111111111111111111111111111
11111b111b1b1bbb11b111711ccc171111111c111c1c1ccc1cc11ccc117111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1b111bbb11711cc11c1c111111111ccc1ccc1c1c1ccc117111111111111111111111111111111111111111111111111111111111111111111111
11111b1b1b1b1b1111b1171111c11c1c1111111111c11c1c1c1c1c11111711111111111111111111111111111111111111111111111111111111111111111111
11111bbb1bbb1b1111b1171111c11ccc1111111111c11cc11c1c1cc1111711111111111111111111111111111111111111111111111111111111111111111111
11111b111b1b1b1111b1171111c1111c1171111111c11c1c1c1c1c11111711111111111111111111111111111111111111111111111111111111111111111111
11111b111b1b1bbb11b111711ccc111c1711111111c11c1c11cc1ccc117111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1ee111ee1eee1eee11ee1ee1111116661666166616611666111116661611116616661666117116661166116611711111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116161616116116161161111116111611161616161161171116661611161111171111111111111111111111111111
1ee11e1e1e1e1e1111e111e11e1e1e1e111116661661116116161161111116611611161616661161171116161666161111171111111111111111111111111111
1e111e1e1e1e1e1111e111e11e1e1e1e111116111616116116161161111116111611161616161161171116161116161611171111111111111111111111111111
1e1111ee1e1e11ee11e11eee1ee11e1e111116111616166616161161166616111666166116161161117116161661166611711111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee111116661166116617711ccc1177111111111ccc11111eee1e1e1eee1ee111111111111111111111111111111111111111111111111111111111
111111e11e1111111666161116111711111c1117177717771c1c111111e11e1e1e111e1e11111111111111111111111111111111111111111111111111111111
111111e11ee1111116161666161117111ccc1117111111111c1c111111e11eee1ee11e1e11111111111111111111111111111111111111111111111111111111
111111e11e11111116161116161617111c111117177717771c1c111111e11e1e1e111e1e11111111111111111111111111111111111111111111111111111111
11111eee1e11111116161661166617711ccc1177111111111ccc111111e11e1e1eee1e1e11111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111bb11bbb1b11117116661666116611661166111116661166116611711111111111111111111111111111111111111111111111111111111111111111
111111111b1b1b111b11171116661611161116111611111116661611161111171111111111111111111111111111111111111111111111111111111111111111
111111111b1b1bb11b11171116161661166616111666111116161666161111171111111111111111111111111111111111111111111111111111111111111111
111111111b1b1b111b11171116161611111616161116117116161116161611171111111111111111111111111111111111111111111111111111111111111111
111111111bbb1bbb1bbb117116161666166116661661171116161661166611711111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111eee1eee1eee1e1e1eee1ee111111ccc1ccc1c1111cc1ccc111111111111111111111111111111111111111111111111111111111111111111111111
111111111e1e1e1111e11e1e1e1e1e1e11111c111c1c1c111c111c11111111111111111111111111111111111111111111111111111111111111111111111111
111111111ee11ee111e11e1e1ee11e1e11111cc11ccc1c111ccc1cc1111111111111111111111111111111111111111111111111111111111111111111111111
111111111e1e1e1111e11e1e1e1e1e1e11111c111c1c1c11111c1c11111111111111111111111111111111111111111111111111111111111111111111111111
111111111e1e1eee11e111ee1e1e1e1e11111c111c1c1ccc1cc11ccc111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1111ee1eee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e111e111e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e111eee1ee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e11111e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1eee1ee11eee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116661166116617711ccc1177111111111cc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111666161116111711111c11171111177711c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116161666161117111ccc11171777111111c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116161116161617111c1111171111177711c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111116161661166617711ccc1177111111111ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111188888111111111111111111111111111
111111111bbb1bbb1bbb1bb11bbb117116661166116617711cc11177111116661611166616161666166611111166161688888666161116661616166616661111
111111111b1b1b1b11b11b1b11b11711166616111611171111c11117111116161611161616161611161611111616161688888616161116161616161116161111
111111111bbb1bb111b11b1b11b11711161616661611171111c11117111116661611166616661661166111111616116188888666161116661666166116611111
111111111b111b1b11b11b1b11b11711161611161616171111c11117117116111611161611161611161611111616161688788611161116161116161116161111
111111111b111b1b1bbb1b1b11b1117116161661166617711ccc1177171116111666161616661666161611711661161687888611166616161666166616161171
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111171111111111111111111111111
111111111eee1eee1eee1e1e1eee1ee111111ccc1ccc1c1c1ccc1111111111111111111111111111111111111111111111111177111111111111111111111111
111111111e1e1e1111e11e1e1e1e1e1e111111c11c1c1c1c1c111111111111111111111111111111111111111111111111111177711111111111111111111111
111111111ee11ee111e11e1e1ee11e1e111111c11cc11c1c1cc11111111111111111111111111111111111111111111111111177771111111111111111111111
111111111e1e1e1111e11e1e1e1e1e1e111111c11c1c1c1c1c111111111111111111111111111111111111111111111111111177111111111111111111111111
111111111e1e1eee11e111ee1e1e1e1e111111c11c1c11cc1ccc1111111111111111111111111111111111111111111111111111711111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1ee11ee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ee11e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111e111e1e1e1e1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111eee1e1e1eee1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888828282228222888282828222822288888888888888888888888888888888888882828282822282228882822282288222822288866688
82888828828282888888828282828282882882828282888288888888888888888888888888888888888882828282888288828828828288288282888288888888
82888828828282288888822282828282882882228282882288888888888888888888888888888888888882228222882288828828822288288222822288822288
82888828828282888888888282828282882888828282888288888888888888888888888888888888888888828882888288828828828288288882828888888888
82228222828282228888888282228222828888828222822288888888888888888888888888888888888888828882822288828288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0008000808000000000800000000000000000000000000000000000000000001000000000c00000001010101010100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000808080808080808080800000000000000000000000000000000000000000100000000000001000103004b004800010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080808080808080808080101000000000000000000000000000000000000010c000857080801000157004b4b0000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010001010100000001000000000000000000000000000000000001000000080000010001010101010100010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000001000101000000000000000000000000000000000000000000000100000c0000000c0000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010101000000000000000000000000000000000000000000000001000101010c000000000c000c000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000000000103570000000000000000000000000000000000000000000001000000000000000000000001010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004948474a4b4c0101010101010000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000000000000010100000000010000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000010000010000000000000000000000000000000000000000000001000404040400000000000000006800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000e00000a1530410301103111032e103281032e103381031810319103371031b1031d1031e103211032210324103291032a1032d1032f103301030b103091030a10300103001030010300103001030010300103
0008000038f3033f4038f4031f3038f3033f3038f2032f2038f1032f1032f0032f0032f0032f0032f0038f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f003ff0000f0000f0000f0000f0000f00
001200000d15300203032030220302203342030020300203142030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203002030020300203
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

