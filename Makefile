.PHONY : docs
docs :
	rm -rf docs/build/
	sphinx-autobuild -b html --watch mingaleg_lib/ docs/source/ docs/build/

.PHONY : fix-checks
fix-checks :
	isort .
	black .
	ruff check --fix .
	mypy mingaleg_lib/ tests/
	CUDA_VISIBLE_DEVICES='' pytest -v --color=yes --doctest-modules tests/ mingaleg_lib/

.PHONY : run-checks
run-checks :
	isort --check .
	black --check .
	ruff check .
	mypy mingaleg_lib/ tests/
	CUDA_VISIBLE_DEVICES='' pytest -v --color=yes --doctest-modules tests/ mingaleg_lib/

.PHONY : build
build :
	rm -rf *.egg-info/
	python -m build
