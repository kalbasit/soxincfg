.PHONY: all
all: build

.PHONY: build
build:
	nixos-rebuild --flake '.#$(shell hostname)' build

.PHONY: test
test:
	sudo nixos-rebuild --flake '.#$(shell hostname)' test

.PHONY: switch
switch:
	sudo nixos-rebuild --flake '.#$(shell hostname)' switch

.PHONY: boot
boot:
	sudo nixos-rebuild --flake '.#$(shell hostname)' boot
