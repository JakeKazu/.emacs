(provide 'set-brackets)

;;{とうつと}, "とうつと"のように対応する文字を自動入力
(electric-pair-mode t)
(add-to-list 'electric-pair-pairs '(?| . ?|))
(add-to-list 'electric-layout-rules '(?{ . after)) ;{の後に改行を挿入}

;;ファイルのフルパスをタイトルバーに表示
(setq frame-title-format
      (format "%%f - Emacs@%s" (system-name)))


;;括弧の中を強調表示
(setq show-paren-delay 0)
(show-paren-mode t)
(setq show-paren-style 'expression)
(set-face-background 'show-paren-match-face "#4123AA") ;括弧の範囲色

;;深さレベル括弧色分け
; rainbow-delimiters を使うための設定
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
; 括弧の色を強調する設定
(require 'cl-lib)
(require 'color)
(defun rainbow-delimiters-using-stronger-colors ()
  (interactive)
  (cl-loop
   for index from 1 to rainbow-delimiters-max-face-count
   do
   (let ((face (intern (format "rainbow-delimiters-depth-%d-face" index))))
    (cl-callf color-saturate-name (face-foreground face) 30))))
(add-hook 'emacs-startup-hook 'rainbow-delimiters-using-stronger-colors)
