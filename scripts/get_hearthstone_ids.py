#!/usr/bin/env python3

# TODO: add item names as comments
# TODO: move away from this directory
# TODO: github action

from utils import *
import sys

# https://ptr.wowhead.com/items?filter=107:195:216;0:2:1;innkeeper:0:0

hearthstoneIDs = {}

condition = {
	184353: 'covenant:kyrian',
	183716: 'covenant:venthyr',
	180290: 'covenant:nightfae',
	182773: 'covenant:necrolord',
	210455: 'race:draenei/lightforged',
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
		sys.stderr.write(f'{curIter}/{len(itemIDs)} duplicate...\n')
		curIter = curIter + 1
		continue

	itemName = scrape(f'item={itemID}', r'<title>(.*) - Item - ') # bit wasteful
	hearthstoneIDs[int(itemID)] = itemName[0]

	sys.stderr.write(f'{curIter}/{len(itemIDs)}\n')
	curIter = curIter + 1

print('-- this file is auto-generated')
print('local _, addon = ...')
print('addon.data = addon.data or {{}}')
print('addon.data.hearthstones = {')
print('\tname = \'Hearthstone\',')
print('')

for itemID, itemName in sorted(hearthstoneIDs.items()):
	if itemID in condition:
		print(f"\t{{'toy', {itemID}, show='[{condition[itemID]}]'}}, -- {itemName}")
	else:
		print(f"\t{{'toy', {itemID}}}, -- {itemName}")

print(f"\t{{'item', 6948}}, -- Hearthstone")
print('}')

sys.stderr.write('Done\n')
