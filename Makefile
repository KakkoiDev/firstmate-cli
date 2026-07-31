PREFIX ?= $(HOME)/.local/bin

.PHONY: install uninstall

install:
	./install.sh

uninstall:
	rm -f $(PREFIX)/firstmate $(PREFIX)/secondmate
	@echo "Removed $(PREFIX)/firstmate and $(PREFIX)/secondmate"
