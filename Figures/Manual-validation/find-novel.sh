wget -O Panbarlex_disease-resistance https://panbarlex.ipk-gatersleben.de/functional_annotation/search/disease%20resistance/download
awk -F'\t' '$1 == "RGT_PLANET"' Panbarlex_disease-resistance > Panbarlex_RGT_PLANET_disease-resistance.txt

