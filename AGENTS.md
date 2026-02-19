# AGENTS.md - Coding Agent Guidelines

This document provides guidance for AI coding agents working in this Ansible collection repository.

## Project Overview

This is an Ansible collection skeleton for the `calopsys` namespace. Collections are installed at:
```
~/git/ansible_collections/{{ namespace }}/{{ collection_name }}
```

## Build/Lint/Test Commands

### Linting
```bash
make lint                    # Run ansible-lint with production profile
```

### Testing
```bash
make test.sanity             # Run ansible-test sanity (requires Docker)
make testfull                # Run both lint and sanity tests
```

### Running a Single Test
For sanity tests on specific files:
```bash
ansible-test sanity --docker -v --test <test_name> <path/to/file>
```

Common test names: `import`, `compile`, `validate-modules`, `shellcheck`, `yamllint`, `ansible-doc`

Example - run yamllint on a specific file:
```bash
ansible-test sanity --docker -v --test yamllint plugins/modules/my_module.py
```

### Building
```bash
make build                   # Build collection tarball in build/ directory
```

### Documentation
```bash
make docs                    # Generate docs for all roles (requires aar-doc)
make docs role=rolename      # Generate docs for a specific role
```

### Changelogs
```bash
make changelog.lint          # Lint changelog fragments
make changelog.release       # Generate changelog for release
```

### Cleanup
```bash
make clean                   # Remove build/, tests/, and .ansible/ directories
```

## Project Structure

```
.
├── .ansible-lint           # ansible-lint configuration
├── Makefile               # Build and test commands
├── galaxy.yml.j2          # Collection metadata template
├── changelogs/
│   ├── config.yaml        # antsibull-changelog configuration
│   └── fragments/         # Changelog fragments
├── meta/
│   ├── runtime.yml        # Ansible version requirements
│   └── execution-environment.yml  # ansible-builder config
├── playbooks/             # Collection playbooks
├── plugins/               # Custom plugins (modules, filters, etc.)
│   ├── modules/           # Ansible modules
│   ├── filter/            # Jinja2 filter plugins
│   ├── lookup/            # Lookup plugins
│   └── module_utils/      # Shared module utilities
└── tests/
    ├── integration/       # Integration tests
    │   └── targets/
    └── unit/              # Unit tests
```

## Code Style Guidelines

### YAML Files

- Always start YAML files with `---` document marker
- Use 2 spaces for indentation (no tabs)
- Keep lines under 160 characters (though longer lines are tolerated)
- Use `.yml` extension (not `.yaml`)

### Task Files

- Use FQCN (Fully Qualified Collection Names) for all modules:
  ```yaml
  ansible.builtin.debug:
  ansible.builtin.template:
  ansible.builtin.service:
  ```
- Quote task names:
  ```yaml
  - name: "Install the package."
    ansible.builtin.apt:
  ```
- Quote file paths in import/include statements:
  ```yaml
  ansible.builtin.import_tasks: "install.yml"
  ```

### Tags

Use consistent tag naming: `{{ namespace }}_{{ collection_name }}_<action>`

Example:
```yaml
tags: ["calopsys_myapp_install"]
tags: ["calopsys_myapp_configure"]
```

### Variable Naming

- Use `snake_case` for variable names
- Example: `myapp_config_path`, `myapp_service_name`

### Conditionals

```yaml
- name: "Task with condition."
  ansible.builtin.debug:
    msg: "Conditional task"
  when: "myapp_enable_feature | bool"
```

### Error Handling

- Use `failed_when` and `changed_when` for explicit control:
  ```yaml
  - name: "Check something."
    ansible.builtin.command: "some-command"
    register: result
    changed_when: "'changed' in result.stdout"
    failed_when: result.rc != 0 and 'expected_error' not in result.stderr"
  ```

- Use `ignore_errors: true` sparingly and document why

### Comments

- Use `#` for comments in YAML
- Comment format for section headers:
  ```yaml
  # install tasks
  # configure tasks
  ```

### Linting Rules

The following ansible-lint rules are skipped (see `.ansible-lint`):
- `galaxy[no-changelog]` - No changelog required
- `var-naming[no-role-prefix]` - Variables don't need role prefix
- `name[casing]` - Task name casing is flexible
- `yaml[line-length]` - Line length limit not enforced

## Dependencies

Install required tools:
```bash
pipx install ansible-lint
pipx install antsibull-changelog
pipx install aar-doc
```

Ansible Core 2.18.0+ is required.

## Best Practices

1. Run `make lint` before committing
2. Run `make test.sanity` before pushing
3. Add changelog fragments for user-visible changes
4. Write unit tests for plugins/modules in `tests/unit/`
5. Write integration tests in `tests/integration/targets/`
