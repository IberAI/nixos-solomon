{pkgs, ...}: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
  };

  home.file.".emacs.d/init.el".text = ''
    ;;; init.el --- Simple Emacs config -*- lexical-binding: t; -*-

    (setq-default indent-tabs-mode nil)
    (setq-default tab-width 4)

    (setq make-backup-files nil)
    (setq auto-save-default nil)
    (setq create-lockfiles nil)

    (setq inhibit-startup-screen t)
    (setq initial-scratch-message nil)

    (setq initial-buffer-choice
          (lambda ()
            (let ((dev-dir (expand-file-name "~/Development")))
              (dired-noselect
               (if (file-directory-p dev-dir)
                   dev-dir
                 "~")))))

    (load-theme 'modus-vivendi t)

    (menu-bar-mode 1)
    (tool-bar-mode -1)
    (scroll-bar-mode -1)

    (show-paren-mode 1)
    (electric-pair-mode 1)
    (column-number-mode 1)

    (global-display-line-numbers-mode 1)
    (setq display-line-numbers-type 'relative)

    (setq c-default-style "linux")
    (setq c-basic-offset 4)

    (defun solomon/c-like-style ()
      "Apply Solomon's simple C/C++ style."
      (setq c-basic-offset 4)
      (setq indent-tabs-mode nil))

    (add-hook 'c-mode-hook #'solomon/c-like-style)
    (add-hook 'c++-mode-hook #'solomon/c-like-style)

    (dolist (hook '(term-mode-hook
                    vterm-mode-hook
                    shell-mode-hook
                    eshell-mode-hook
                    dired-mode-hook
                    compilation-mode-hook))
      (add-hook hook
                (lambda ()
                  (display-line-numbers-mode 0))))

    (fset 'yes-or-no-p 'y-or-n-p)

    (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
    (when (file-exists-p custom-file)
      (load custom-file))

    ;;; init.el ends here
  '';
}
