;;; gitmoji.el --- Add a gitmoji selector to your commits.  -*- lexical-binding: t; -*-

;; Author: Tiv0w <https:/github.com/Tiv0w>
;; URL: https://github.com/Tiv0w/gitmoji-commit.git
;; Version: 0.1.1
;; Package-Requires: ((emacs "24.1") (ivy ""))
;; Keywords: emoji, git, gitmoji, commit

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package is intended to help people with adding gitmojis to their
;; commits when commiting through Emacs.

;; To load this file, add `(require 'gitmoji)' to your init file.
;;
;; To use it, simply use `M-x gitmoji-commit-mode' and you will be
;; prompted to choose a gitmoji when using git-commit.
;;
;; You could also want to insert a gitmoji in current buffer,
;; for that you would `M-x gitmoji-insert' and voilà!

;;; Code:

(defvar gitmojis-list
  '(("Improve structure / format of the code." ":art:" #x1F3A8)
    ("Improve performance." ":zap:" #x26A1)
    ("Remove code or files." ":fire:" #x1F525)
    ("Fix a bug." ":bug:" #x1F41B)
    ("Critical hotfix." ":ambulance:" #x1F691)
    ("Introduce new features." ":sparkles:" #x2728)
    ("Add or update documentation." ":memo:" #x1F4DD)
    ("Deploy stuff." ":rocket:" #x1F680)
    ("Add or update the UI and style files." ":lipstick:" #x1F484)
    ("Begin a project." ":tada:" #x1F389)
    ("Add or update tests." ":white_check_mark:" #x2705)
    ("Fix security issues." ":lock:" #x1F512)
    ("Release / Version tags." ":bookmark:" #x1F516)
    ("Fix compiler / linter warnings." ":rotating_light:" #x1F6A8)
    ("Work in progress." ":construction:" #x1F6A7)
    ("Fix CI Build." ":green_heart:" #x1F49A)
    ("Downgrade dependencies." ":arrow_down:" #x2B07)
    ("Upgrade dependencies." ":arrow_up:" #x2B06)
    ("Pin dependencies to specific versions." ":pushpin:" #x1F4CC)
    ("Add or update CI build system." ":construction_worker:" #x1F477)
    ("Add or update analytics or track code." ":chart_with_upwards_trend:" #x1F4C8)
    ("Refactor code." ":recycle:" #x267B)
    ("Add a dependency." ":heavy_plus_sign:" #x2795)
    ("Remove a dependency." ":heavy_minus_sign:" #x2796)
    ("Add or update configuration files." ":wrench:" #x1F527)
    ("Add or update development scripts." ":hammer:" #x1F528)
    ("Internationalization and localization." ":globe_with_meridians:" #x1F310)
    ("Fix typos." ":pencil2:" #x270F)
    ("Write bad code that needs to be improved." ":poop:" #x1F4A9)
    ("Revert changes." ":rewind:" #x23EA)
    ("Merge branches." ":twisted_rightwards_arrows:" #x1F500)
    ("Add or update compiled files or packages." ":package:" #x1F4E6)
    ("Update code due to external API changes." ":alien:" #x1F47D)
    ("Move or rename resources (e.g.: files, paths, routes)." ":truck:" #x1F69A)
    ("Add or update license." ":page_facing_up:" #x1F4C4)
    ("Introduce breaking changes." ":boom:" #x1F4A5)
    ("Add or update assets." ":bento:" #x1F371)
    ("Improve accessibility." ":wheelchair:" #x267F)
    ("Add or update comments in source code." ":bulb:" #x1F4A1)
    ("Write code drunkenly." ":beers:" #x1F37B)
    ("Add or update text and literals." ":speech_balloon:" #x1F4AC)
    ("Perform database related changes." ":card_file_box:" #x1F5C3)
    ("Add or update logs." ":loud_sound:" #x1F50A)
    ("Remove logs." ":mute:" #x1F507)
    ("Add or update contributor(s)." ":busts_in_silhouette:" #x1F465)
    ("Improve user experience / usability." ":children_crossing:" #x1F6B8)
    ("Make architectural changes." ":building_construction:" #x1F3D7)
    ("Work on responsive design." ":iphone:" #x1F4F1)
    ("Mock things." ":clown_face:" #x1F921)
    ("Add or update an easter egg." ":egg:" #x1F95A)
    ("Add or update a .gitignore file." ":see_no_evil:" #x1F648)
    ("Add or update snapshots." ":camera_flash:" #x1F4F8)
    ("Perform experiments." ":alembic:" #x2697)
    ("Improve SEO." ":mag:" #x1F50D)
    ("Add or update types." ":label:" #x1F3F7)
    ("Add or update seed files." ":seedling:" #x1F331)
    ("Add, update, or remove feature flags." ":triangular_flag_on_post:" #x1F6A9)
    ("Catch errors." ":goal_net:" #x1F945)
    ("Add or update animations and transitions." ":dizzy:" #x1F4AB)
    ("Deprecate code that needs to be cleaned up." ":wastebasket:" #x1F5D1)
    ("Work on code related to authorization, roles and permissions." ":passport_control:" #x1F6C2)
    ("Simple fix for a non-critical issue." ":adhesive_bandage:" #x1FA79)
    ("Data exploration/inspection." ":monocle_face:" #x1F9D0)))

(defcustom gitmoji--insert-utf8-emoji nil
  "When t, inserts the utf8 emoji character instead of the github-style representation.
Example: ⚡ instead of :zap:.
Default: nil."
  :type 'boolean
  :group 'gitmoji)

(defcustom gitmoji--display-utf8-emoji nil
  "When t, displays the utf8 emoji character in the gitmoji choice list.
Default: nil."
  :type 'boolean
  :group 'gitmoji)

;;;###autoload
(defun gitmoji-set-selection-backend (backend)
  "Set the backend for selecting emojis.

BACKEND is a valid backend name, see `gitmoji-selection-backend"
  (setq-default gitmoji-selection-backend backend))

