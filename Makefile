# List all targets with 'make list'
SRCDIR   := $(abspath $(lastword $(MAKEFILE_LIST))/..)
FONTDIR  := build/fonts
UFODIR   := build/ufo
BIN      := $(SRCDIR)/build/venv/bin
TOOLS    := $(SRCDIR)/inter/misc/tools
MAKEFILE := $(lastword $(MAKEFILE_LIST))
FAMILY   := Lolcat
DSPACE   := $(UFODIR)/$(FAMILY)Inter.designspace

export PATH := $(BIN):$(PATH)

default: all

# ---------------------------------------------------------------------------------
# intermediate sources

$(UFODIR)/$(FAMILY)Inter.glyphs: $(FAMILY)Inter.glyphspackage | $(UFODIR)
	$(BIN)/python3 build/venv/bin/glyphspkg -o $(dir $@) $^

# features
inter/src/features: $(wildcard inter/src/features/*)
	@touch "$@"
	@true
$(UFODIR)/features: inter/features
	@mkdir -p $(UFODIR)
	@ln -sf ../../inter/src/features $(UFODIR)/features

$(UFODIR)/%.designspace: $(UFODIR)/%.glyphs $(UFODIR)/features
	$(BIN)/fontmake -o ufo -g $< --designspace-path $@ \
		--master-dir $(UFODIR) --instance-dir $(UFODIR)
	$(BIN)/python3 $(TOOLS)/postprocess-designspace.py $@

# master UFOs are byproducts of building Inter.designspace
$(UFODIR)/$(FAMILY)-Black.ufo:       $(DSPACE)
	touch $@
$(UFODIR)/$(FAMILY)-BlackItalic.ufo: $(DSPACE)
	touch $@
$(UFODIR)/$(FAMILY)-Regular.ufo:     $(DSPACE)
	touch $@
$(UFODIR)/$(FAMILY)-Italic.ufo:      $(DSPACE)
	touch $@
$(UFODIR)/$(FAMILY)-Thin.ufo:        $(DSPACE)
	touch $@
$(UFODIR)/$(FAMILY)-ThinItalic.ufo:  $(DSPACE)
	touch $@

# instance UFOs are generated on demand
$(UFODIR)/$(FAMILY)-Light.ufo:            $(DSPACE)
	$(BIN)/fontmake -o ufo -m $< --output-path $@ -i "$(FAMILY) Light"
$(UFODIR)/$(FAMILY)-LightItalic.ufo:      $(DSPACE)
	$(BIN)/fontmake -o ufo -m $< --output-path $@ -i "$(FAMILY) Light Italic"
$(UFODIR)/$(FAMILY)-ExtraLight.ufo:       $(DSPACE)
	$(BIN)/fontmake -o ufo -m $< --output-path $@ -i "$(FAMILY) Extra Light"
$(UFODIR)/$(FAMILY)-ExtraLightItalic.ufo: $(DSPACE)
	$(BIN)/fontmake -o ufo -m $< --output-path $@ -i "$(FAMILY) Extra Light Italic"
$(UFODIR)/$(FAMILY)-Medium.ufo:           $(DSPACE)
	$(BIN)/fontmake -o ufo -m $< --output-path $@ -i "$(FAMILY) Medium"
$(UFODIR)/$(FAMILY)-MediumItalic.ufo:     $(DSPACE)
	$(BIN)/fontmake -o ufo -m $< --output-path $@ -i "$(FAMILY) Medium Italic"
$(UFODIR)/$(FAMILY)-SemiBold.ufo:         $(DSPACE)
	$(BIN)/fontmake -o ufo -m $< --output-path $@ -i "$(FAMILY) Semi Bold"
$(UFODIR)/$(FAMILY)-SemiBoldItalic.ufo:   $(DSPACE)
	$(BIN)/fontmake -o ufo -m $< --output-path $@ -i "$(FAMILY) Semi Bold Italic"
$(UFODIR)/$(FAMILY)-Bold.ufo:             $(DSPACE)
	$(BIN)/fontmake -o ufo -m $< --output-path $@ -i "$(FAMILY) Bold"
$(UFODIR)/$(FAMILY)-BoldItalic.ufo:       $(DSPACE)
	$(BIN)/fontmake -o ufo -m $< --output-path $@ -i "$(FAMILY) Bold Italic"
$(UFODIR)/$(FAMILY)-ExtraBold.ufo:        $(DSPACE)
	$(BIN)/fontmake -o ufo -m $< --output-path $@ -i "$(FAMILY) Extra Bold"
$(UFODIR)/$(FAMILY)-ExtraBoldItalic.ufo:  $(DSPACE)
	$(BIN)/fontmake -o ufo -m $< --output-path $@ -i "$(FAMILY) Extra Bold Italic"

# make sure intermediate files are not gc'd by make
.PRECIOUS: \
	$(UFODIR)/$(FAMILY)-Black.ufo \
	$(UFODIR)/$(FAMILY)-BlackItalic.ufo \
	$(UFODIR)/$(FAMILY)-Regular.ufo \
	$(UFODIR)/$(FAMILY)-Italic.ufo \
	$(UFODIR)/$(FAMILY)-Thin.ufo \
	$(UFODIR)/$(FAMILY)-ThinItalic.ufo \
	$(UFODIR)/$(FAMILY)-Light.ufo \
	$(UFODIR)/$(FAMILY)-LightItalic.ufo \
	$(UFODIR)/$(FAMILY)-ExtraLight.ufo \
	$(UFODIR)/$(FAMILY)-ExtraLightItalic.ufo \
	$(UFODIR)/$(FAMILY)-Medium.ufo \
	$(UFODIR)/$(FAMILY)-MediumItalic.ufo \
	$(UFODIR)/$(FAMILY)-SemiBold.ufo \
	$(UFODIR)/$(FAMILY)-SemiBoldItalic.ufo \
	$(UFODIR)/$(FAMILY)-Bold.ufo \
	$(UFODIR)/$(FAMILY)-BoldItalic.ufo \
	$(UFODIR)/$(FAMILY)-ExtraBold.ufo \
	$(UFODIR)/$(FAMILY)-ExtraBoldItalic.ufo \
	$(DSPACE)

# ---------------------------------------------------------------------------------
# products

$(FONTDIR)/static/%.otf: $(UFODIR)/%.ufo | $(FONTDIR)/static
	$(BIN)/fontmake -u $< -o otf --output-path $@ \
	--overlaps-backend pathops --production-names

$(FONTDIR)/static/%.ttf: $(UFODIR)/%.ufo | $(FONTDIR)/static
	$(BIN)/fontmake -u $< -o ttf --output-path $@ \
	--overlaps-backend pathops --production-names

$(FONTDIR)/static-hinted/%.ttf: $(FONTDIR)/static/%.ttf | $(FONTDIR)/static-hinted
	$(BIN)/python3 $(PWD)/build/venv/lib/python/site-packages/ttfautohint \
		--no-info "$<" "$@"

$(FONTDIR)/var/%.var.ttf: $(DSPACE) | $(FONTDIR)/var
	$(BIN)/fontmake -o variable -m $(DSPACE) --output-path $@ \
		--overlaps-backend pathops --production-names
	$(BIN)/python3 $(TOOLS)/postprocess-vf.py $@
# 	$(BIN)/gftools fix-unwanted-tables -t MVAR $@

$(FONTDIR)/var/%.var.otf: $(DSPACE) | $(FONTDIR)/var
	$(BIN)/fontmake -o variable-cff2 -m $(DSPACE) --output-path $@ \
		--overlaps-backend pathops --production-names

%.woff2: %.ttf
	$(BIN)/woff2_compress "$<"

$(FONTDIR)/static:
	mkdir -p $@
$(FONTDIR)/static-hinted:
	mkdir -p $@
$(FONTDIR)/var:
	mkdir -p $@
$(UFODIR):
	mkdir -p $@

static_otf: \
	$(FONTDIR)/static/$(FAMILY)-Black.otf \
	$(FONTDIR)/static/$(FAMILY)-BlackItalic.otf \
	$(FONTDIR)/static/$(FAMILY)-Regular.otf \
	$(FONTDIR)/static/$(FAMILY)-Italic.otf \
	$(FONTDIR)/static/$(FAMILY)-Thin.otf \
	$(FONTDIR)/static/$(FAMILY)-ThinItalic.otf \
	$(FONTDIR)/static/$(FAMILY)-Light.otf \
	$(FONTDIR)/static/$(FAMILY)-LightItalic.otf \
	$(FONTDIR)/static/$(FAMILY)-ExtraLight.otf \
	$(FONTDIR)/static/$(FAMILY)-ExtraLightItalic.otf \
	$(FONTDIR)/static/$(FAMILY)-Medium.otf \
	$(FONTDIR)/static/$(FAMILY)-MediumItalic.otf \
	$(FONTDIR)/static/$(FAMILY)-SemiBold.otf \
	$(FONTDIR)/static/$(FAMILY)-SemiBoldItalic.otf \
	$(FONTDIR)/static/$(FAMILY)-Bold.otf \
	$(FONTDIR)/static/$(FAMILY)-BoldItalic.otf \
	$(FONTDIR)/static/$(FAMILY)-ExtraBold.otf \
	$(FONTDIR)/static/$(FAMILY)-ExtraBoldItalic.otf

static_ttf: \
	$(FONTDIR)/static/$(FAMILY)-Black.ttf \
	$(FONTDIR)/static/$(FAMILY)-BlackItalic.ttf \
	$(FONTDIR)/static/$(FAMILY)-Regular.ttf \
	$(FONTDIR)/static/$(FAMILY)-Italic.ttf \
	$(FONTDIR)/static/$(FAMILY)-Thin.ttf \
	$(FONTDIR)/static/$(FAMILY)-ThinItalic.ttf \
	$(FONTDIR)/static/$(FAMILY)-Light.ttf \
	$(FONTDIR)/static/$(FAMILY)-LightItalic.ttf \
	$(FONTDIR)/static/$(FAMILY)-ExtraLight.ttf \
	$(FONTDIR)/static/$(FAMILY)-ExtraLightItalic.ttf \
	$(FONTDIR)/static/$(FAMILY)-Medium.ttf \
	$(FONTDIR)/static/$(FAMILY)-MediumItalic.ttf \
	$(FONTDIR)/static/$(FAMILY)-SemiBold.ttf \
	$(FONTDIR)/static/$(FAMILY)-SemiBoldItalic.ttf \
	$(FONTDIR)/static/$(FAMILY)-Bold.ttf \
	$(FONTDIR)/static/$(FAMILY)-BoldItalic.ttf \
	$(FONTDIR)/static/$(FAMILY)-ExtraBold.ttf \
	$(FONTDIR)/static/$(FAMILY)-ExtraBoldItalic.ttf

static_ttf_hinted: \
	$(FONTDIR)/static-hinted/$(FAMILY)-Black.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-BlackItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-Regular.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-Italic.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-Thin.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-ThinItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-Light.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-LightItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-ExtraLight.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-ExtraLightItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-Medium.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-MediumItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-SemiBold.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-SemiBoldItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-Bold.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-BoldItalic.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-ExtraBold.ttf \
	$(FONTDIR)/static-hinted/$(FAMILY)-ExtraBoldItalic.ttf

static_web: \
	$(FONTDIR)/static/$(FAMILY)-Black.woff2 \
	$(FONTDIR)/static/$(FAMILY)-BlackItalic.woff2 \
	$(FONTDIR)/static/$(FAMILY)-Regular.woff2 \
	$(FONTDIR)/static/$(FAMILY)-Italic.woff2 \
	$(FONTDIR)/static/$(FAMILY)-Thin.woff2 \
	$(FONTDIR)/static/$(FAMILY)-ThinItalic.woff2 \
	$(FONTDIR)/static/$(FAMILY)-Light.woff2 \
	$(FONTDIR)/static/$(FAMILY)-LightItalic.woff2 \
	$(FONTDIR)/static/$(FAMILY)-ExtraLight.woff2 \
	$(FONTDIR)/static/$(FAMILY)-ExtraLightItalic.woff2 \
	$(FONTDIR)/static/$(FAMILY)-Medium.woff2 \
	$(FONTDIR)/static/$(FAMILY)-MediumItalic.woff2 \
	$(FONTDIR)/static/$(FAMILY)-SemiBold.woff2 \
	$(FONTDIR)/static/$(FAMILY)-SemiBoldItalic.woff2 \
	$(FONTDIR)/static/$(FAMILY)-Bold.woff2 \
	$(FONTDIR)/static/$(FAMILY)-BoldItalic.woff2 \
	$(FONTDIR)/static/$(FAMILY)-ExtraBold.woff2 \
	$(FONTDIR)/static/$(FAMILY)-ExtraBoldItalic.woff2

static_web_hinted: \
	$(FONTDIR)/static-hinted/$(FAMILY)-Black.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-BlackItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-Regular.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-Italic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-Thin.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-ThinItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-Light.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-LightItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-ExtraLight.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-ExtraLightItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-Medium.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-MediumItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-SemiBold.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-SemiBoldItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-Bold.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-BoldItalic.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-ExtraBold.woff2 \
	$(FONTDIR)/static-hinted/$(FAMILY)-ExtraBoldItalic.woff2

var:     $(FONTDIR)/var/$(FAMILY).var.ttf
var_web: $(FONTDIR)/var/$(FAMILY).var.woff2

all:        static_otf static_ttf static_ttf_hinted static_web static_web_hinted \
            var var_web var_no_slnt_axis

.PHONY: all static_otf static_ttf static_ttf_hinted static_web static_web_hinted \
            var var_web var_no_slnt_axis

# ---------------------------------------------------------------------------------
# testing

test: build/fontbakery-report-var.txt \
      build/fontbakery-report-static.txt

# FBAKE_ARGS are common args for all fontbakery targets
FBAKE_ARGS := check-universal \
              --no-colors \
              --no-progress \
              --loglevel WARN \
              --succinct \
              --full-lists \
              -j \
              -x com.google.fonts/check/family/win_ascent_and_descent

build/fontbakery-report-var.txt: $(FONTDIR)/var/$(FAMILY).var.ttf
	@echo "fontbakery $(FAMILY).var.ttf > $(@) ..."
	@$(BIN)/fontbakery \
		$(FBAKE_ARGS) -x com.google.fonts/check/STAT_strings \
		$^ > $@ \
		|| (cat $@; echo "report at $@"; touch -m -t 199001010000 $@; exit 1)

build/fontbakery-report-static.txt: $(wildcard $(FONTDIR)/static/$(FAMILY)-*.otf)
	@echo "fontbakery static/$(FAMILY)-*.otf > $(@) ..."
	@$(BIN)/fontbakery \
		$(FBAKE_ARGS) -x com.google.fonts/check/family/underline_thickness \
		$^ > $@ \
		|| (cat $@; echo "report at $@"; touch -m -t 199001010000 $@; exit 1)

.PHONY: test

# ---------------------------------------------------------------------------------
# install

INSTALLDIR := $(HOME)/Library/Fonts/$(FAMILY)

install: $(INSTALLDIR)/$(FAMILY).var.ttf

$(INSTALLDIR)/%.otf: $(FONTDIR)/static/%.otf | $(INSTALLDIR)
	cp -a $^ $@

$(INSTALLDIR)/%.var.ttf: $(FONTDIR)/var/%.var.ttf | $(INSTALLDIR)
	cp -a $^ $@

$(INSTALLDIR):
	mkdir -p $@

.PHONY: install

# ---------------------------------------------------------------------------------
# misc

clean:
	rm -rf build/tmp build/fonts build/ufo build/googlefonts

.PHONY: clean

# ---------------------------------------------------------------------------------
# list make targets
#
# We copy the Makefile (first in MAKEFILE_LIST) and disable the include to only list
# primary targets, avoiding the generated targets.
list:
	@mkdir -p build/etc \
	&& cat $(MAKEFILE) \
	 | sed 's/include /#include /g' > build/etc/Makefile-list \
	&& $(MAKE) -pRrq -f build/etc/Makefile-list : 2>/dev/null \
	 | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
	 | sort \
	 | egrep -v -e '^_|/' \
	 | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: list
