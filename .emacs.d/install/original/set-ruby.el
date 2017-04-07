(provide 'set-ruby)

;;;;;;ruby-mode設定;;;;;;

(require 'ruby-mode)
(autoload 'ruby-mode "enh-ruby-mode"
  "Mode for editing ruby source files" t)
(add-to-list 'auto-mode-alist '("\\.rb" . ruby-mode))  (add-to-list 'auto-mode-alist '("Capfile" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))

;;do end補完
(require 'ruby-electric)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode t)))
(setq ruby-electric-expand-delimiters-list nil)

;;doやendに対応する行のハイライト
;; ruby-block.el --- highlight matching block
(require 'ruby-block)
(ruby-block-mode t)
(setq ruby-block-highlight-toggle t)

;;;;;;ruby-mode設定終わり;;;;;;