(defcustom gitmoji-selection-backend
  '(helm ivy consult)
  "The backend for the selection of emojis.

These can have one of the following values

`helm'  - Use Helm
`ivy'   - Use Ivy
`consult'   - Use Consult"
  :type '(set
          (const :tag "Helm" helm)
          (const :tag "Consult" consult)
          (const :tag "Ivy" ivy))
  :set (lambda (_ value) (gitmoji-set-selection-backend value))
  :group 'gitmoji)

(defun gitmoji-insert--candidates ()
  (mapcar (lambda (x)
            (let ((description (car x))
                  (shortcode (cadr x))
                  (utf8 (caddr x)))
              (cons
               (concat
                (when gitmoji--display-utf8-emoji
                  (concat (string utf8) " - "))
                shortcode
                " — "
                description)
               x)))
          gitmojis-list))

(defun gitmoji-insert--action (x)
  (let ((utf8 (cadddr x))
        (shortcode (caddr x)))
    (if gitmoji--insert-utf8-emoji
        (insert-char utf8)
      (insert shortcode)))
  (insert " "))

(defun gitmoji-insert-ivy ()
  "Choose a gitmoji with ivy and insert it in the current buffer."
  (interactive)
  (let ((candidates (gitmoji-insert--candidates)))
    (ivy-read
     "Choose a gitmoji: "
     candidates
     :action #'gitmoji-insert--action
     )))

(defun gitmoji-insert-helm ()
  "Choose a gitmoji with helm and insert it in the current buffer."
  (interactive)
  (helm :sources `((name . "Choose a gitmoji:")
                    (candidates . ,(gitmoji-insert--candidates))
                    (action . (lambda (candidate) (gitmoji-insert--action (append '(" ") candidate)))))))

(defun gitmoji-insert-consult ()
  "Choose a gitmoji with consult and insert it in the current buffer."
  (interactive)
  (let* ((candidates (gitmoji-insert--candidates))
         (candidate (assoc (completing-read "Choose a gitmoji: " candidates) candidates)))
    (gitmoji-insert--action candidate)))

(defun gitmoji-insert ()
  (cond
   ((memql 'ivy gitmoji-selection-backend) (gitmoji-insert-ivy))
   ((memql 'helm gitmoji-selection-backend) (gitmoji-insert-helm))
   ((memql 'consult gitmoji-selection-backend) (gitmoji-insert-consult))
   (t (warn "No valid backend selected for Gitmoji."))
   ))

;;;###autoload
(define-minor-mode gitmoji-commit-mode
  "Toggle gitmoji-commit mode. This is a global setting."
  :global t
  :init-value nil
  :lighter " Gitmoji"
  (if gitmoji-commit-mode
      (add-hook 'git-commit-mode-hook 'gitmoji-insert)
    (remove-hook 'git-commit-mode-hook 'gitmoji-insert)))

(provide 'gitmoji)
