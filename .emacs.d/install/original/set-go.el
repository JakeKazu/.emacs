(provide 'set-go)

;; go get github.com/rogpeppe/godef
;; go get -u github.com/nsf/gocode
;; go get github.com/golang/lint/golint
;; go get github.com/kisielk/errcheck

(require 'go-mode)
(require 'go-eldoc)

;;各自設定する
(require 'exec-path-from-shell)
(let ((envs '("PATH" "GOPATH")))
  (exec-path-from-shell-copy-envs envs))

::go-mode
(use-package go-mode
  :config
  (bind-keys :map go-mode-map
         ("M-." . godef-jump)
         ("M-," . pop-tag-mark))
  )

;;go-eldoc
(use-package go-eldoc
  :config
  (add-hook 'go-mode-hook 'go-eldoc-setup))

;;; helm-doc
(defvar my/helm-go-source
  '((name . "Helm Go")
    (candidates . go-packages)
    (action . (("Show document" . godoc)
               ("Import package" . my/helm-go-import-add)))))

(defun my/helm-go-import-add (candidate)
  (dolist (package (helm-marked-candidates))
    (go-import-add current-prefix-arg package)))

(defun my/helm-go ()
  (interactive)
  (helm :sources '(my/helm-go-source) :buffer "*helm go*"))

(define-key go-mode-map (kbd "C-c C-d") 'my/helm-go)

;; flycheck & company-go
(require 'company-go)

;; 諸々の有効化、設定
(add-hook 'go-mode-hook 'company-mode)
(add-hook 'go-mode-hook 'flycheck-mode)
(add-hook 'go-mode-hook (lambda()
           (setq gofmt-command "goimports") ;import 自動追加
           (add-hook 'before-save-hook 'gofmt-before-save)
           (local-set-key (kbd "M-.") 'godef-jump)
           (set (make-local-variable 'company-backends) '(company-go))
           (company-mode)
           (setq indent-tabs-mode nil)    ; タブを利用
           (setq c-basic-offset 4)        ; tabサイズを4にする
           (setq tab-width 4)))

(require 'go-direx) ;; Don't need to require, if you install by package.el
(define-key go-mode-map (kbd "C-c C-j") 'go-direx-pop-to-buffer)
