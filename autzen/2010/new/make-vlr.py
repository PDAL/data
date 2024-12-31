

data="""Ground,    2
Vegetation,    5
Building,    6
Water,    9
Transmission Tower,    15
Bridge Deck,    17
Overhead Structure,    19
Wire,    64
Car,    65
Truck,    66
Boat,    67
Barrier,    68
Railroad Car,    69
Elevated Walkway,    70
Covered Walkway,    71
Pier/Dock,    72
Fence,    73
Tower,    74
Crane,    75
Silo/Storage,    76
Bridge Structure,    77"""

lines = data.split('\n')


import struct
import base64
import json

fmt = '<B15c'


limit = 15
vlr = None
for line in lines:
    description, value = line.split(',')
    desc = description[:limit].ljust(limit, '\0')
    desc = [bytes(i, 'utf-8') for i in desc]


    p = struct.pack(fmt, int(value), *desc)
    if not vlr:
        vlr = p
    vlr = vlr + p


b64 = base64.b64encode(vlr)
b64 = b64.decode('utf-8')


vlr = {
    "description": "ASPRS Classification Lookup",
    "record_id": 0,
    "user_id": "LASF_Spec",
    "data": b64
}


print (json.dumps(vlr))

