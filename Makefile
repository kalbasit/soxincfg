HOST := $(shell hostname)

.PHONY: all
all: build

.PHONY: build
build:
	nixos-rebuild --flake '.#$(HOST)' build

.PHONY: test
test:
	sudo nixos-rebuild --flake '.#$(HOST)' test

.PHONY: switch
switch:
	sudo nixos-rebuild --flake '.#$(HOST)' switch

.PHONY: boot
boot:
	sudo nixos-rebuild --flake '.#$(HOST)' boot
