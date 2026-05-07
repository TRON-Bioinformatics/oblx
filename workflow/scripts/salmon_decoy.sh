# This script is based on snakemake salmon decoy wrapper.

# Gathering decoy sequences names
# Sed command works as follow:
# -n       = do not print all lines
# s/ .*//g = Remove anything after spaces. (remove comments)
# s/>//p  = Remove '>' character at the begining of sequence names. Print names.
sed -n 's/ .*//g;s/>//p' ${snakemake_input[genome]} >${snakemake_output[decoys]} 2>${snakemake_log[0]}
cat ${snakemake_input[transcriptome]} ${snakemake_input[genome]} >${snakemake_output[gentrome]} 2>>${snakemake_log[0]}
