PROJECT_NAME = Yet another parametric storage box [YAP-SB]
PROJECT_COPYRIGHT = Copyright © 2026 by Conyx
PROJECT_URL = https://github.com/conyx/yap-sb
PROJECT_LICENCE = CC BY-NC-SA 4.0
PROJECT_LICENCE_URL = https://creativecommons.org/licenses/by-nc-sa/4.0/

# Generates a single-file storagebox.scad from main.scad by inlining all local
# include files (non-BOSL2) at the /* [Hidden] */ marker, making the output
# self-contained for sharing on [MakerWorld/Thingvers/Printables] platforms.
.PHONY: unify
unify: storagebox.scad
storagebox.scad: main.scad
	@awk ' \
		BEGIN { \
			print "// $(PROJECT_NAME)"; \
			print "// $(PROJECT_COPYRIGHT)"; \
			print "// Project repository: $(PROJECT_URL)"; \
			print "// Licence: $(PROJECT_LICENCE) ($(PROJECT_LICENCE_URL))"; \
			print ""; \
		} \
		/^include[[:space:]]*<[^>]*>/ { \
			file = $$0; \
			gsub(/.*</, "", file); \
			gsub(/>.*/, "", file); \
			if (file !~ /^BOSL2\//) { \
				files[++n] = file; \
				next; \
			} \
		} \
		{ print } \
		/\/\* \[Hidden\] \*\// { \
			print ""; \
			for (i = 1; i <= n; i++) { \
				while ((getline line < files[i]) > 0) print line; \
				close(files[i]); \
				print ""; \
			} \
		} \
	' main.scad > $@
	@echo "Generated $@"

.PHONY: clean
clean:
	rm -f storagebox.scad main.stl
