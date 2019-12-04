#!/usr/bin/env bash

if [[ "$#" -lt 1 ]]
then
    echo "usage: bash download_reference.sh output.fa [build_id]"
    exit 1
fi

output_file=`readlink -f ${1}`
output_dir=`dirname ${output_file}`
genome_build=${2:-"37"}

if [ ${genome_build} = "37" ]; then
	remote="ftp://ftp.ncbi.nlm.nih.gov/genomes/Homo_sapiens/ARCHIVE/BUILD.37.3/Assembled_chromosomes/seq"
elif [ ${genome_build} = "38" ]; then
    remote=ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.15_GRCh38/GCA_000001405.15_GRCh38_assembly_structure/Primary_Assembly/assembled_chromosomes/FASTA/
else
	echo "Error: Unsupported genome build ${genome_build}, valid values are 37,38"
	exit 1
fi

temp_dir=`mktemp -d -p ${output_dir}`
pushd ${temp_dir}

for chrom in `seq 1 22` X Y
do
    wget ${remote}/chr${chrom}.fna.gz
done

for chrom in `seq 1 22` X Y
do
    echo ">${chrom}" >> ${output_file}
    gunzip -c chr${chrom}.fna.gz | grep -v ">" >> ${output_file}
done

if hash samtools 2>/dev/null; then
    samtools faidx ${output_file}
else
    echo "Warning: unable to locate samtools, reference file was not indexed"
fi

popd
rm -r ${temp_dir}
