#!/usr/bin/env python3

from utils import *
import sys

# https://www.wowhead.com/spells?filter=109;54;0
# see the "Effect" field from these spells, the value in paranteses

# some spells should be ignored (like test spells)
ignoredSpellIDs = [
	36503,
	162426,
	172938,
	409669,
	409671,
	409672,
]

enchantIDs = {}

sys.stderr.write('Scraping wowhead for enchantIDs...\n')

spellIDs = scrape('spells?filter=109;54;0', r'"(\d+)":{"name_enus')
if spellIDs == None or len(spellIDs) == 0:
	sys.stderr.write('No spellIDs found\n')
	sys.exit(1)

sys.stderr.write(f'Scraping done, processing {len(spellIDs)} enchantIDs...\n')
curIter = 1

for spellID in spellIDs:
	if int(spellID) in ignoredSpellIDs:
		sys.stderr.write(f'{curIter}/{len(spellIDs)} ignored...\n')
		curIter = curIter + 1
		continue

	enchantID = scrape(f'spell={spellID}', r'&nbsp;\((\d+)\)')
	enchantName = scrape(f'spell={spellID}', r'<title>(.*) - Spell - ') # bit wasteful

	if enchantID == None or len(enchantID) == 0:
		sys.stderr.write(f'No enchantID found for spellID {spellID}\n')
		sys.exit(1)

	enchantID = int(enchantID[0])
	enchantIDs[enchantID] = {}
	enchantIDs[enchantID]['enchantID'] = enchantID
	enchantIDs[enchantID]['spellID'] = int(spellID)
	enchantIDs[enchantID]['name'] = enchantName[0]

	sys.stderr.write(f'{curIter}/{len(spellIDs)}\n')
	curIter = curIter + 1


templateLuaTable('enchants', '\t[{enchantID}] = {spellID}, -- {name}', enchantIDs)

sys.stderr.write('Done\n')
