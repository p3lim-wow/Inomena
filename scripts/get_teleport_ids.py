#!/usr/bin/env python3

# TODO: add item names as comments
# TODO: github action

import re
import sys
from urllib.request import urlopen

ignoredItems = [42014,42015,42016,42017,42018,51537,60478,64747,65572,70314,70469,70568,72459,73487,73660,128402,169305,194309]

def scrape(path, pattern):
	page = urlopen(f'https://ptr.wowhead.com/{path}')
	html = page.read().decode('utf-8')
	return re.findall(pattern, html)

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
		continue

	if int(itemID) in teleportIDs:
		continue

	itemName = scrape(f'item={itemID}', r'<title>(.*) - Item - ') # bit wasteful
	teleportIDs[int(itemID)] = itemName[0]

	sys.stderr.write(f'{curIter}/{len(itemIDs)} ({itemID}: {itemName[0]})\n')
	curIter = curIter + 1

print('-- generated by scripts/get_teleport_ids.py')
print('local _, addon = ...')
print('addon.TELEPORT_IDS = {')

for itemID, itemName in sorted(teleportIDs.items()):
	print(f'\t[{itemID}] = true, -- {itemName}')

print('}')

sys.stderr.write('Done\n')