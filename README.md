# error-lines

An emacs library to highlight lines and move between these highlighted lines.

Commonly these highlighted lines will be errors. The motivation behind this
library is to make it easy build ad-hoc error checking libraries.

Similar functionality is provided by **flymake**, **flyspell**, **compile**
and as part of other libraries but very much in the context of one activity.

## Extended usage example

Hopefully, an extended example will illustrate the motivation for this library.

Suppose you are interested in lines with more than 120 characters.

The following bash command will produce a list of line numbers for lines
with more than around 120 characters, storing the results in the clipboard.

```bash
cat error-lines.el | nl |  sed -E '/.{120}/ p' -n | awk '{ print $1 }' | xclip -i
```

You may then run `M-x error-lines-from-clipboard` to highlight these lines.

## Documentation

See `error-lines.el` for documentation.

## Installing

Download this library, add it your `load-path`, then run the following to your `init.el` file.

```
(require 'error-lines)
```

## MELPA

I got half-way through adding this to MELPA before I decided if was too much effort.
Perhaps it wouldn't take too long to finish the job.



