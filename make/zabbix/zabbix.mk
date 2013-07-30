$(call PKG_INIT_BIN, 2.0.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=f7261987731dd74b58cb1da890655ddc
$(PKG)_SITE:=@SF/$(pkg)

# sender & get should actually be installed to 'bin' and not 'sbin'... but in order to simplify the Makefile we install them all to 'sbin'
$(PKG)_BINARIES_ALL           :=            agentd            server             proxy             sender             get
$(PKG)_BINARIES_BUILD_SUBDIRS := src/zabbix_agent/ src/zabbix_server/ src/zabbix_proxy/ src/zabbix_sender/ src/zabbix_get/

$(PKG)_BINARIES               := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR     := $(addprefix $($(PKG)_DIR)/,$(join $($(PKG)_BINARIES_BUILD_SUBDIRS),$($(PKG)_BINARIES_ALL:%=zabbix_%)))
$(PKG)_BINARIES_TARGET_DIR    := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/zabbix_%)
$(PKG)_NOT_INCLUDED           := $(addprefix $($(PKG)_DEST_DIR)/usr/sbin/zabbix_,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))
$(PKG)_CATEGORY:=Unstable

$(PKG)_DEPENDS_ON += sqlite
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += libiconv
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

# add EXTRA_(C|LD)FLAGS
$(PKG)_CONFIGURE_PRE_CMDS += find $(abspath $($(PKG)_DIR)) -name Makefile.in -type f -exec $(SED) -i -r -e 's,^(C|LD)FLAGS[ \t]*=[ \t]*@\1FLAGS@,& $$$$(EXTRA_\1FLAGS),' \{\} \+;

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += --disable-java
$(PKG)_CONFIGURE_OPTIONS += --enable-agent
$(PKG)_CONFIGURE_OPTIONS += --enable-server
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite3="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --enable-proxy

$(PKG)_MAKE_FLAGS := ARCH=linux
$(PKG)_MAKE_FLAGS += AR="$(TARGET_AR)"
$(PKG)_MAKE_FLAGS += RANLIB="$(TARGET_RANLIB)"
$(PKG)_MAKE_FLAGS += EXTRA_CFLAGS="-ffunction-sections -fdata-sections"
$(PKG)_MAKE_FLAGS += EXTRA_LDFLAGS="-Wl,--gc-sections"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ZABBIX_DIR) $(ZABBIX_MAKE_FLAGS)

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ZABBIX_DIR) clean
	-$(RM) $(ZABBIX_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(ZABBIX_DEST_DIR)/usr/sbin/zabbix_*

$(PKG_FINISH)
