# Use an official TeX Live image
FROM texlive/texlive:latest

# Install any additional LaTeX packages you might need (optional)
# RUN tlmgr install biber xindy
# RUN tlmgr update --self && tlmgr update --all

# Set the working directory
WORKDIR /workspace

# Create the build script that handles LaTeX compilation
RUN echo '#!/bin/bash\n\
set -e\n\
MAIN_FILE=${1:-main.tex}\n\
\n\
# Check if main tex file exists\n\
if [ ! -f "$MAIN_FILE" ]; then\n\
    echo "❌ Error: Main LaTeX file $MAIN_FILE not found!"\n\
    echo "Available .tex files:"\n\
    find . -name "*.tex" -type f\n\
    exit 1\n\
fi\n\
\n\
echo "🔨 Building LaTeX document: $MAIN_FILE"\n\
\n\
# Extract basename for output files\n\
BASENAME=$(basename "$MAIN_FILE" .tex)\n\
\n\
# Create temporary directory for build files\n\
TEMP_DIR="/tmp/latex-build-$$"\n\
mkdir -p "$TEMP_DIR"\n\
\n\
# Copy source files to temp directory\n\
echo "📁 Copying source files to temporary build directory..."\n\
cp -r . "$TEMP_DIR/"\n\
cd "$TEMP_DIR"\n\
\n\
# Build the document (run multiple times for references and bibliography)\n\
echo "📄 Running pdflatex (1st pass)..."\n\
pdflatex -interaction=nonstopmode "$MAIN_FILE" || true\n\
\n\
# Run bibtex if .bib files exist\n\
if ls *.bib 1> /dev/null 2>&1; then\n\
    echo "📚 Found bibliography files, running bibtex..."\n\
    bibtex "$BASENAME.aux" || true\n\
fi\n\
\n\
# Run pdflatex again for references\n\
echo "📄 Running pdflatex (2nd pass)..."\n\
pdflatex -interaction=nonstopmode "$MAIN_FILE"\n\
echo "📄 Running pdflatex (3rd pass)..."\n\
pdflatex -interaction=nonstopmode "$MAIN_FILE"\n\
\n\
# Copy PDF back to workspace and clean up\n\
if [ -f "$BASENAME.pdf" ]; then\n\
    echo "📋 Copying PDF to workspace and cleaning up..."\n\
    cp "$BASENAME.pdf" "/workspace/"\n\
    cd /workspace\n\
    rm -rf "$TEMP_DIR"\n\
    echo "✅ Successfully built: $BASENAME.pdf"\n\
    ls -lh "$BASENAME.pdf"\n\
else\n\
    echo "❌ Error: PDF was not generated"\n\
    echo "LaTeX log:"\n\
    cat "$BASENAME.log" 2>/dev/null || echo "No log file found"\n\
    cd /workspace\n\
    rm -rf "$TEMP_DIR"\n\
    exit 1\n\
fi\n\
' > /usr/local/bin/build-latex && chmod +x /usr/local/bin/build-latex

# Set default entrypoint to the build script
ENTRYPOINT ["/usr/local/bin/build-latex"]

# Default command builds main.tex
CMD ["main.tex"]
