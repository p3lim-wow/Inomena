#!/usr/bin/env python3

# TODO: add item names as comments
# TODO: move away from this directory
# TODO: github action

import re
import sys
from urllib.request import urlopen

# https://ptr.wowhead.com/items?filter=107:195:216;0:2:1;innkeeper:0:0

def scrape(path, pattern):
	page = urlopen(f'https://ptr.wowhead.com/{path}')
	html = page.read().decode('utf-8')
	return re.findall(pattern, html)

hearthstoneIDs = {}

covenant = {
	184353: 'kyrian',
	183716: 'venthyr',
	180290: 'nightfae',
	182773: 'necrolord',
}

sys.stderr.write('Scraping wowhead for itemIDs...\n')

itemIDs = scrape('items?filter=107:195:216;0:2:1;innkeeper:0:0', r'"(\d+)":{"name_enus')

if itemIDs == None or len(itemIDs) == 0:
	sys.stderr.write('No itemIDs found\n')
	sys.exit(1)

sys.stderr.write(f'Scraping done, processing {len(itemIDs)} items...\n')
curIter = 1
for itemID in itemIDs:
	if int(itemID) in hearthstoneIDs:
		continue

	itemName = scrape(f'item={itemID}', r'<title>(.*) - Item - ') # bit wasteful
	hearthstoneIDs[int(itemID)] = itemName[0]

	sys.stderr.write(f'{curIter}/{len(itemIDs)}\n')
	curIter = curIter + 1

print('-- generated by scripts/get_hearthstone_ids.py')
print('local _, addon = ...')
print('addon.HEARTHSTONE_IDS = {')
print('\tname = \'Hearthstone\',')
print('')

for itemID, itemName in sorted(hearthstoneIDs.items()):
	if itemID in covenant:
		print(f"\t{{'toy', {itemID}, show='[covenant:{covenant[itemID]}]'}}, -- {itemName}")
	else:
		print(f"\t{{'toy', {itemID}}}, -- {itemName}")

print(f"\t{{'item', 6948}}, -- Hearthstone")
print('}')

sys.stderr.write('Done\n')
