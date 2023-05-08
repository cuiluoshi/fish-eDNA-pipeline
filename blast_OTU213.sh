#!/bin/bash

cat file_list.txt | while read line;

do
    name_array=(${line//./ }) 
    file_path=./${name_array[0]}/${name_array[0]}
    echo 'now :'${name_array[0]};

    num_file=${name_array[2]}
    if [ $num_file == R1 ];then

        filename=${file_path}_nonchim.fasta
        outfmt=6
        evalue=1e-5
        alinum=5

        #blast use MitoFish
        name_db='complete_partial_mitogenomes'

        outname=${file_path}_blast_mitofish.tsv
        database='mitogenomes.db'

        if [ -f ./${database}.ndb ];
        then
            echo 'MitoFish database is OK!';
        else
        
            if [ ! -f ./${name_db}.fa  ];
            then
                unzip ${name_db}.zip
                echo 'unzip database fasta OK!'
            else
                echo 'database fasta already unzip'
            fi
            
            makeblastdb -in ${name_db}.fa  -dbtype nucl -parse_seqids -out ${database}
            echo 'make MitoFish database OK!';
        fi

        blastn -query ${filename} -out ${outname} -db ${database}  -outfmt ${outfmt}  -evalue ${evalue} -num_alignments ${alinum}

        echo ${database}' blast finish'

    
    fi
    

done

