#!/usr/bin/env python3

import re
import sys
from urllib.request import urlopen

# https://www.wowhead.com/spells?filter=109;54;0
# see the "Effect" field from these spells, the value in paranteses

# some spells should be ignored (like test spells)
ignoredSpellIDs = [
	36503,
	162426,
	172938,
]

def scrape(path, pattern):
	page = urlopen(f'https://www.wowhead.com/{path}')
	html = page.read().decode('utf-8')
	return re.findall(pattern, html)

enchantIDs = {}

sys.stderr.write('Scraping wowhead for enchantIDs...\n')

spellIDs = scrape('spells?filter=109;54;0', r'"(\d+)":{"name_enus')
if spellIDs == None or len(spellIDs) == 0:
	sys.stderr.write('No spellIDs found\n')
	sys.exit(1)

for spellID in spellIDs:
	if int(spellID) in ignoredSpellIDs:
		continue

	enchantID = scrape(f'spell={spellID}', r'&nbsp;\((\d+)\)')
	enchantName = scrape(f'spell={spellID}', r'<title>(.*) - Spell - ') # bit wasteful

	if enchantID == None or len(enchantID) == 0:
		sys.stderr.write(f'No enchantID found for spellID {spellID}\n')
		sys.exit(1)

	enchantID = int(enchantID[0])
	enchantIDs[enchantID] = {}
	enchantIDs[enchantID]['spellID'] = int(spellID)
	enchantIDs[enchantID]['name'] = enchantName[0]

print('local ENCHANT_IDS = {')
print('\t-- generated by get_enchant_ids.py')
print('\t-- enchantID = spellID')

for enchantID, info in sorted(enchantIDs.items()):
	print(f'\t[{enchantID}] = {info["spellID"]}, -- {info["name"]}')

print('}')

sys.stderr.write('Done\n')