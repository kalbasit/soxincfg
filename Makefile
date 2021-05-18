HOST := $(shell hostname)
OS_ID := $(awk -F= '/^ID=/ {print $2}' /etc/os-release)

.PHONY: all
all: build

.PHONY: build
build:
ifeq ($(OS_ID),nixos)
	nix build '.#nixosConfigurations.$(HOST).config.system.build.toplevel'
else
	home-manager build --flake '.#$(HOST)'
endif

.PHONY: test
test:
ifeq ($(OS_ID),nixos)
	sudo nixos-rebuild --flake '.#$(HOST)' test
else
	$(error test is not support on home-manager)
endif

.PHONY: switch
switch:
ifeq ($(OS_ID),nixos)
	sudo nixos-rebuild --flake '.#$(HOST)' switch
else
	home-manager switch --flake '.#$(HOST)'
endif

.PHONY: boot
boot:
ifeq ($(OS_ID),nixos)
	sudo nixos-rebuild --flake '.#$(HOST)' boot
else
	$(error boot is not support on home-manager)
endif
