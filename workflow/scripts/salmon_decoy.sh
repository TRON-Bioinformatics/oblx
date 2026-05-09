#!/usr/bin/env bash
# Generate salmon decoy sequences and gentrome fasta.
#
# Usage: salmon_decoy.sh <genome> <transcriptome> <decoys> <gentrome>

set -euo pipefail

if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <genome> <transcriptome> <decoys> <gentrome>" >&2
    exit 1
fi

genome="$1"
transcriptome="$2"
decoys="$3"
gentrome="$4"

# Gathering decoy sequences names
# Sed command works as follow:
# -n       = do not print all lines
# s/ .*//g = Remove anything after spaces. (remove comments)
# s/>//p  = Remove '>' character at the begining of sequence names. Print names.
sed -n 's/ .*//g;s/>//p' "${genome}" >"${decoys}"
cat "${transcriptome}" "${genome}" >"${gentrome}"
