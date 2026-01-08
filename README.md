# file-compare

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/Melkor-1/file-compare/edit/main/LICENSE)

A 16-bit DOS assembly program that compares two files byte by byte and prints whether they are equal or not.

## Usage

1. Assemble and link the program in DOSBox:

```dos
masm fc.asm
link fc.obj

```

2. Run the program:

```dos
fc.exe
```

3. Enter the first filename and second filename when prompted.

4. The program outputs whether the files are equal or unequal, or prints an error code if a file cannot be opened or read.

## Code Reviews:

This project has been reviewed and discussed on [CodeReview Stack Exchange](https://codereview.stackexchange.com/).
You can explore the discussions here: 
- [Full Code Review Discussion](https://codereview.stackexchange.com/questions/295873/compare-two-files-in-16-bit-dos-assembly)
