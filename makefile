all: jquery.instavalidate.md jquery.instavalidate.js

%.md: %.js.sdoc makefile
	sdoc cat markdown::$< > $@

%.js: %.js.sdoc makefile
	sdoc cat code.js::$< > $@
