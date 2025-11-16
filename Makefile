all: unittest

unittest:
	pytest --tag unittest --git-aware --symlink --stderr-bytes 100000

documentation:
	mkdocs build -f docs/tronmake-genome-lib-builder/mkdocs.yml
