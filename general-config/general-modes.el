;; Dired

;; Open file(s) in external application
(defun my/dired-open-in-external-application (&optional file)
  "Open the current file or dired marked files in external application(s). The application is chosen from the OS's preference."
  (interactive)
  (let (doIt
        (myFileList
         (cond
          ((string-equal major-mode "dired-mode") (dired-get-marked-files))
          ((not file) (list (buffer-file-name)))
          (file (list file)))))

    (setq doIt (if (<= (length myFileList) 5)
                   t
                 (y-or-n-p "Open more than 5 files? ")))

    (when doIt
      (cond
       ((string-equal system-type "windows-nt")
        (mapc (lambda (fPath) (w32-shell-execute "open" (replace-regexp-in-string "/" "\\" fPath t t))) myFileList))
       ((string-equal system-type "darwin")
        (mapc (lambda (fPath) (shell-command (format "open \"%s\"" fPath)))  myFileList))
       ((string-equal system-type "gnu/linux")
        (mapc (lambda (fPath) (let ((process-connection-type nil)) (start-process "" nil "xdg-open" fPath))) myFileList))))))

;; Copy full file path and filename to the kill ring
(defun my/dired-copy-path-and-filename-as-kill ()
  "Push the path and filename of the file under point to the kill ring."
  (interactive)
  (message "added %s to kill ring" (kill-new (dired-get-filename))))

;; Advise quit-window (q) to kill buffer instead of bury
(defadvice quit-window (before quit-window-always-kill)
  "When running `quit-window', always kill the buffer."
  (ad-set-arg 0 t))
(ad-activate 'quit-window)

;; Doc-view mode

;; Doesn't currently work; trouble with M-x toggle-debug-on-error
;; http://emacs.stackexchange.com/questions/7540/doc-view-mode-hook
;; (add-hook 'doc-view-mode-hook 'doc-view-fit-width-to-window)

;; Ediff mode

(custom-set-variables
 ;; Puts buffers side by side
 '(ediff-split-window-function (quote split-window-horizontally))
 ;; Added ediff control buffer at bottom; activate with ?
 '(ediff-window-setup-function (quote ediff-setup-windows-plain)))

;; Calc mode

;; Disable multiplication having precedence over division
(setq calc-multiplication-has-precedence nil)

;; eshell mode

(setq eshell-prompt-function
      (lambda ()
        (concat
         (propertize "┌─[" 'face `(:foreground "black"))
         (propertize (user-login-name) 'face `(:foreground "red"))
         (propertize "@" 'face `(:foreground "black"))
         (propertize (system-name) 'face `(:foreground "blue"))
         (propertize "]──[" 'face `(:foreground "black"))
         (propertize (format-time-string "%H:%M" (current-time)) 'face `(:foreground "red"))
         (propertize "]──[" 'face `(:foreground "black"))
         (propertize (concat (eshell/pwd)) 'face `(:foreground "blue"))
         (propertize "]\n" 'face `(:foreground "black"))
         (propertize "└─>" 'face `(:foreground "black"))
         (propertize (if (= (user-uid) 0) " # " " $ ") 'face `(:foreground "black")))))
