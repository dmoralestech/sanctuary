OWNER = sanctuary-js
NAME = sanctuary

DOCTEST = node_modules/.bin/doctest --module commonjs --prefix .
ISTANBUL = node_modules/.bin/istanbul
NPM = npm


.PHONY: all
all: LICENSE README.md

.PHONY: LICENSE
LICENSE:
	node_modules/.bin/sanctuary-update-copyright-year

README.md: index.js package.json
	node_modules/.bin/sanctuary-generate-readme index.js


.PHONY: lint
lint:
	node_modules/.bin/sanctuary-lint-es3 \
	  --global define \
	  --global module \
	  --global require \
	  --global self \
	  -- index.js
	node_modules/.bin/sanctuary-lint-es3 \
	  --env node \
	  -- karma.conf.js
	node_modules/.bin/sanctuary-lint-es3 \
	  --env node \
	  --global suite \
	  --global test \
	  --rule 'dot-notation: [error, {allowKeywords: true}]' \
	  --rule 'max-len: [off]' \
	  -- test
	node_modules/.bin/sanctuary-check-required-files
	node_modules/.bin/sanctuary-lint-package-json '$(OWNER)' '$(NAME)'
	node_modules/.bin/sanctuary-lint-bower-json
	node_modules/.bin/sanctuary-lint-readme
	node_modules/.bin/sanctuary-lint-commit-message


.PHONY: release-major release-minor release-patch
release-major release-minor release-patch:
	@node_modules/.bin/sanctuary-release $(@:release-%=%) '$(OWNER)' '$(NAME)'


.PHONY: setup
setup:
	$(NPM) --version
	$(NPM) install


.PHONY: test
test:
	$(ISTANBUL) cover node_modules/.bin/_mocha
	$(ISTANBUL) check-coverage --branches 100
ifeq ($(shell node --version | cut -d . -f 1),v6)
	$(DOCTEST) -- index.js
else
	@echo '[WARN] Doctests are only run in Node v6.x.x (current version is $(shell node --version))' >&2
endif
