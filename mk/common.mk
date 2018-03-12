#
# functions and definitions expected to be used my many or all systems
#

# Calculate the basename of the debian build file
DEBIAN_BASENAME = debian.$(DEBIAN_VER).$(DEBIAN_ARCH)
DEBIAN = $(TOP_DIR)/debian/build/$(DEBIAN_BASENAME)

CONFIGDIRS = .
CONFIGDIRS += $(TOP_DIR)/debian-config
export CONFIGDIRS

ifndef PART3_SIZE_MEGS
INITRD_PARTS += $(DEBIAN).lzma
else
SD_PARTS +=  $(DEBIAN).lzma
endif

# Standardised directory names
BUILD = build
TAG = $(BUILD)/tags
BOOT = $(BUILD)/boot

DISK_IMAGE = $(BUILD)/disk.img

# install any packages needed for the builder
build-depends: $(TAG)/build-depends
$(TAG)/build-depends: Makefile
	sudo apt-get -y install $(BUILD_DEPENDS)
	$(call tag,build-depends)

# Rules to go and make the debian installed root
# Note: as this has no local dependency checks, we force it to always
# run the make command, so the debian submodule can do some checks.
.FORCE:
$(DEBIAN).cpio: $(TOP_DIR)/debian/Makefile .FORCE
	$(MAKE) -C $(TOP_DIR)/debian build/$(DEBIAN_BASENAME).cpio CONFIG_DEBIAN_ARCH=$(DEBIAN_ARCH)

# Ensure that the submodule is actually present
$(TOP_DIR)/debian/Makefile:
	git submodule update --init

%.lzma: %.cpio
	lzma <$< >$@

clean:
	rm -rf $(CLEAN_FILES)

reallyclean:
	rm -rf $(BUILD)

define tag
	@echo Touching tag $1
	@mkdir -p $(TAG)
	@touch $(TAG)/$1
endef

