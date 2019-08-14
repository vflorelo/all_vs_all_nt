All versus All
==============
--------------
Overview
--------
Phage comparative genomics often involves alignment of several genomes at the nucleotide sequence level.
While this task is far from trivial, it can be simplified by using matrices.
Here we present two scripts that perform nucleotide comparisons using [MUMmer 4](https://github.com/mummer4/mummer).
The main script parses the MUMmer output and constructs matrices showing percent identities among the compared phage genomes, normalized against different values in order to explore the contributions of insertions/deletions to the genome alignments (without actually *seeing* the alignment).
* First it computes the sum of the aligned lengths between pairs of genomes, adjusting a partial score taking into account the local percent identity observed in each alignment.
* The score is then normalized against five different values for different purposes
  1. Against the shortest phage genome
  * This is the most inclusive setting, it is useful when the researcher is trying to infer distant relationships among the compared genomes (*i.e.* phages of different groups)
  2. Against the longest phage genome
	* This is the most strict setting, it is useful when the researcher is trying to detect differences among the compared genomes (*i.e.* phages of the same group)
	3. Against the length of the query genome
  4. Against the length of the subject genome
	* These settings are complementary to each other, when two same comparisons are significantly different, it might be a consequence of extensive insertions/deletions in one of the genomes (usually the longest). Caveat: If two phages are of similar lengths but present insertions/deletions in both genomes but in different positions, the percent identity drops.
  5. Against the average length
  * This is the most common setting, it is useful for a quick exploration of the relationships of the compared phages.

**Installation**:
-----------------

Simpy put the scripts ``all_vs_all_nt.sh`` and ``draw_matrix.sh`` somewhere in your ``$PATH`` and give them execution permissions:
```bash
chmod 775 all_vs_all_nt.sh draw_matrix.sh
```

MUMmer 4 must also be installed and available in your ``$PATH``

For editing purposes, the font [Source Code Pro](https://fonts.google.com/specimen/Source+Code+Pro) should be installed in your system.

**Usage**:
----------
* Sequences are expected to be in the fasta format, and a file of filenames is expected to perform the genome comparisons in a specified order.
  * Naming convention: fasta files containing just the accession number are preferred, however, for displaying purposes, the researcher could use a short description such as ``>NC_041953_Pseudomonas_phage_PaMx25``. For aesthetic purposes, one has to chose between those two, despite they're compatible. Whitespaces and special characters are not allowed.
* A break length value is expected in order to fine tune the MUMmer comparisons (see MUMmer [documentation](https://github.com/mummer4/mummer/blob/master/docs/nucmer.README) )
  * As a general rule, higher values give more relaxed comparisons, however prone to overestimating the similarity between 2 genomes. On the other hand, lower values give stricter comparisons but might lose some relationships. A value of 120 is used as default
* **Important caveat**: Genomes with high contents of repetitive sequences could potentially give similarity percents greater than 100%, in this case, it is recommended to either use lower break length values or use repeat-masked sequences. Future versions might use minimap2 to avoid this cases.
* Two types of examples are provided:
  * Multiple comparisons where accession numbers are used ([link](accessions))
  * Multiple comparisons where phage names are used ([link](full_names))

The most basic syntax is this, in which all_versus_all_nt.sh search for the genome files specified in the genome_order and outputs five matrices in the tsv format (excel compatible)
```bash
all_versus_all_nt.sh genome_order 60
```
But a tsv file is just as useful as a plain table, in order to get more from your comparisons, we can color code the matrix showing more similar genomes in green and less similar genomes in red, by using ``draw_matrix.sh`` which reads the tsv file and draws a picture of the matrix in the svg format that allows further customisation and annotation by using vector graphics software such as [Inkscape](https://inkscape.org) or [Adobe Illustrator](https://www.adobe.com/products/illustrator.html).

```bash
draw_matrix.sh average_matrix.tsv
```
