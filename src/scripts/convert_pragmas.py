#!/usr/bin/python

# Copyright (c) 2016 Fondazione Bruno Kessler www.fbk.eu
# Author Roberto Tiella

# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to 
# deal in the Software without restriction, including without limitation the 
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
# sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
# IN THE SOFTWARE.



import sys
import re

def usage():
	print >> sys.stderr, "Usage:",sys.argv[0],"[-r] fin [fout]"
	print >> sys.stderr, "converts pragmas from old to aspire 'function notation' and back to c99 format"
	print >> sys.stderr, "\t-r\treverse direction"

def from_old_pragmas_to_aspire(fin,fout):
	for l in open(finfn):
		ls = l.strip()
		if ls.startswith("#pragma ASPIRE"):
			s = ls.split(" ");
			if s[2] == "begin":
				print >> fout,'_ASPIRE_BLOCK_BEGIN("'+' '.join(s[3:])+'")'
			elif s[2] == "end":
				print >> fout,'_ASPIRE_BLOCK_END()'
			else:
				print >> sys.stderr, "Syntax error at line: ",l
				sys.exit(2)
		else:
			print >> fout, ls

	fout.close()

def from_aspire_to_new_pragmas(fin,fout):
	for l in open(finfn):
		newl = re.sub('_ASPIRE_BLOCK_BEGIN\s*\(\s*"(.*)"\s*\)','_Pragma("ASPIRE begin \\1")',l)
		if newl == l:
			newl = re.sub('_ASPIRE_BLOCK_END\s*\(\s*\)','_Pragma("ASPIRE end")',l)
		print >> fout, newl
	fout.close()

expargs=2
argi=1

reverse=False

if len(sys.argv) < expargs:
	usage()
	sys.exit(1)

if sys.argv[argi] == '-r':
	reverse=True
	argi += 1
	expargs += 1

if len(sys.argv) < expargs:
	usage()
	sys.exit(1)

finfn=sys.argv[argi]
argi += 1

fin=open(finfn)
fout=sys.stdout

# print len(sys.argv),expargs,argi

if len(sys.argv) > expargs:
	foutfn=sys.argv[argi]
	argi += 1
	fout=open(foutfn,"w")

if not reverse:
	from_old_pragmas_to_aspire(fin,fout)
else:
	from_aspire_to_new_pragmas(fin,fout)
