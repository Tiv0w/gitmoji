# gitmoji
Add a gitmoji selector to your commits and easily insert gitmojis :sparkles:


## Usage

You can install the library by cloning the repo and using `M-x package-install-file`.
Then you would put this snippet in your config file(s):

```emacs-lisp
(require 'gitmoji)
(setq gitmoji--insert-utf8-emoji nil
      gitmoji--display-utf8-emoji nil) ;; These are the defaults.
```

## Customization

- `gitmoji--insert-utf8-emoji`:
  When t, inserts the utf8 emoji character into the buffer instead of the github-style representation.
  Example: :zap: instead of `:zap:`.
  Default: nil.

- `gitmoji--display-utf8-emoji`:
  When t, displays the utf8 emoji character in the gitmoji choice list.
  Default: nil.
