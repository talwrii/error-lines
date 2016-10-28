# error-lines

An emacs library to make it easy to highlight lines and move between these
highlighted lines.

Commonly these highlighted lines will be errors. The motivation
behind this library is to make it easy build ad-hoc error
checking libraries.

Similar functionality is provided by flymake, flyspell and compile
but very much in the context of one activity.

## Extended usage example

Hopefully an extended example will illustrate the motivation behind this library:

Suppose you are interested in lines with more than 120 characters.

The following bash command will find you a list of line numbers with more
than around 120 characters, and store the results in the clipboard.

```
cat error-lines.el | nl |  sed -E '/.{120}/ p' -n | awk '{ print $1 }' | xclip -i
```

You may then run the command `M-x error-lines-from-clipboard` to highlight these lines.

## Documentation

See error-lines.el for documentation.

## Installing

Download this library, add it your load-path, then run add the following to your `init.el` file.

```
(require 'error-lines)
```

## MELPA

I got half-way through adding this to MELPA before I decided if was too much effort.
Perhaps it wouldn't take too long to finish the job.

