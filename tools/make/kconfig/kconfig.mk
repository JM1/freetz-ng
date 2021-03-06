KCONFIG_VERSION:=v5.9
KCONFIG_SOURCE:=kconfig-$(KCONFIG_VERSION).tar.xz
KCONFIG_SOURCE_SHA256:=b0a49edfd6b31102642122983fa0ccdaa27d20c3357f6912750b1e7c761e9747
KCONFIG_SITE:=git_archive@git://repo.or.cz/linux.git,scripts/basic,scripts/kconfig,scripts/Kbuild.include,scripts/Makefile.build,scripts/Makefile.host,scripts/Makefile.lib,Documentation/kbuild/kconfig-language.rst,Documentation/kbuild/kconfig-macro-language.rst,Documentation/kbuild/kconfig.rst
KCONFIG_DIR:=$(TOOLS_SOURCE_DIR)/kconfig-$(KCONFIG_VERSION)
KCONFIG_MAKE_DIR:=$(TOOLS_DIR)/make/kconfig
KCONFIG_TARGET_DIR:=$(TOOLS_DIR)/config

kconfig-source: $(DL_DIR)/$(KCONFIG_SOURCE)
$(DL_DIR)/$(KCONFIG_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(KCONFIG_SOURCE) $(KCONFIG_SITE) $(KCONFIG_SOURCE_SHA256)

kconfig-unpacked: $(KCONFIG_DIR)/.unpacked
$(KCONFIG_DIR)/.unpacked: $(DL_DIR)/$(KCONFIG_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(KCONFIG_SOURCE)
	$(call APPLY_PATCHES,$(KCONFIG_MAKE_DIR)/patches,$(KCONFIG_DIR))
	$(if $(FREETZ_REAL_DEVELOPER_ONLY__BUTTONS),$(call APPLY_PATCHES,$(KCONFIG_MAKE_DIR)/patches/buttons,$(KCONFIG_DIR)))
	touch $@

$(KCONFIG_DIR)/scripts/kconfig/conf: $(KCONFIG_DIR)/.unpacked
	$(MAKE) -C $(KCONFIG_DIR) config

$(KCONFIG_DIR)/scripts/kconfig/mconf: $(KCONFIG_DIR)/.unpacked
	$(MAKE) -C $(KCONFIG_DIR) menuconfig

$(KCONFIG_TARGET_DIR)/conf: $(KCONFIG_DIR)/scripts/kconfig/conf
	$(INSTALL_FILE)

$(KCONFIG_TARGET_DIR)/mconf: $(KCONFIG_DIR)/scripts/kconfig/mconf
	$(INSTALL_FILE)

kconfig: $(KCONFIG_TARGET_DIR)/conf $(KCONFIG_TARGET_DIR)/mconf

kconfig-clean:
	$(RM) \
		$(KCONFIG_DIR)/scripts/basic/.*.cmd \
		$(KCONFIG_DIR)/scripts/kconfig/.*.cmd \
		$(KCONFIG_DIR)/scripts/kconfig/lxdialog/.*.cmd \
		$(KCONFIG_DIR)/scripts/kconfig/*.o \
		$(KCONFIG_DIR)/scripts/kconfig/lxdialog/*.o \
		$(KCONFIG_DIR)/scripts/kconfig/zconf.*.c \
		$(KCONFIG_DIR)/scripts/basic/fixdep \
		$(KCONFIG_DIR)/scripts/kconfig/conf \
		$(KCONFIG_DIR)/scripts/kconfig/mconf

kconfig-dirclean:
	$(RM) -r $(KCONFIG_DIR)

kconfig-distclean: kconfig-dirclean
	$(RM) $(KCONFIG_TARGET_DIR)/conf $(KCONFIG_TARGET_DIR)/mconf

.PHONY: kconfig-source kconfig-unpacked kconfig kconfig-clean kconfig-dirclean kconfig-distclean
