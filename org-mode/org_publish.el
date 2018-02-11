;;; package --- Summary
;;; Commentary:
;;; Code:
(defconst home (file-name-directory (or load-file-name buffer-file-name)))

(require 'org-publish)
(setq org-publish-project-alist
      `(
        ;; add all the components here
        ;; *notes* - publishes org files to html
        ("main-page"
         :base-directory ,(concat home "org/")
         :base-extension "org"  ; Filename suffix without dot
         :publishing-directory ,(concat home "html/")
         :recursive t           ; DONT include subdirectories
         :publishing-function org-publish-org-to-html
         :headline-levels 4             ; Just the default for this project.
         :style "<link rel=\"stylesheet\" type=\"text/css\" href=\"../css/stylesheet.css\" />"
         :auto-preamble t
         :auto-sitemap t                ; generate automagically
         :sitemap-sort-folders last
         :sitemap-title "Main Sitemap"
         )

        ;; The meeting notes to be published
        ("meeting-notes"
         :base-directory ,(concat home "org/meeting-notes/")
         :base-extension "org"
         :publishing-directory ,(concat home "html/meeting-notes/")
         :recursive nil
         :publishing-function org-publish-org-to-html
         :headline-levels 4
         :style "<link rel=\"stylesheet\" type=\"text/css\" href=\"../../css/stylesheet.css\" />"
         :auto-preamble t
         :auto-sitemap t
         :sitemap-title "Meeting Notes Directory"
         )

        ;; *static* - copies files to directories
        ("org-static"
         :base-directory ,(concat home "org/")
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
         :publishing-directory ,(concat home "html/")
         :recursive t
         :publishing-function org-publish-attachment
         )

        ;; *publish* with M-x org-publish-project RET emacsclub RET
        ("emacsclub" :components ("main-page" "meeting-notes" "org-static"))
))
(provide 'org_publish)
;;; org_publish.el ends here
