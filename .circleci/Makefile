.DEFAULT_GOAL := validate

.PHONY: build
build:
	@dhall-to-yaml \
	  --generated-comment \
	  --explain \
	  --file ./config.dhall \
	  | tee config.yml
	@echo

.PHONY: validate
validate: build
	@circleci config validate config.yml
	@echo

.PHONY: do-watch
do-watch:
	@clear
	@echo "Changes to config.dhall will trigger the \`$(TARGET)\` target"
	@echo
	@while inotifywait -e modify config.dhall; do \
	  clear; \
	  $(MAKE) -s $(TARGET); \
	  done

.PHONY: watch
watch:
	@TARGET=build $(MAKE) -s do-watch

.PHONY: watch-validate
watch-validate:
	@TARGET=validate $(MAKE) -s do-watch
