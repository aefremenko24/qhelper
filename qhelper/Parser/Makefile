.PHONY: setup clean

PIP := /usr/local/bin/python3.11 -m pip
REQ_FILE := requirements.txt

setup: $(REQ_FILE)
	@echo "Setting up the Python environment..."
	$(PIP) install -r $(REQ_FILE) --user
	chmod 755 parser.py

	rm -rf __pycache__ *.pyc
clean:
	@echo "Cleaning up...
