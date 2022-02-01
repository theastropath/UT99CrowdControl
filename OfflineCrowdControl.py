# Can't use real Crowd Control?  Get a taste of the experience with this!

import socket
import time
import random


def genMsg(code,param):
    msg = '{"id":1,"viewer":"Python","code":"'+code+'","type":1'
    if param:
        msg+=',"parameters":['
        paramstr = ""
        for p in param:
            print(p)
            if isinstance(p,int):
                paramstr+=str(p)
            elif isinstance(p,str):
                paramstr+='"'+p+'"'
            paramstr+=","
        paramstr = paramstr[:-1]
        print(paramstr)
        msg+=paramstr
        msg+=']'
    msg+='}\0'

    return msg

def randomAmmo():
    ammo = []
    ammo.append('FlakAmmo') #Flak Cannon
    ammo.append('BioAmmo')  #Bio Rifle
    ammo.append('WarHeadAmmo')  #Redeemer
    ammo.append('PAmmo') #Pulse Gun
    ammo.append('ShockCore') #Shock Rifle
    ammo.append('BladeHopper') #Ripper
    ammo.append('RocketPack') #Rocket 
    ammo.append('BulletBox') #Sniper
    ammo.append('MiniAmmo')   #Enforcer and minigun both use these???

    return random.choice(ammo).lower()

def randomWeapon():
    weapon = []
    weapon.append('Translocator')
    weapon.append('Ripper')
    weapon.append('WarHeadLauncher')
    weapon.append('BioRifle')
    weapon.append('FlakCannon')
    weapon.append('SniperRifle')
    weapon.append('ShockRifle')
    weapon.append('PulseGun')
    weapon.append('MiniGun')
    weapon.append('SuperShockRifle')

    return random.choice(weapon).lower()


def pickEffect():
    effects = []
    
    #return ("give_weapon",[randomWeapon()])  #For testing a specific effect
    
    #effects.append(("gotta_go_slow",None));
    #return random.choice(effects)            #For testing a small selection of effects

    
    #effects.append(None)
    #effects.append(None)
    #effects.append(None)

    #This might be too mean for a machine
    #effects.append(("kill",None))
    
    effects.append(("sudden_death",None))

    effects.append(("full_heal",None))
    effects.append(("full_heal",None))
    
    #effects.append(("full_armour",None))

    #effects.append(("drop_selected_item",None))

    #effects.append(("give_armour",[str(random.randint(10,100))]))
    
    effects.append(("give_health",[str(random.randint(10,100))]))
    effects.append(("give_health",[str(random.randint(10,100))]))
    effects.append(("give_health",[str(random.randint(10,100))]))
    
    #effects.append(("give_armour",[str(random.randint(10,100))]))

    #effects.append(("disable_jump",None))

    effects.append(("gotta_go_fast",None))

    effects.append(("gotta_go_slow",None))

    #effects.append(("ice_physics",None))

    effects.append(("third_person",None))

    effects.append(("double_dmg",None))
    
    effects.append(("thanos",None))
    effects.append(("full_fat",None))
    effects.append(("skin_and_bones",None))
    effects.append(("no_ammo",None))

    #effects.append(("give_"+randomWeapon(),None))

    effects.append(("nudge",None))

    effects.append(("swap_player_position",None))

    #effects.append(("low_grav",None))
    
    effects.append(("give_ammo",[randomAmmo(),random.randint(1,2)]))


    return random.choice(effects)


s=socket.create_server(("localhost",43384))

while True:
    print("Connecting...")
    conn,addr = s.accept()

    with conn:
        print("Connected to ",addr)
        while True:
            #conn.send(x)
            effect = pickEffect()
            if effect!=None:
                msg = genMsg(effect[0],effect[1])
                print("Sending "+msg)
                try:
                    conn.send(msg.encode('utf-8'))
                except:
                    break
                print("Sent")
            time.sleep(random.randint(5,15))
