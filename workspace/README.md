# Workspace Directory

This directory is mounted into the Vibecraft Docker container at `/workspace`.

## Usage

Place your projects here to make them accessible to Claude Code running inside the container:

```bash
cd workspace

# Clone a project
git clone https://github.com/your/project.git

# Or copy an existing project
cp -r ~/my-project .
```

## In Vibecraft

When creating a new Claude session in the Vibecraft UI:
1. Set the working directory to `/workspace/your-project-name`
2. Claude can now read, edit, and run commands in that directory

## Example Structure

```
workspace/
├── my-web-app/
│   ├── src/
│   ├── package.json
│   └── ...
├── another-project/
│   └── ...
└── README.md (this file)
```

## Notes

- This directory is ignored by git (see `.gitignore`)
- Your projects stay on your host machine
- Multiple projects can coexist here
- Claude sessions can work on different projects simultaneously
