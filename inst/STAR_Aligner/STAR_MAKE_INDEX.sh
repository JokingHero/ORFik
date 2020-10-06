#!/bin/bash

# HT 12/02/19
# Script to make genome index for species
# 1 make directories
# 2 STAR INDICES
usage(){
cat << EOF
usage: $0 options

Script to make genome index for species

OPTIONS:
	-o	   output folder for all indices
	-c     path to merged contaminants fasta/fasta.gz file. Use instead of individual
	          rRNA, tRNA etc.
	-s   	 species to use (zebrafish, soon human and yeast, only used on cbu UIB)
	-p 	   path to phix fasta/fasta.gz file
	-r	   path to rrna fasta/fasta.gz file
	-n	   path to ncRNA fasta/fasta.gz file
	-t	   path to trna fasta/fasta.gz file
	-f         path to species whole genome fasta/fasta.gz file
	-g         path to species gtf file
	-G         path to use as output for species genome, if other than rest
	-S         path to STAR (default: ~/bin/STAR-2.7.0c/source/STAR)
	-m	   max cpus allowed (defualt 40)
	-h	   this help message
example usage (easy): STAR_MAKE_INDEX.sh -o <out.dir> -s <in.species>

example usage (avanced): STAR_MAKE_INDEX.sh -o <out.dir> -p <in.fasta> -r <in.fasta> -n <in.fasta> -t <in.fasta> -g <in.fasta>

INFO:
To add new species download these 4 files for the species:
1 .GTF, 2. fasta genome, 3. trna (from trnascan) and 4. non coding rnas (from NONCODE)
Then add them to the species list in this script or input directly as arguments
EOF
}
phix=""
rRNA=""
maxCPU=60
STAR=~/bin/STAR-2.7.0c/source/STAR
tRNA=""
ncRNA=""
contamints=""
species=""
genomeGTF=""
genome=""
species=""
while getopts ":o:s:p:r:c:n:t:f:g:G:S:m:h" opt; do
    case $opt in
    s)
	species=$OPTARG
	echo "-s using species: $OPTARG"
	;;
    p)
        phix=$OPTARG
        echo "-p phix path $OPTARG"
	;;
    r)
        rRNA=$OPTARG
        echo "-r path $OPTARG"
	;;
    n)
        ncRNA=$OPTARG
        echo "-n ncRNA path $OPTARG"
	;;
    t)
        tRNA=$OPTARG
        echo "-t trna path $OPTARG"
	;;
    f)
        genome=$OPTARG
        echo "-f fasta genome $OPTARG"
	;;
	  c)
        contamints=$OPTARG
        echo "-c contamints fasta genome $OPTARG"
	;;
    g)
        genomeGTF=$OPTARG
        echo "-f gtf/gff genome $OPTARG"
	;;
    G)
        outGenome=$OPTARG
        echo "-outGenome folder $OPTARG"
	;;

    o)
        out_dir=$OPTARG
        echo "-o output folder $OPTARG"
        ;;
    S)
        STAR=$OPTARG
        echo "-S STAR path $OPTARG"
        ;;
    m)
	maxCPU=$OPTARG
	echo "-m maxCPU: $OPTARG"
        ;;
    h)
        usage
        exit
        ;;
    ?)
        echo "Invalid option: -$OPTARG"
        usage
        exit 1
        ;;
    esac
done

if [ $genome == "" ]; then
		echo "Genome fasta file not specified;"
		#exit 1
fi
if [ $genomeGTF == "" ]; then
	echo "Genome gtf/gff file not specified;"
	#exit 1
fi


# 1. mkdir
mainGenomeOut=${out_dir}/genomeDir
if [ ! -z "$G" ]; then
      mainGenomeOut=${outGenome}
fi


if [ ! -d $out_dir ]; then
    mkdir $out_dir
fi

if [ ! -d ${out_dir}/PhiX_genomeDir ]; then
  if [ $phix != "" ]; then
        mkdir ${out_dir}/PhiX_genomeDir
  fi
fi

if [ ! -d ${out_dir}/rRNA_genomeDir ]; then
  if [ $rRNA != "" ]; then
        mkdir ${out_dir}/rRNA_genomeDir
  fi
