# 生成文件目录

## summary.rb

```
summary.rb [OPTION]

-t, --title [string]:
   title ,default 'SUMMARY'

-d, --directory [directory path]:
   target directory path ,default './'

-o, --output [file path]:
   output file path ,default './SUMMARY.md'

-i, --ignore [array]:
   ignore string array ,default '['resource', 'Resource']'

-s, --suffix [array]:
   suffix string array ,default '['.md', '.markdown']'

-S, --style [string]:
   output style ,could be 'github' or 'gitbook', default 'github'

-h, --help:
   show help

-v, --version:
   show version

```

### -S, --style

生成目录风格，有`github`和`gitbook`两种风格

#### github

文件夹直接链接到文件夹目录

#### gitbook

文件夹链接到文件夹目录下的`README.md`，如果没有就没有链接
