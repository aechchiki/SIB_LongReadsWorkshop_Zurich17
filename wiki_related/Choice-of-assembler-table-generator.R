source('table_print.R')

# testing
# df <- data.frame(sd = 1:5, swdasd = 6:10, asd = c('a', 'dsfa', 'asdfaa', 'bv', 'sadf'))
# print.mdtable(df)

assemblers <- c('Falcon', 'Canu', 'HGAP', 'Miniasm', 'HINGE')
# O <-
# L <-
# C <-
genome_size <- c('any','any','bacterial size', 'any','')
heterozygosity <- c('any', 'low or high', '', 'low', '')
pros <- c('Handling variable levels of haplotype divergence', 'elegant read correction, nice assembly reports', 'usually single contig assembly of bacteria', 'easy to install, super fast to run', '')
cons <- c('hard to install', '', 'slow, hard to install', 'not that accurate', '')

df <- data.frame(assembler = assemblers, genome_size = genome_size, heterozygosity = heterozygosity, pros = pros, cons = cons)
print.mdtable(df[1:4,])
