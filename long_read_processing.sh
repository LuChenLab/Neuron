## 01.basecalling

guppy_basecaller \
  -i /mnt/raid63/NSC/mouse/Nanopore/RawData/SM2cDNA/20201022_1525_MN29097_FAO09193_1a55685f \
  -r -s /mnt/raid63/NSC/mouse/Nanopore/BaseCalled \
  --device cuda:0 \
  -c dna_r9.4.1_450bps_hac.cfg \
  --barcode_kits EXP-NBD104 \
  --trim_barcode \
  --num_callers 8 \
  --gpu_runners_per_device 4 \
  --chunks_per_runner 768 \
  --chunk_size 500

## 02.qc

NanoComp --fastq barcode01.fastq barcode02.fastq barcode03.fastq barcode04.fastq barcode05.fastq \
	--outdir ../../analysis/00.QC/01.NanoComp  \
	--raw --store --tsv_stats


## 03. align to genome

for i in $(ls *fastq|awk -F "." '{print $1}');do
  minimap2 -ax splice \
  /mnt/raid64/ref_genomes/MusMus/release93/minimap_index/Mus_musculus.GRCm38.dna.primary_assembly.mmi ./$i.fastq  \
  | samtools view -Sb | samtools sort > ../01.minimap2/$i.sorted.bam
done


## 04.StringTie  

for i in $(ls *bam |awk -F "." '{print $1}');do
/mnt/raid61/Personal_data/xumengying/soft/stringtie/stringtie    -p 10 \
		-L -v --conservative --rf -G /mnt/raid64/ref_genomes/MusMus/release93/Mus_musculus.GRCm38.93.sorted.gtf \
 		-o ../01.stringTie2/minimap/v2/$i.gtf  ./$i.sorted.bam
done


## 05.compare with gff

for i in $(ls *gtf |awk -F "." '{print $1}');do
	/mnt/raid61/Personal_data/xumengying/soft/gffcompare/gffcompare \
	-r /mnt/raid64/ref_genomes/MusMus/release93/Mus_musculus.GRCm38.93.gtf $i.gtf \
	-o ./gffcompare/$i
done


## 06.suppa2

for i in $(ls *.annotated.gtf |awk -F "." '{print $1}');do
	suppa.py generateEvents \
	-i ./$i.annotated.gtf \
	-o  ../02.SUPP2/minimap/v2/$i \
	-f ioe \
	-e SE SS MX RI FL
done


## 07. visualized transcript 

for i in Sox5 Abat;do
 egrep "\<$i\>"  Mus_musculus.GRCm38.93.gtf|awk -F '\t' '{if($3=="gene") {print $1,":",$4,"-",$5}}'|sed 's/[[:space:]]//g'| xargs -i samtools view -b   ../barcode01.sorted.bam  {} \
 | bedtools bamtobed -bed12 -split \
 | bedToGenePred /dev/stdin /dev/stdout\
 | genePredToGtf  file /dev/stdin   ./${i}_v1/E15_5.${i}.gtf

 egrep "\<$i\>"  Mus_musculus.GRCm38.93.gtf|awk -F '\t' '{if($3=="gene") {print $1,":",$4,"-",$5}}'|sed 's/[[:space:]]//g'| xargs -i samtools view -b   ../barcode02.sorted.bam  {} \
 | bedtools bamtobed -bed12 -split \
 | bedToGenePred /dev/stdin /dev/stdout\
 | genePredToGtf  file /dev/stdin   ./${i}_v1/E17_5.${i}.gtf

 egrep "\<$i\>"  Mus_musculus.GRCm38.93.gtf|awk -F '\t' '{if($3=="gene") {print $1,":",$4,"-",$5}}'|sed 's/[[:space:]]//g'| xargs -i samtools view -b   ../barcode03.sorted.bam  {} \
 | bedtools bamtobed -bed12 -split \
 | bedToGenePred /dev/stdin /dev/stdout\
 | genePredToGtf  file /dev/stdin   ./${i}_v1/P1_5.${i}.gtf

 egrep "\<$i\>"  Mus_musculus.GRCm38.93.gtf|awk -F '\t' '{if($3=="gene") {print $1,":",$4,"-",$5}}'|sed 's/[[:space:]]//g'| xargs -i samtools view -b   ../barcode04.sorted.bam  {} \
 | bedtools bamtobed -bed12 -split \
 | bedToGenePred /dev/stdin /dev/stdout\
 | genePredToGtf  file /dev/stdin   ./${i}_v1/P8.${i}.gtf

 egrep "\<$i\>"  Mus_musculus.GRCm38.93.gtf|awk -F '\t' '{if($3=="gene") {print $1,":",$4,"-",$5}}'|sed 's/[[:space:]]//g'| xargs -i samtools view -b   ../barcode05.sorted.bam  {} \
 | bedtools bamtobed -bed12 -split \
 | bedToGenePred /dev/stdin /dev/stdout\
 | genePredToGtf  file /dev/stdin   ./${i}_v1/zAdult.${i}.gtf

done


## 08. sashimi with NGS data

python /mnt/raid61/Personal_data/zhangyiming/code/pysashimi/main.py  plot -e 16:8608794-8614182:+  \
    -b ./sashimi_meta.txt  \
    -g  /mnt/raid64/ref_genomes/MusMus/release93/Mus_musculus.GRCm38.93.gtf \
    -o ./Abat2_16_8608994-8613982_+_15.pdf \
    --color-factor 3 -t 15 \
    --indicator-lines 8608994,8613982

python /mnt/raid61/Personal_data/zhangyiming/code/pysashimi/main.py  plot -e 6:143873951-143941550:-  \
    -b ./sashimi_meta.txt  \
    -g  /mnt/raid64/ref_genomes/MusMus/release93/Mus_musculus.GRCm38.93.gtf \
    -o ./Sox5_6_143874151-143941350_-_15.pdf  \
    --color-factor 3 -t 15 \
    --indicator-lines 143874151,143941350    

