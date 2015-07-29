SQUASHFS2_HOST_VERSION:=2.2-r2
SQUASHFS2_HOST_SOURCE:=squashfs$(SQUASHFS2_HOST_VERSION).tar.gz
SQUASHFS2_HOST_SOURCE_MD5:=a8d09a217240127ae4d339e8368d2de1
SQUASHFS2_HOST_SITE:=@SF/squashfs

SQUASHFS2_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/squashfs2-host
SQUASHFS2_HOST_DIR:=$(TOOLS_SOURCE_DIR)/squashfs$(SQUASHFS2_HOST_VERSION)
SQUASHFS2_HOST_BUILD_DIR:=$(SQUASHFS2_HOST_DIR)/squashfs-tools

SQUASHFS2_HOST_TOOLS:=mksquashfs
SQUASHFS2_HOST_TOOLS_BUILD_DIR:=$(SQUASHFS2_HOST_TOOLS:%=$(SQUASHFS2_HOST_BUILD_DIR)/%-lzma)
SQUASHFS2_HOST_TOOLS_TARGET_DIR:=$(SQUASHFS2_HOST_TOOLS:%=$(TOOLS_DIR)/%2-lzma)

squashfs2-host-source: $(DL_DIR)/$(SQUASHFS2_HOST_SOURCE)
$(DL_DIR)/$(SQUASHFS2_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SQUASHFS2_HOST_SOURCE) $(SQUASHFS2_HOST_SITE) $(SQUASHFS2_HOST_SOURCE_MD5)

squashfs2-host-unpacked: $(SQUASHFS2_HOST_DIR)/.unpacked
$(SQUASHFS2_HOST_DIR)/.unpacked: $(DL_DIR)/$(SQUASHFS2_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SQUASHFS2_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(SQUASHFS2_HOST_MAKE_DIR)/patches,$(SQUASHFS2_HOST_DIR))
	touch $@

$(SQUASHFS2_HOST_TOOLS_BUILD_DIR): $(SQUASHFS2_HOST_DIR)/.unpacked $(LZMA1_HOST_DIR)/liblzma1++.a
	$(MAKE) -C $(SQUASHFS2_HOST_BUILD_DIR) \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		LZMA_LIBNAME=lzma1++ \
		LZMA_DIR="$(abspath $(LZMA1_HOST_DIR))" \
		$(SQUASHFS2_HOST_TOOLS:%=%-lzma)
	touch -c $@

$(SQUASHFS2_HOST_TOOLS_TARGET_DIR): $(TOOLS_DIR)/%2-lzma: $(SQUASHFS2_HOST_BUILD_DIR)/%-lzma
	$(INSTALL_FILE)
	strip $@

squashfs2-host: $(SQUASHFS2_HOST_TOOLS_TARGET_DIR)

squashfs2-host-clean:
	-$(MAKE) -C $(SQUASHFS2_HOST_BUILD_DIR) clean

squashfs2-host-dirclean:
	$(RM) -r $(SQUASHFS2_HOST_DIR)

squashfs2-host-distclean: squashfs2-host-dirclean
	$(RM) $(SQUASHFS2_HOST_TOOLS_TARGET_DIR)