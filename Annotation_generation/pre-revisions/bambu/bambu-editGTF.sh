#!/bin/bash
awk -F'\t' '{
    $9 = gensub(/(transcript_id "[^"]+"); (gene_id "[^"]+");/, "\\2; \\1;", 1, $9);
    print
}' OFS='\t' RGT_Planet_v2.gtf > RGT_Planet_v2_bambu.gtf
