# Fix for Missing LaTeX Packages in Overleaf

## Problem
The default Overleaf Community Edition installation uses a minimal TeX Live setup that only includes basic LaTeX packages. This causes compilation errors when trying to use document classes or packages that are not included in the basic installation, such as:

- `extarticle.cls` (from the `extsizes` package)
- Many other commonly used LaTeX packages

## Solution

### Option 1: Use the Extended Docker Image (Recommended)

We've created an extended Dockerfile that includes many commonly used LaTeX packages. To use it:

1. **Stop your current Overleaf instance:**
   ```bash
   docker-compose down
   ```

2. **Use the extended docker-compose file:**
   ```bash
   docker-compose -f docker-compose-extended.yml up -d
   ```

This will build a new image with additional LaTeX packages installed, including:
- Document classes: `extsizes` (for extarticle), `memoir`, `beamer`
- Math packages: `amsmath`, `amscls`, `amsfonts`, `mathtools`
- Graphics: `graphics`, `subfig`, `wrapfig`, `tikz`
- And many more commonly used packages

### Option 2: Add Specific Packages to Your Existing Installation

If you only need a few specific packages, you can add them to your running container:

1. **Access the running container:**
   ```bash
   docker exec -it sharelatex bash
   ```

2. **Install the required packages using tlmgr:**
   ```bash
   # For extarticle class
   tlmgr install extsizes
   
   # For other packages
   tlmgr install package-name
   
   # Update tlmgr path
   tlmgr path add
   ```

3. **Exit the container:**
   ```bash
   exit
   ```

**Note:** Changes made this way will be lost when the container is recreated.

### Option 3: Create a Custom Dockerfile

For a permanent solution with only the packages you need:

1. Create a custom Dockerfile based on `server-ce/Dockerfile-extended`
2. Modify the `tlmgr install` command to include only the packages you need
3. Build and use your custom image

### Option 4: Use a Full TeX Live Installation

For development environments where disk space is not a concern, you can modify the base Dockerfile to use `scheme-full` instead of `scheme-basic`:

In `server-ce/Dockerfile-base`, change line 66:
```dockerfile
echo "selected_scheme scheme-full" >> /install-tl-unx/texlive.profile
```

**Warning:** This will significantly increase the image size (several GB).

## Testing

After implementing any of the above solutions, test by creating a document with:

```latex
\documentclass{extarticle}
\usepackage[utf8]{inputenc}

\begin{document}
Hello World!
\end{document}
```

The document should compile without errors.

## Troubleshooting

1. **Clear browser cache** after making changes
2. **Check container logs:**
   ```bash
   docker logs sharelatex
   ```
3. **Verify package installation:**
   ```bash
   docker exec sharelatex tlmgr list --only-installed | grep package-name
   ```

## Additional Packages

To find the TeX Live package name for a specific LaTeX package or class:
- Search on [CTAN](https://ctan.org/)
- Use `tlmgr search` command

## Performance Considerations

- Installing many packages increases image build time
- Consider creating a local Docker registry to cache built images
- Use multi-stage builds if you need different package sets for different use cases
