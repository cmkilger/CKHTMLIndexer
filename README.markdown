#CKHTMLIndexer

CKHTMLIndexer indexes a set of HTML files, associating words to file paths.  I still need to write code to actually _use_ the generated index.

##Usage

html\_indexer _directorypath_ _indexpath_ [blacklistpath]

This will index the given directory and generate a Core Data SQLite file at the index path.  It will also generate HTMLIndexer.mom, a Core Data model file, next to the index file.  This needs to be used in the application that loads the index file. Any words contained in the blacklist file are ignored.

__Note:__ This project uses [data2source](http://github.com/cmkilger/data2source) to generate the mom file.  It currently assumes that data2source is installed at ~/.bin (that's where I put it).  If you don't have it, the script which updates the source files will fail.  If you don't change the data model, this shouldn't be a problem for you, just remove the "Data Model Source Files" target, or the dependency, or comment out the line that says "~/.bin/data2source …", or something like that.

##License

data2source is licensed under the MIT license, which is reproduced in its entirety here:

>Copyright (c) 2010 Cory Kilger
>
>Permission is hereby granted, free of charge, to any person obtaining a copy
>of this software and associated documentation files (the "Software"), to deal
>in the Software without restriction, including without limitation the rights
>to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>copies of the Software, and to permit persons to whom the Software is
>furnished to do so, subject to the following conditions:
>
>The above copyright notice and this permission notice shall be included in
>all copies or substantial portions of the Software.
>
>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>THE SOFTWARE.