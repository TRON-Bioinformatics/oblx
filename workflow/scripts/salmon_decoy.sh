#!/usr/bin/env bash
# Generate salmon decoy sequences and gentrome fasta.
#
# Usage: salmon_decoy.sh <genome> <transcriptome> <decoys> <gentrome> [log_file]

set -euo pipefail

if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <genome> <transcriptome> <decoys> <gentrome> [log_file]" >&2
    exit 1
fi

genome="$1"
transcriptome="$2"
decoys="$3"
gentrome="$4"
log_file="${5:-/dev/stderr}"

# Gathering decoy sequences names
# Sed command works as follow:
# -n       = do not print all lines
# s/ .*//g = Remove anything after spaces. (remove comments)
# s/>//p  = Remove '>' character at the begining of sequence names. Print names.
sed -n 's/ .*//g;s/>//p' "${genome}" >"${decoys}" 2>"${log_file}"
cat "${transcriptome}" "${genome}" >"${gentrome}" 2>>"${log_file}"
