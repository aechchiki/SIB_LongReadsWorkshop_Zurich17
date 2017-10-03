#!/usr/bin/env python
import sys

lastTranscript = [None, None, None, []]  # ID, chrom, strand, [(start, end, score), ...]


def getID(s):
    """Parse out the ID attribute"""
    s = s.split(";")
    for k in s:
        if k.startswith("ID="):
            return k[3:]
    return None


def dumpLastTranscript():
    """Print the last transcript"""
    bounds = sorted(lastTranscript[3])
    print("{}\tgmapidx\tgene\t{}\t{}\t.\t{}\t.\tgene_id \"{}\"; transcript_id \"{}\";".format(lastTranscript[1], bounds[0][0], bounds[-1][1], lastTranscript[2], lastTranscript[0], lastTranscript[0]))
    print("{}\tgmapidx\ttranscript\t{}\t{}\t.\t{}\t.\tgene_id \"{}\"; transcript_id \"{}\";".format(lastTranscript[1], bounds[0][0], bounds[-1][1], lastTranscript[2], lastTranscript[0], lastTranscript[0]))
    for start, end, score in bounds:
        print("{}\tgmapidx\texon\t{}\t{}\t{}\t{}\t.\tgene_id \"{}\"; transcript_id \"{}\";".format(lastTranscript[1], start, end, score, lastTranscript[2], lastTranscript[0], lastTranscript[0]))


def handleLine(cols):
    """Handle a single line, appending the exon bounds to the previous if relevant"""
    ID = getID(cols[8])
    assert(ID is not None)
    if lastTranscript[0] is not None and lastTranscript[0] != ID:
        dumpLastTranscript()
        lastTranscript[3] = []
    lastTranscript[0] = ID
    lastTranscript[1] = cols[0]
    lastTranscript[2] = cols[6]
    lastTranscript[3].append((int(cols[3]), int(cols[4]), cols[5]))


f = open(sys.argv[1])
for line in f:
    if line.startswith("#"):
        continue
    cols = line.strip().split("\t")
    handleLine(cols)

dumpLastTranscript()
f.close()
