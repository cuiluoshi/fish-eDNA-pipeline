#!/bin/bash
ls ./try |grep fq.gz > file_list.txt;

cat file_list.txt | while read line;

do

    name_array=(${line//./ }) 
    name_file=${name_array[0]}
    num_file=${name_array[2]}
    if [ $num_file == R1 ];then
        echo 'now :'${name_file};
        miniquesize=2
        otu_id=0.97
        zotu_minisize=2
        unoise_alpha=2.0
        thread=10
        if [ -d ./${name_file} ];
        then
            echo 'dir alreadly exis!';
        else
            mkdir ./${name_file};
        fi

		vsearch --fastq_mergepairs ./try/${name_file}.clean.R1.fq.gz  --reverse ./try/${name_file}.clean.R2.fq.gz  --fastqout ./${name_file}/${name_file}.merged.fq  --relabel ${name_file}.
		echo 'Merge Finished';  #双端合并
        new_result_file=./${name_file}/${name_file}.merged.fq;
        vsearch --fastx_uniques ${new_result_file} --minuniquesize ${miniquesize} --fastaout ./${name_file}/${name_file}_derep.fasta
		echo 'Dereplication Finished!';  #去冗余
        new_result_file=./${name_file}/${name_file}_derep.fasta;
		vsearch --cluster_size ${new_result_file}  --centroids ./${name_file}/${name_file}_otus.fasta  --otutabout ./${name_file}/${name_file}_cluster.tsv --id ${otu_id} --relabel OTU_
		echo 'Cluster Finished!';  #聚类
		new_result_file=./${name_file}/${name_file}_otus.fasta;
		vsearch  --uchime_denovo ${new_result_file} --borderline ./${name_file}/${name_file}_borderline.fasta --chimeras ./${name_file}/${name_file}_chimeric.fasta --nonchimeras ./${name_file}/${name_file}_nonchim.fasta
		echo 'Delete Chimeric Finished!';  #去嵌合体
		new_result_file=./${name_file}/${name_file}_nonchim.fasta;
		vsearch -usearch_global ./try/${line}  --db ${new_result_file} --otutabout ./${name_file}/${name_file}_OTUtab.tsv -threads ${thread}  --id ${otu_id} --strand plus
		echo 'otu table Finished!' #生成特征表
    fi

done