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
make test.sanity             # Run ansible-test sanity
make molecule                # Run molecule tests for all roles
make molecule role=rolename  # Run molecule tests for a specific role
make test                    # Run lint, sanity, and molecule tests
```

### Running Molecule Commands

Molecule is used for integration testing. Tests are located in `extensions/molecule/` with shared configuration.

```bash
# Run full test sequence (destroy, create, prepare, converge, idempotence, verify, destroy)
make molecule role=rolename

# Run just the converge step (apply the role)
make molecule.converge role=rolename

# Run just the verify step
make molecule.verify role=rolename

# Test idempotency (run converge twice)
make molecule.idempotence role=rolename

# Create test instance
make molecule.create role=rolename

# Destroy test instance
make molecule.destroy role=rolename
```

Molecule uses **podman** for testing. The **idempotence** step automatically runs the role twice to verify no changes occur on the second run.

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
├── extensions/
│   └── molecule/          # Molecule integration tests
│       ├── config.yml     # Global driver/provisioner config
│       └── <scenario>/    # Per-role molecule scenarios
│           ├── molecule.yml
│           ├── prepare.yml
│           ├── converge.yml
│           └── verify.yml
├── meta/
│   ├── runtime.yml        # Ansible version requirements
│   └── execution-environment.yml  # ansible-builder config
├── playbooks/             # Collection playbooks
├── plugins/               # Custom plugins (modules, filters, etc.)
│   ├── modules/           # Ansible modules
│   ├── filter/            # Jinja2 filter plugins
│   ├── lookup/            # Lookup plugins
│   └── module_utils/      # Shared module utilities
└── roles/
    └── <rolename>/        # Role directories
        ├── defaults/main.yml
        ├── handlers/main.yml
        ├── meta/
        │   ├── main.yml
        │   └── argument_specs.yml
        ├── tasks/
        └── templates/
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
  ansible.builtin.systemd_service:
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
- Prefix variables with `{{ namespace }}_{{ collection_name }}_` (e.g., `calopsys_myapp_user`)
- Example: `calopsys_myapp_config_dir`, `calopsys_myapp_env_dir`

### Conditionals

```yaml
- name: "Task with condition."
  ansible.builtin.debug:
    msg: "Conditional task"
  when: "calopsys_myapp_enable_feature | bool"
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
pipx install molecule
pipx inject molecule molecule-plugins[podman]
```

Ansible Core 2.18.0+ is required.

## Best Practices

1. Run `make lint` before committing
2. Run `make test.sanity` before pushing
3. Add changelog fragments for user-visible changes
4. Write molecule tests in `extensions/molecule/<scenario>/`
5. Update REFERENCE.md when changing role defaults or argument specs (run `make docs role=<name>`)
