(provide 'set-company)

;; ;;;;;;自動補完 company;;;;;;
(require 'company)
(global-company-mode) ; 全バッファで有効にする 
(setq company-idle-delay 0) ; デフォルトは0.5 nilにするとcompany無効
(setq company-minimum-prefix-length 2) ; デフォルトは4
(setq company-selection-wrap-around t) ; 候補の一番下でさらに下に行こうとすると一番上に戻る
;; 特定のmodeだけでcompany-modeを有効にしたいときは，(global-company-mode)を消して
;(add-hook 'c++-mode-hook 'company-mode)
;(add-hook 'python-mode-hook 'company-mode)

;rubyはauto-completeを使う ruby-mode無効
;(custom-set-variables
; '(company-global-modes '(not ruby-mode)))
;goはauto-completeを使う
;; (custom-set-variables
;; '(company-global-modes '(not go-mode)))

;; tabの設定
(defun company--insert-candidate2 (candidate)
  (when (> (length candidate) 0)
    (setq candidate (substring-no-properties candidate))
    (if (eq (company-call-backend 'ignore-case) 'keep-prefix)
        (insert (company-strip-prefix candidate))
      (if (equal company-prefix candidate)
          (company-select-next)
          (delete-region (- (point) (length company-prefix)) (point))
        (insert candidate))
      )))

(defun company-complete-common2 ()
  (interactive)
  (when (company-manual-begin)
    (if (and (not (cdr company-candidates))
             (equal company-common (car company-candidates)))
        (company-complete-selection)
      (company--insert-candidate2 company-common))))

(define-key company-active-map [tab] 'company-complete-common2)
(define-key company-active-map [backtab] 'company-select-previous) ; おまけ

;;キーバインド設定
(global-set-key (kbd "C-M-i") 'company-complete)
;; C-n, C-pで補完候補を次/前の候補を選択
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)
(define-key company-search-map (kbd "C-n") 'company-select-next)
(define-key company-search-map (kbd "C-p") 'company-select-previous)
;; C-sで絞り込む
(define-key company-active-map (kbd "C-s") 'company-filter-candidates)

;;色をauto-complete風に
(set-face-attribute 'company-tooltip nil
                    :foreground "black" :background "lightgrey")
(set-face-attribute 'company-tooltip-common nil
                    :foreground "black" :background "lightgrey")
(set-face-attribute 'company-tooltip-common-selection nil
                    :foreground "white" :background "steelblue")
(set-face-attribute 'company-tooltip-selection nil
                    :foreground "black" :background "steelblue")
(set-face-attribute 'company-preview-common nil
                    :background nil :foreground "lightgrey" :underline t)
(set-face-attribute 'company-scrollbar-fg nil
                    :background "orange")
(set-face-attribute 'company-scrollbar-bg nil
                    :background "gray40")

(require 'irony)
(require 'yasnippet)
(yas-global-mode)

;;c/c++
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode)) ;;ヘッダファイルをc++-modeに
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(add-to-list 'company-backends 'company-irony) ; backend追加

;; 連想リストの中身を文字列のリストに変更せず、変数そのままの構造を利用。
;; 複数のコンパイルオプションはスペースで区切る
(setq irony-lang-compile-option-alist
      (quote ((c++-mode . "c++ -std=co+11 -lstdc++")
              (c-mode . "c")
              (objc-mode . "objective-c"))))
;; アドバイスによって関数を再定義。
;; split-string によって文字列をスペース区切りでリストに変換

;; ;; (24.3以前 旧アドバイス使用)
(defadvice irony--lang-compile-option (around ad-irony--lang-compile-option activate)
   (defvar irony-lang-compile-option-alist)
   (let ((it (cdr-safe (assq major-mode irony-lang-compile-option-alist))))
     (when it (append '("-x") (split-string it "\s")))))

;; 使い方
;; 初回実行時のみ，
;; M-x irony-install-server RET
;; でirony-serverをインストールする．但し,cmakeが必要
;; irony-serverがインストールされる場所はirony-server-install-prefixで指定できる．
;; あとは適当にprefixを打てばcompanyが補完候補を表示してくれるはず

;; cmakeの設定が終わっていないと面倒 参照:http://qiita.com/alpha22jp/items/90f7f2ad4f8b1fa089f4

;;python company-jedi
(require 'jedi-core)
(setq jedi:complete-on-dot t)
;(setq jedi:use-shortcuts t)
(add-hook 'python-mode-hook 'jedi:setup)
(add-to-list 'company-backends 'company-jedi) ; backendに追加
;; 使い方
;; pip install jedi epc
;; 初回実行時のみ，
;; M-x irony-install-server RET

;;goはgoの設定で行う

;;rubyはrubyの設定で行う

;;;;;;自動補完 company 終わり;;;;;;
