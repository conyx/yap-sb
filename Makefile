.PHONY: unify
unify: boxee.scad
boxee.scad: main.scad unify.py
	@python3 unify.py $< > $@
	@echo "Generated $@"

.PHONY: clean
clean:
	rm -f boxee.scad boxee.stl main.stl
