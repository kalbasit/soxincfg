HOST := $(shell hostname)
OS_ID := $(awk -F= '/^ID=/ {print $2}' /etc/os-release) # debian or nixos or others...

.PHONY: all
all: build

.PHONY: build
build:
ifeq ($(OS_ID),nixos)
	nix build '.#nixosConfigurations.$(HOST).config.system.build.toplevel' --show-trace
else
	home-manager build --flake '.#$(HOST)' --show-trace
endif

.PHONY: test
test:
ifeq ($(OS_ID),nixos)
	sudo nixos-rebuild --flake '.#$(HOST)' test --show-trace
else
	$(error test is not support on home-manager)
endif

.PHONY: switch
switch:
ifeq ($(OS_ID),nixos)
	sudo nixos-rebuild --flake '.#$(HOST)' switch --show-trace
else
	home-manager switch --flake '.#$(HOST)'
endif

.PHONY: boot
boot:
ifeq ($(OS_ID),nixos)
	sudo nixos-rebuild --flake '.#$(HOST)' boot --show-trace
else
	$(error boot is not support on home-manager)
endif
