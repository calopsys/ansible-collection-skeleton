# Collections Roles Directory

This directory contains roles that can be used within the collection.

Each role is placed in its own subdirectory. Here is an example structure:

```
└── roles
    └── my_role/
        ├── defaults/
        │   └── main.yml           # Default variables
        ├── files/                 # Static files
        ├── handlers/
        │   └── main.yml           # Handlers
        ├── meta/
        │   ├── main.yml           # Role metadata
        │   └── argument_specs.yml # Role argument validation
        ├── tasks/
        │   └── main.yml           # Main tasks
        ├── templates/             # Jinja2 templates
        └── vars/
            └── main.yml           # Role variables
```

For more information, see [Roles](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html).
