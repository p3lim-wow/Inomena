#!/usr/bin/env python3

# TODO: add item names as comments
# TODO: github action

from utils import *
import sys

ignoredItems = [42014,42015,42016,42017,42018,51537,60478,64747,65572,70314,70469,70568,72459,73487,73660,128402,169305,194309,207165,208556,219303,222463]
teleportIDs = {}

sys.stderr.write('Scraping wowhead for itemIDs...\n')

itemIDs = scrape('items/slot:16:18:5:8:11:10:1:23:7:21:2:22:13:15:26:14:4:3:19:12:17:6:9?filter-any=107:107:107;0:0:0;teleport:returns:whisks', r'"(\d+)":{"name_enus')

if itemIDs == None or len(itemIDs) == 0:
	sys.stderr.write('No itemIDs found\n')
	sys.exit(1)

sys.stderr.write(f'Scraping done, processing {len(itemIDs)} items...\n')
curIter = 1
for itemID in itemIDs:
	if int(itemID) in ignoredItems:
		sys.stderr.write(f'{curIter}/{len(itemIDs)} ignored...\n')
		curIter = curIter + 1
		continue

	if int(itemID) in teleportIDs:
		sys.stderr.write(f'{curIter}/{len(itemIDs)} duplicate...\n')
		curIter = curIter + 1
		continue

	itemName = scrape(f'item={itemID}', r'<title>(.*) - Item - ') # bit wasteful
	teleportIDs[int(itemID)] = {}
	teleportIDs[int(itemID)]['itemID'] = itemID
	teleportIDs[int(itemID)]['itemName'] = itemName[0]

	sys.stderr.write(f'{curIter}/{len(itemIDs)} ({itemID}: {itemName[0]})\n')
	curIter = curIter + 1

templateLuaTable('teleports', '\t[{itemID}] = true, -- {itemName}', teleportIDs)

sys.stderr.write('Done\n')
