#!/bin/bash

#things you need: trimmomatic, stringtie, hisat2, samtools
#miniconda might help the installation: https://docs.conda.io/en/latest/miniconda.html


#what this does: for a list of arguments, trims reads, aligns with hisat,converts to bam, runs stringtie on that bam 
#put your own reference fasta in here

#You could also take out the trimmomatic step probably. Just change the hisat -1 and -2 entries below if you do
melpipeline33(){
one=$(basename $1 .fastq.gz)
two=$(basename $2 .fastq.gz)

	trimmomatic PE $1 $2 $one.paired.fq.gz $one.unpaired.fq.gz $two.paired.fq.gz $two.unpaired.fq.gz ILLUMINACLIP:adapter.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:30
	hisat2 -p 8 /ru-auth/local/home/lzhao/Data_store/witt/Genomes/dmel_r6.15_FB2017_02/fasta/dmel-all-chromosome-r6.15 -1 <(gunzip -c $one.paired.fq.gz) -2 <(gunzip -c $two.paired.fq.gz) -S $3.sam
	samtools sort -@ 8 -o $3.bam $3.sam 
	rm $3.sam 
	stringtie -p 8 -G $4 -o $3.gtf -A $3.tsv $3.bam


}


#This looks for fastq files in the current directory and cuts off _1.fastq.gz to gets their basenames. If you're not usi 
rm names*
rm basenames
for i in `ls| grep _1.fastq.gz `
do
echo $i >> names1
echo $(basename $i _1.fastq.gz) >> basenames

done

for i in `ls| grep _2.fastq.gz `
do
echo $i >> names2
done

#this looks through all the basenames in the directory and runs the above pipeline. Replace that GTF with your own.

for i in `cat basenames`
do
one=$(grep $i names1)
two=$(grep $i names2)
echo $one
echo $two
melpipeline33 $one $two $i /ru-auth/local/home/lzhao/Data_store/witt/Genomes/dmel_r6.15_FB2017_02/gtf/dmel-all-r6.15.gtf
done

