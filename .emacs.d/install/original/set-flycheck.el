(provide 'set-flycheck)

(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)
(global-flycheck-mode)

;;キーバインド
(define-key global-map (kbd "\C-cn") 'flycheck-next-error)
(define-key global-map (kbd "\C-cp") 'flycheck-previous-error)
(define-key global-map (kbd "\C-cd") 'flycheck-list-errors)

;;エラー文を文字の下に表示する flycheck-pos-tip
(require 'flycheck-pos-tip)
(eval-after-load 'flycheck
  '(custom-set-variables
   '(flycheck-display-errors-function #'flycheck-pos-tip-error-messages)))

;;c
(flycheck-define-checker c/c++
  "A C/C++ checker using g++."
  :command ("g++" "-Wall" "-Wextra" source)
  :error-patterns  ((error line-start
                           (file-name) ":" line ":" column ":" " エラー: " (message)
                           line-end)
                    (warning line-start
                           (file-name) ":" line ":" column ":" " 警告: " (message)
                           line-end))
  :modes (c-mode c++-mode))

;; ;;c++ flycheck-irony
;; (eval-after-load "flycheck"
;;   '(progn
;;      (when (locate-library "flycheck-irony")
;;        (flycheck-irony-setup))))

;;sudo gem install rubocop ruby-lint
;;ruby rubocop
(require 'rubocop)
(add-hook 'ruby-mode-hook 'rubocop-mode)
(flycheck-define-checker ruby-rubocop
  "A Ruby syntax and style checker using the RuboCop tool."
  :command ("rubocop" "--format" "emacs" "--silent"
            (config-file "--config" flycheck-rubocoprc)
            source)
  :error-patterns
  ((warning line-start
            (file-name) ":" line ":" column ": " (or "C" "W") ": " (message)
            line-end)
   (error line-start
          (file-name) ":" line ":" column ": " (or "E" "F") ": " (message)
          line-end))
  :modes (enh-ruby-mode motion-mode))

