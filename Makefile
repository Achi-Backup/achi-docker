COLOR_WARNING = \033[31m
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

# do nothing if make is called without target
placeholder:
	@:
.PHONY: placeholder

achi:
	@./bin/achi.sh $(RUN_ARGS)
.PHONY: achi

%:
	@:
