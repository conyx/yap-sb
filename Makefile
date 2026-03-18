.PHONY: unify
unify: storagebox.scad

storagebox.scad: main.scad
	@awk ' \
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
