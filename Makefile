.SILENT:

.PHONY: lint
lint:
	ansible-lint -v

.PHONY: test.sanity
test.sanity: clean
	ansible-test sanity --docker -v --exclude LICENSE

.PHONY: test
test: lint test.sanity molecule

.PHONY: molecule
molecule:
ifdef role
	molecule test -s $(role)
else
	molecule test --all
endif

.PHONY: molecule.create
molecule.create:
ifdef role
	molecule create -s $(role)
else
	molecule create --all
endif

.PHONY: molecule.converge
molecule.converge:
ifdef role
	molecule converge -s $(role)
else
	molecule converge --all
endif

.PHONY: molecule.verify
molecule.verify:
ifdef role
	molecule verify -s $(role)
else
	molecule verify --all
endif

.PHONY: molecule.idempotence
molecule.idempotence:
ifdef role
	molecule idempotence -s $(role)
else
	molecule idempotence --all
endif

.PHONY: molecule.destroy
molecule.destroy:
ifdef role
	molecule destroy -s $(role)
else
	molecule destroy --all
endif

.PHONY: clean
clean:
	rm -rf build/
	find . -name ".ansible" -type d -exec rm -rf {} +

# Document a single role with `make docs role=rolename`
# Document all roles with `make docs`
# All roles should contain meta/main.yml and meta/argument_specs.yml for aar-doc to work
.PHONY: docs
docs: clean
ifdef role
	aar-doc roles/$(role) defaults; \
	aar-doc --output-file REFERENCE.md roles/$(role) markdown;
else
	@for r in $(shell ls roles/ 2>/dev/null); do \
		aar-doc roles/$$r defaults; \
		aar-doc --output-file REFERENCE.md roles/$$r markdown; \
	done
endif

.PHONY: build
build: clean
	ansible-galaxy collection build --output-path build --force

.PHONY: changelog.lint
changelog.lint:
	antsibull-changelog lint

.PHONY: changelog.release
changelog.release:
	antsibull-changelog release
