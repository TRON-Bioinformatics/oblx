all: unittest

unittest:
	pytest --tag unittest --git-aware --symlink --stderr-bytes 100000
