OUT_DIR=output
IN_DIR=markdown
STYLES_DIR=styles
STYLE=gunziptarball

all: html pdf docx rtf public-html

pdf: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		SUBST_FILE=$(IN_DIR)/subst.$$FILE_NAME; \
		echo $$FILE_NAME.pdf; \
		envsubst < $$f > $$SUBST_FILE; \
		pandoc --standalone --template $(STYLES_DIR)/$(STYLE).tex \
			--from markdown --to context \
			--variable papersize=A4 \
			--output $(OUT_DIR)/$$FILE_NAME.tex $$SUBST_FILE > /dev/null; \
		mtxrun --path=$(OUT_DIR) --result=$$FILE_NAME.pdf --script context $$FILE_NAME.tex > $(OUT_DIR)/context_$$FILE_NAME.log 2>&1; \
		rm $$SUBST_FILE; \
	done

html: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		SUBST_FILE=$(IN_DIR)/subst.$$FILE_NAME; \
		echo $$FILE_NAME.html; \
		envsubst < $$f > $$SUBST_FILE; \
		pandoc --standalone --include-in-header $(STYLES_DIR)/$(STYLE).html \
			--lua-filter=pdc-links-target-blank.lua \
			--from markdown --to html \
			--output $(OUT_DIR)/$$FILE_NAME.html $$SUBST_FILE; \
		rm $$SUBST_FILE; \
	done
#main_content > p:nth-child(20)
docx: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		SUBST_FILE=$(IN_DIR)/subst.$$FILE_NAME; \
		echo $$FILE_NAME.docx; \
		envsubst < $$f > $$SUBST_FILE; \
		pandoc --standalone $$SMART $$SUBST_FILE --output $(OUT_DIR)/$$FILE_NAME.docx; \
		rm $$SUBST_FILE; \
	done

rtf: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		SUBST_FILE=$(IN_DIR)/subst.$$FILE_NAME; \
		echo $$FILE_NAME.rtf; \
		envsubst < $$f > $$SUBST_FILE; \
		pandoc --standalone $$SMART $$SUBST_FILE --output $(OUT_DIR)/$$FILE_NAME.rtf; \
		rm $$SUBST_FILE; \
	done

init: dir version

dir:
	mkdir -p $(OUT_DIR)

version:
	PANDOC_VERSION=`pandoc --version | head -1 | cut -d' ' -f2 | cut -d'.' -f1`; \
	if [ "$$PANDOC_VERSION" -eq "2" ]; then \
		SMART=-smart; \
	else \
		SMART=--smart; \
	fi \

clean:
	rm -f $(OUT_DIR)/*
