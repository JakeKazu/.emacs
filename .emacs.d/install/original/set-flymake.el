(provide 'set-flymake)

;;;;;;文法チェック flymake;;;;;
(require 'flymake)
;ハイライト色
(set-face-background 'flymake-errline nil)    ;既存のフェイスを無効にする
(set-face-foreground 'flymake-errline nil)
(set-face-background 'flymake-warnline nil)
(set-face-foreground 'flymake-warnline nil)

(make-face 'my-flymake-warning-face)
(set-face-foreground 'my-flymake-warning-face "yellow")
(set-face-background 'my-flymake-warning-face "black")
(setq my-flymake-warning-face 'my-flymake-warning-face)

(defvar flymake-fringe-overlays nil)
(make-variable-buffer-local 'flymake-fringe-overlays)

(defadvice flymake-make-overlay (after add-to-fringe first
                                       (beg end tooltip-text face mouse-face)
                                       activate compile)
  (push (fringe-helper-insert-region
           beg end
           (fringe-lib-load (if (eq face 'flymake-errline)
                                fringe-lib-exclamation-mark
                              fringe-lib-question-mark))
           'left-fringe 'my-flymake-warning-face)
           ;; 'left-fringe 'font-lock-warning-face)
        flymake-fringe-overlays))

(defadvice flymake-delete-own-overlays (after remove-from-fringe activate
                                              compile)
  (mapc 'fringe-helper-remove flymake-fringe-overlays)
  (setq flymake-fringe-overlays nil))

;; c++有効 flycheckの方が動作が早いのでそちらを採用
;; (defun flymake-cc-init ()
;;   (let* ((temp-file   (flymake-init-create-temp-buffer-copy
;;                        'flymake-create-temp-inplace))
;;          (local-file  (file-relative-name
;;                        temp-file
;;                        (file-name-directory buffer-file-name))))
;;     (list "g++" (list "-Wall" "-Wextra" "-fsyntax-only" local-file))))

;; (push '("\\.cpp$" flymake-cc-init) flymake-allowed-file-name-masks)
;; (add-hook 'c++-mode-hook
;;           '(lambda()
;;              (flymake-mode t)
;;              (flymake-cursor-mode t)
;;              (setq flymake-check-was-interrupted t)
;;              ;;(local-set-key "\C-c\C-v" 'flymake-start-syntax-check)
;;              ;;(local-set-key "\C-c\C-p" 'flymake-goto-prev-error)
;;              ;;(local-set-key "\C-c\C-n" 'flymake-goto-next-error)
;;           )
;; )

;java
(defun my-java-flymake-init ()
  (list "javac" (list (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-with-folder-structure))))
(add-to-list 'flymake-allowed-file-name-masks '("\\.java$" my-java-flymake-init flymake-simple-cleanup))
(add-hook 'java-mode-hook 'flymake-mode-on)

;python-mode
(require 'python-mode)
(autoload 'python-mode "python-mode" "Python editing mode." t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(display-time-mode t)
 '(py-indent-offset 4)
 '(show-paren-mode t))
(add-hook 'python-mode-hook
  '(lambda()
    (setq tab-width 4) 
    (setq indent-tabs-mode nil)
  )
)
;python
(require 'flymake-python-pyflakes)
(add-hook 'python-mode-hook 'flymake-python-pyflakes-load)


;ミニバッファにエラー文表示（カーソルをかざす）
(defun flymake-show-help ()
  (when (get-char-property (point) 'flymake-overlay)
    (let ((help (get-char-property (point) 'help-echo)))
      (if help (message "%s" help)))))
(add-hook 'post-command-hook 'flymake-show-help)

;;;;;;文法チェック flymake おわり;;;;;;
