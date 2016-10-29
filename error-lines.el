;;; error-lines.el --- Covenience library for highlight errors

;; Copyright (C) 2016 Tal Wrii

;; Author: Tal Wrii (talwrii@gmail.com)
;; URL: github.com/talwrii/error-lines
;; Version: 0.1.0
;; Package-Version: 20161028.1
;; Created October 2016

;; Keywords: debugging

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.


;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; This code is mostly stolen from flymake within emacs core
;; (written by Pavel Kobyakov and copyrighted by the FSF)
;; This library is distributed under GPL v3


;;; Commentary:
;; A *simple* library to highlight errors on lines and navigate to them
;; Hopefully this is more useful for ad-hoc activities than things
;; like flymake and compile because you can call it yourself,
;; rather than have it call you

;;; Usage:

;; Highlight some lines
;; (require 'error-lines)
;; (error-lines-from-string "1 2 3 4")
;; (error-lines-from-search "defun")

;; Motions
;; (error-lines-next)  (error-lines-prev)

;; Clearing (error-lines-reset)

;; You might like to have some keybindings for these functions

;; If you want to have independent instances of this library,
;; this may be achieved using dynamic (or lexical) scoping
;; like so to consistenly override error-lines overlay

;;  (let ((error-lines-overlay 'mylibrary-overlay))
;;     (error-lines-next))


;;; Code:

(require 'dash)
(require 's)
(require 'select)

(defface error-lines-face '((:background . "red")) "Face used to highlight error lines")
(defvar error-lines-overlay 'error-lines-overlay "Identifier for error lines.  Dynamically override this to run independent instances of error lines.")

(defun error-lines-add-lines (lines)
  "Add error lines from LINES, a list of line numbers."
  (mapcar 'error-lines-add-line lines))

(defun error-lines-from-search (search-string)
  "Add error lines for those lines containing SEARCH-STRING."
  (interactive "sSearch String:")
  (error-lines-add-lines (error-lines--all-matching-lines search-string)))

(defun error-lines--all-matching-lines (search)
  "Find all lines matching a string: SEARCH."
  (let (matches bol)
    (save-match-data
      (save-excursion
        (goto-char (point-min))
        (while (search-forward search nil 't)
          (push (line-number-at-pos) matches))))
    (sort (delete-duplicates matches) '<)))

(defun error-lines-from-string (lines-string)
  "Add error lines from a string, LINES-STRING, consisting of a list of numbers separated by spaces or newlines."
  (interactive "sLine numbers to highlight:")
  (setq lines-string (s-replace "\n" " " lines-string))
  (error-lines-add-lines (mapcar 'parse-integer (s-split " " lines-string t))))

(defun error-lines-from-clipboard ()
  "Add error lines from a string in the clipboard (as with `error-lines-from-string')."
  (interactive)
  (error-lines-from-string (x-get-selection)))

(defun error-lines-add-line (line-num)
  "Overlay a line with number LINE-NUM with formatting."
  (let (overlay beg end)
    (save-excursion
      (goto-line line-num)
      (beginning-of-line)
      (setq beg (point))
      (next-line)
      (beginning-of-line)
      (setq end (point)))

    (setq overlay (make-overlay beg end nil t))
    (overlay-put overlay 'face 'error-lines-face)
    (overlay-put overlay error-lines-overlay  t)
    (overlay-put overlay 'priority 100)
    (overlay-put overlay 'evaporate t)))

(defun error-lines-reset ()
  "Reset the highlighting in the current buffer."
  (interactive)
  (error-lines--delete-overlays))

(defun error-lines-next ()
  "Jump to the next error line."
  (interactive)
  (let (next-line next-overlays)
    (setq next-line (save-excursion (next-line) (point)))
    (setq next-overlays (error-lines--overlays next-line (point-max)))
    (if next-overlays
        (goto-char
         (apply 'min
                (mapcar 'overlay-start
                        next-overlays)))
      (error "No-more-lines"))))

(defun error-lines-previous ()
  "Jump to the previous error line."
  (interactive)
  (let (prev-line prev-overlays)
    (setq prev-line (save-excursion (previous-line) (point)))
    (setq prev-overlays (error-lines--overlays (point-min) prev-line))
    (if prev-overlays
        (goto-char
         (apply 'max
                (mapcar 'overlay-start
                        prev-overlays)))
      (error 'no-more-lines))))

(defun error-lines-fixed (line-num)
  "Mark a line at LINE-NUM as fixed (remove highlighting).  nil for current line."
  (interactive (list nil))
  (let (start end)
    (setq line-num (or line-num (line-number-at-pos)))
    (save-excursion
      (goto-line line-num)
      (beginning-of-line)
      (setq start (point))
      (end-of-line)
      (setq end (point)))
    (error-lines--delete-overlays start end)))

(defun error-lines--delete-overlays (&optional start end)
  "Delete all flymake overlays in current buffer in the region between START and END.  Default to the entire buffer."
  (setq start (or start (point-min)))
  (setq end (or end (point-max)))
  (dolist (overlay (error-lines--overlays start end))
      (delete-overlay overlay)))

(defun error-lines--overlay-p (overlay)
  "Confirm that OVERLAY belongs to us."
  (overlay-get overlay error-lines-overlay))

(defun error-lines--overlays (start end)
  "Get our overlays in the region between START and END."
    (-filter 'error-lines--overlay-p (overlays-in start end)))

(provide 'error-lines)
(provide 'error-lines)

;;; error-lines.el ends here
