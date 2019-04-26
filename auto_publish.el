(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)
(package-refresh-contents)
(package-install 'mustache)
(package-install 'htmlize)

(setq load-path (cons  "~/EGO/" load-path))
(require 'log-edit)
(require 'htmlize)
(require 'ego)
(setq ego-project-config-alist
      `(("emacs-document"
         :repository-directory "~/source"
         :site-domain "https://lujun9972.github.io/emacs-document"
         :site-main-title "EMACS-DOCUMENT"
         :site-sub-title "=============>随便,谢谢"
         :repository-org-branch "master"
         :repository-html-branch "gh-pages"
         :theme (default)
         :summary
         (("years" :year :updates 10)
          ("authors" :authors)
          ("tags" :tags))
         :source-browse-url
         ("Github" ,(getenv "REPO"))
         :personal-disqus-shortname "emacs-document"
         :personal-google-analytics-id "7bac4fd0247f69c27887e0d4e3aee41e"
         :ignore-file-name-regexp "README.org"
         :store-dir "~/web")))
(message "BEGIN TO AUTO PUBLIC")
(setq org-export-use-babel nil)
(setq debug-on-error t)
(setq org-src-fontify-natively t)
(ego-do-publication "emacs-document" nil nil nil)