fi

if [ ! -d ${out_dir}/ncRNA_genomeDir ]; then
  if [ $ncRNA != "" ]; then
        mkdir ${out_dir}/ncRNA_genomeDir
  fi
fi

if [ ! -d ${out_dir}/tRNA_genomeDir ]; then
  if [ $tRNA != "" ]; then
        mkdir ${out_dir}/tRNA_genomeDir
  fi
fi

if [ ! -d ${out_dir}/contaminants_genomeDir ]; then
  if [ $contamints != "" ]; then
        mkdir ${out_dir}/contaminants_genomeDir
  fi
fi

if [ ! -d ${out_dir}/genomeDir ]; then
        mkdir ${out_dir}/genomeDir
fi

# 1: currently used cores, 2: max cores
function nCores()
{
	if (( $1 > $2 )); then
		echo $2
	else
		echo $1
	fi
}

#################### 2. make all star indices given #############################

# genome (--sjdbOverhang 72, 76-3(trim) - 1)
if [ ${genome} != "" ]; then
	echo ""; echo "Main genome index:"
	eval $STAR \
	--runMode genomeGenerate \
	--genomeFastaFiles ${genome} \
	--sjdbGTFfile ${genomeGTF} \
	--genomeDir ${mainGenomeOut} \
	--runThreadN $(nCores $maxCPU 80) \
	--sjdbOverhang 72 \
	--limitGenomeGenerateRAM 30000000000
fi
# contaminants
if [ $contamints != "" ]; then
	echo ""; echo "contamints index:"
	eval $STAR \
	--runMode genomeGenerate \
	--genomeFastaFiles ${$contamints} \
	--genomeDir ${out_dir}/contaminants_genomeDir \
	--runThreadN $(nCores $maxCPU 40) \
	--limitGenomeGenerateRAM 300000000000 \
	--genomeChrBinNbits 11 # TODO Switch to 15? no dont think so from calculation
fi

# phix (--genomeSAindexNbases 5 for small genome)
if [ $phix != "" ]; then
	echo ""; echo "phix index:"
	eval $STAR \
	--runMode genomeGenerate \
	--genomeFastaFiles ${phix} \
	--genomeDir ${out_dir}/PhiX_genomeDir \
	--runThreadN $(nCores $maxCPU 40) \
	--limitGenomeGenerateRAM 80000000 \
	--genomeSAindexNbases 2
fi

# rrna (checked --genomeChrBinNbits log2(2462064000/1641376) for many sequences)
if [ $rRNA != "" ]; then
	echo ""; echo "rRNA index:"
	eval $STAR \
	--runMode genomeGenerate \
	--genomeFastaFiles ${rRNA} \
	--genomeDir ${out_dir}/rRNA_genomeDir \
	--runThreadN $(nCores $maxCPU 40) \
	--limitGenomeGenerateRAM 300000000000 \
	--genomeChrBinNbits 11 # TODO Switch to 15? no dont think so from calculation
fi
# ncRNA (small genome 5)
if [ $ncRNA != "" ]; then
	echo ""; echo "ncRNA index:"
	eval $STAR \
	--runMode genomeGenerate \
	--genomeFastaFiles ${ncRNA} \
	--genomeDir ${out_dir}/ncRNA_genomeDir \
	--runThreadN $(nCores $maxCPU 40) \
	--limitGenomeGenerateRAM 300000000000 \
	--genomeSAindexNbases 5
fi
# trna (mix of both, many sequences and small genome)
# Check SA index size is valid
if [ $tRNA != "" ]; then
	echo ""; echo "tRNA index:"
	SA=6
	size=($(wc -m $tRNA))
	if [ "100000" -gt "$size" ]; then
		if [ "90000" -gt "$size" ]; then
			SA=4
		else
			SA=5
		fi
	fi

	eval $STAR \
	--runMode genomeGenerate \
	--genomeFastaFiles $tRNA \
	--genomeDir ${out_dir}/tRNA_genomeDir \
	--runThreadN $(nCores $maxCPU 40) \
	--limitGenomeGenerateRAM 10000000000 \
	--genomeSAindexNbases $SA \
	--genomeChrBinNbits 11
fi
