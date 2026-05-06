all: unittest

unittest:
	pytest --tag unittest

documentation:
	mkdocs build -f docs/tronmake-genome-lib-builder/mkdocs.yml
