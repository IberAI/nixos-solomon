{pkgs, ...}: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
  };

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  home.file.".emacs.d/init.el".text = ''
    ;;; init.el --- Simple Emacs config -*- lexical-binding: t; -*-

    ;; Basics
    (setq inhibit-startup-screen t)
    (setq initial-scratch-message nil)

    (setq make-backup-files nil)
    (setq auto-save-default nil)
    (setq create-lockfiles nil)

    (fset 'yes-or-no-p 'y-or-n-p)

    ;; Indentation
    (setq-default indent-tabs-mode nil)
    (setq-default tab-width 4)

    ;; Keep the good Enter auto-indent behavior.
    (electric-indent-mode 1)

    ;; Auto-pair brackets, quotes, etc.
    (electric-pair-mode 1)

    ;; Normal modern editing behavior.
    (delete-selection-mode 1)

    ;; Stop visual jumping / bubbling around the cursor.
    (setq scroll-margin 0)
    (setq scroll-conservatively 0)
    (setq scroll-step 1)
    (setq auto-window-vscroll nil)

    ;; Font
    (set-face-attribute 'default nil
                        :family "JetBrainsMono Nerd Font"
                        :height 150
                        :weight 'regular)

    ;; Theme / UI
    (load-theme 'modus-vivendi t)

    (menu-bar-mode 1)
    (tool-bar-mode -1)
    (scroll-bar-mode -1)

    (show-paren-mode 1)
    (column-number-mode 1)

    ;; Line numbers
    (global-display-line-numbers-mode 1)
    (setq display-line-numbers-type 'relative)

    ;; Prevent line-number column resizing.
    (setq display-line-numbers-width 4)

    ;; This can make the current line look weird in some GTK/VM setups.
    (global-hl-line-mode -1)

    ;; Prevent long lines from visually wrapping and moving other lines.
    (setq-default truncate-lines t)

    ;; Better cursor for coding.
    (setq-default cursor-type 'bar)

    ;; Startup buffer
    (setq initial-buffer-choice
          (lambda ()
            (let ((dev-dir (expand-file-name "~/Development")))
              (dired-noselect
               (if (file-directory-p dev-dir)
                   dev-dir
                 "~")))))

    ;; C / C++
    (setq c-default-style "linux")
    (setq c-basic-offset 4)

    (defun solomon/c-like-style ()
      "Apply Solomon's simple C/C++ style."
      (setq c-basic-offset 4)
      (setq indent-tabs-mode nil)
      (electric-indent-local-mode 1))

    (add-hook 'c-mode-hook #'solomon/c-like-style)
    (add-hook 'c++-mode-hook #'solomon/c-like-style)

    ;; Disable line numbers in special buffers.
    (dolist (hook '(term-mode-hook
                    vterm-mode-hook
                    shell-mode-hook
                    eshell-mode-hook
                    dired-mode-hook
                    compilation-mode-hook))
      (add-hook hook
                (lambda ()
                  (display-line-numbers-mode 0))))

    ;; Custom file
    (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
    (when (file-exists-p custom-file)
      (load custom-file))

    ;;; init.el ends here
  '';
}
