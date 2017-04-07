;;ステートをモードラインに
(eval-when-compile (require 'cl))

(defgroup mode-line-color nil
  "Mode line color."
  :prefix "mode-line-color-"
  :group 'mode-line)

(defcustom mode-line-color-buffers-regexp '("^\\*scratch\\*$")
  "List of regular expressions of buffer names to enable mode-line-color-mode automatically."
  :group 'mode-line-color
  :type '(repeat 'string))

(defcustom mode-line-color-exclude-buffers-regexp '("^ ")
  "List of regular expressions of buffer names not to enable mode-line-color-mode automatically."
  :group 'mode-line-color
  :type '(repeat 'string))

(defvar mode-line-color-hook nil
  "hook for setting mode line color

   Usage:
     (defun your-function-to-set-mode-line-color (setter)
       (funcall setter \"yellow\"))
     (add-hook 'mode-line-color-hook 'your-function-to-set-mode-line-color)")

(defvar mode-line-color-mode nil)
(defvar mode-line-color-color nil)
(defvar mode-line-color-original nil)
(defvar mode-line-color-activated nil)
(make-variable-buffer-local 'mode-line-color-activated)

(defun mode-line-color-set-color (color)
  (setq mode-line-color-color color))

(defun mode-line-color-excluded-p ()
  (let* ((buffer (current-buffer)) (name (buffer-name buffer)))
    (flet ((mem-pat (s l)
             (memq nil (mapcar #'(lambda (r) (not (string-match-p r s))) l))))
      (or (minibufferp buffer)
          (and (not (mem-pat name mode-line-color-buffers-regexp))
               (mem-pat name mode-line-color-exclude-buffers-regexp))))))

(defun mode-line-color-active-p ()
  (unless mode-line-color-activated ; make cache
    (let ((exclude (mode-line-color-excluded-p)))
      (setq mode-line-color-activated (if exclude 0 1))))
  (= 1 mode-line-color-activated))

(defun mode-line-color-update (&optional force)
  (if (mode-line-color-active-p)
      (let ((mode-line-color-color nil))
        (run-hook-with-args 'mode-line-color-hook 'mode-line-color-set-color)
        (set-face-background 'mode-line (or mode-line-color-color
                                            mode-line-color-original)))
    (unless (minibufferp)
      (set-face-background 'mode-line mode-line-color-original))))

(defmacro define-mode-line-color (bind &rest body)
  (declare (indent defun))
  (let ((prev (nth 0 bind)))
    `(add-hook 'mode-line-color-hook
               #'(lambda (setter)
                   (let* ((,prev mode-line-color-color) (color (progn ,@body)))
                     (when color (funcall setter color)))))))

(defun mode-line-color-install ()
  (unless mode-line-color-original
    (setq mode-line-color-original (face-background 'mode-line)))
  (add-hook 'post-command-hook 'mode-line-color-update))

(defun mode-line-color-uninstall ()
  (set-face-background 'mode-line mode-line-color-original)
  (remove-hook 'post-command-hook 'mode-line-color-update))

(defadvice set-buffer (after update-mode-line-color activate)
  (when (eq (current-buffer) (window-buffer (selected-window)))
    (mode-line-color-update)))

(defadvice kill-buffer (after update-mode-line-color activate)
  (mode-line-color-update))

;;;###autoload
(define-minor-mode mode-line-color-mode
  "Set color of mode line."
  :global t
  :group 'mode-line-color
  (if mode-line-color-mode
      (mode-line-color-install)
    (mode-line-color-uninstall)))

(provide 'mode-line-color)

;;; evil-mode-line.el --- Mode line plugin for Evil

;; Author: INA Lintaro <tarao.gnn at gmail.com>
;; URL: http://github.com/tarao/evil-plugins
;; Version: 0.1
;; Keywords: evil, plugin

;; This file is NOT part of GNU Emacs.

;;; License:
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Code:

(defgroup evil-mode-line nil
  "Mode line color and message for Evil"
  :group 'evil)

(defcustom evil-mode-line-color
  `((normal   . ,(face-background 'mode-line))
    (insert   . "#575735")
    (replace  . "#575735")
    (operator . "DarkSeaGreen4")
    (visual   . "SteelBlue4")
    (emacs    . "#8c5353"))
  "Mode line color corresponds to Evil state."
  :type '(alist :key-type symbol :value-type string)
  :group 'evil-mode-line)
(defcustom evil-normal-state-msg ""
  "Mode line message for Evil normal state."
  :type 'string
  :group 'evil-mode-line)
(defcustom evil-insert-state-msg "INSERT"
  "Mode line message for Evil insert state."
  :type 'string
  :group 'evil-mode-line)
(defcustom evil-replace-state-msg "REPLACE"
  "Mode line message for Evil replace state."
  :type 'string
  :group 'evil-mode-line)
(defcustom evil-emacs-state-msg "x"
  "Mode line message for Evil emacs state."
  :type 'string
  :group 'evil-mode-line)
(defcustom evil-visual-state-msg-alist
  '((normal . "VISUAL") (line . "VLINE") (block . "VBLOCK"))
  "Mode line messages for Evil visual states."
  :type '(list (cons symbol string))
  :group 'evil-mode-line)

(defun evil-mode-line-state-msg (&optional state)
  "Find a message string for STATE.
If `evil-STATE-state-msg' is bound, use that value.  Otherwise,
if STATE is a visual state, then `evil-visual-state-msg-alist' is
looked up by the return value of `evil-visual-type'.  If no
message string is found, return an empty string."
  (unless state (setq state evil-state))
  (let ((sym (intern (concat "evil-" (symbol-name state) "-state-msg"))))
    (cond
     ((boundp sym) (symbol-value sym))
     ((evil-visual-state-p)
      (or (cdr (assq (evil-visual-type) evil-visual-state-msg-alist))
          (cdr (assq 'normal evil-visual-state-msg-alist))))
     (t ""))))

(defun evil-mode-line-state-msg-format (&optional state)
    "Make mode string for STATE.
If `evil-mode-line-state-msg' returns non-empty string, the mode string
is \"--STATE MESSAGE--\".  Otherwise, the mode string is \"-\"."
    (let* ((msg (evil-mode-line-state-msg state)) (line msg)
           (empty (= (length msg) 0)) (tail (if empty "-" "--")))
      (unless empty (setq line (concat "--" msg)))
      (list "" line tail)))
(defadvice skk-mode-string-to-indicator
  (before evil-remove----from-skk-mode-string (mode string) activate)
  "Do not put \"--\" at the beginning of mode string.
We have our own \"--\" put by `evil-mode-line-state-msg-format'."
  (when (string-match "^--" string)
    (setq string (substring string 2))))

(defvar evil-mode-line-msg (evil-mode-line-state-msg-format 'emacs-state))

(defun evil-update-mode-line-state-msg ()
  "Update `evil-mode-line-msg' and update mode line color."
  (condition-case ()
      (progn
        (set (make-local-variable 'evil-mode-line-msg)
             (evil-mode-line-state-msg-format))
        (mode-line-color-update))
    (error nil)))

(defadvice evil-refresh-mode-line (after evil-update-mode-line-msg activate)
  "Update our own mode string by `evil-update-mode-line-msg'."
  (evil-update-mode-line-state-msg))

;; setup

(define-mode-line-color (color)
  (unless color (cdr (assq evil-state evil-mode-line-color))))

(setq-default mode-line-format
              (append '("" evil-mode-line-msg) mode-line-format))

(provide 'evil-mode-line)
;;; evil-mode-line.el ends here
