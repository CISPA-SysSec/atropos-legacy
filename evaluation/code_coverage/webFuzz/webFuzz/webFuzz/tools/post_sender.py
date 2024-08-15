#!/bin/env python3.8

import aiohttp
import asyncio
import json
from sys import argv

with open(argv[1], "r") as f:
    ajson = json.load(f)

cookies = {}
for item in ajson:
    name = item['name']
    value = item['value']
    cookies[name] = value

if len(argv) > 2:
    with open(argv[2], "r") as f:
        req = eval(f.read())
else:
    print("enter request:")
    req = eval(input())

async def call():
    async with aiohttp.ClientSession(cookies=cookies) as session:
        print(">>> ", req["url"])
        resp = await session.post(req["url"],
                                  params=req["params"]["GET"], 
                                  data=req["params"]["POST"])
        print(">>> ", resp.status)
        print(">>> ", resp.content_type)
        with open("out.html", "w+") as f:
            f.write(await resp.text())

asyncio.run(call())
