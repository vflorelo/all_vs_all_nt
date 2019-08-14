Multiple genome comparison using accession numbers
==================================================
In order to use ``all_vs_all_nt.sh`` with accession numbers, you just have to name your fasta files and fasta headers with the corresponding names
```bash
cat genome_order
JF939047.fasta
JQ067084.fasta
JQ067092.fasta
KR537871.fasta
KX129925.fasta
KX898399.fasta

grep \> KX898399.fasta
>KX898399
```

The order in the ``genome_order``  file indicates how the matrix is going to be drawn using ``draw_matrix.sh``
![matrix](../images/accession_matrix.svg)
