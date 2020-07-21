;;; gitmoji.el --- Add a gitmoji selector to your commits.  -*- lexical-binding: t; -*-

;; Author: Tiv0w <https:/github.com/Tiv0w>
;; URL: https://github.com/Tiv0w/gitmoji-commit.git
;; Version: 0.0.2
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
  '(("Improving structure / format of the code."  ":art:"  #x1f3a8)
    ("Improving performance." ":zap:" #x26A1)
    ("Removing code or files." ":fire:" #x1F525)
    ("Fixing a bug." ":bug:" #x1F41B)
    ("Critical hotfix." ":ambulance:" #x1F691)
    ("Introducing new features." ":sparkles:" #x2728)
    ("Writing docs." ":memo:" #x1F4DD)
    ("Deploying stuff." ":rocket:" #x1F680)
    ("Updating the UI and style files." ":lipstick:" #x1F484)
    ("Initial commit." ":tada:" #x1F389)
    ("Updating tests." ":white_check_mark:" #x2705)
    ("Fixing security issues." ":lock:" #x1F512)
    ("Fixing something on macOS." ":apple:" #x1F34E)
    ("Fixing something on Linux." ":penguin:" #x1F427)
    ("Fixing something on Windows." ":checkered_flag:" #x1F3C1)
    ("Fixing something on Android." ":robot:" #x1F916)
    ("Fixing something on iOS." ":green_apple:" #x1F34F)
    ("Releasing / Version tags." ":bookmark:" #x1F516)
    ("Removing linter warnings." ":rotating_light:" #x1F6A8)
    ("Work in progress." ":construction:" #x1F6A7)
    ("Fixing CI Build." ":green_heart:" #x1F49A)
    ("Downgrading dependencies." ":arrow_down:" #x2B07)
    ("Upgrading dependencies." ":arrow_up:" #x2B06)
    ("Pinning dependencies to specific versions." ":pushpin:" #x1F4CC)
    ("Adding CI build system." ":construction_worker:" #x1F477)
    ("Adding analytics or tracking code." ":chart_with_upwards_trend:" #x1F4C8)
    ("Refactoring code." ":recycle:" #x267B)
    ("Work about Docker." ":whale:" #x1F433)
    ("Adding a dependency." ":heavy_plus_sign:" #x2795)
    ("Removing a dependency." ":heavy_minus_sign:" #x2796)
    ("Changing configuration files." ":wrench:" #x1F527)
    ("Internationalization and localization." ":globe_with_meridians:" #x1F310)
    ("Fixing typos." ":pencil2:" #x270F)
    ("Writing bad code that needs to be improved." ":hankey:" #x1F4A9)
    ("Reverting changes." ":rewind:" #x23EA)
    ("Merging branches." ":twisted_rightwards_arrows:" #x1F500)
    ("Updating compiled files or packages." ":package:" #x1F4E6)
    ("Updating code due to external API changes." ":alien:" #x1F47D)
    ("Moving or renaming files." ":truck:" #x1F69A)
    ("Adding or updating license." ":page_facing_up:" #x1F4C4)
    ("Introducing breaking changes." ":boom:" #x1F4A5)
    ("Adding or updating assets." ":bento:" #x1F371)
    ("Updating code due to code review changes." ":ok_hand:" #x1F44C)
    ("Improving accessibility." ":wheelchair:" #x267F)
    ("Documenting source code." ":bulb:" #x1F4A1)
    ("Writing code drunkenly." ":beers:" #x1F37B)
    ("Updating text and literals." ":speech_balloon:" #x1F4AC)
    ("Performing database related changes." ":card_file_box:" #x1F5C3)
    ("Adding logs." ":loud_sound:" #x1F50A)
    ("Removing logs." ":mute:" #x1F507)
    ("Adding contributor(s)." ":busts_in_silhouette:" #x1F465)
    ("Improving user experience / usability." ":children_crossing:" #x1F6B8)
    ("Making architectural changes." ":building_construction:" #x1F3D7)
    ("Working on responsive design." ":iphone:" #x1F4F1)
    ("Mocking things." ":clown_face:" #x1F921)
    ("Adding an easter egg." ":egg:" #x1F95A)
    ("Adding or updating a .gitignore file" ":see_no_evil:" #x1F648)
    ("Adding or updating snapshots" ":camera_flash:" #x1F4F8)
    ("Experimenting new things" ":alembic:" #x2697)
    ("Improving SEO" ":mag:" #x1F50D)
    ("Work about Kubernetes" ":wheel_of_dharma:" #x2638)
    ("Adding or updating types (Flow, TypeScript)" ":label:" #x1F3F7)
    ("Adding or updating seed files" ":seedling:" #x1F331)
    ("Adding, updating, or removing feature flags" ":triangular_flag_on_post:" #x1F6A9)
    ("Adding or updating animations and transitions" ":dizzy:" #x1F4AB)))

(defvar gitmoji--insert-utf8-emoji nil
  "When t, inserts the utf8 emoji character instead of the github-style representation.
Example: ⚡ instead of :zap:.
Default: nil.")

(defvar gitmoji--display-utf8-emoji nil
  "When t, displays the utf8 emoji character in the gitmoji choice list.
Default: nil.")

(defun gitmoji-insert ()
  "Choose a gitmoji and insert it in the current buffer."
  (interactive)
  (ivy-read "Choose a gitmoji: "
            (mapcar (lambda (x)
                      (cons
                       (concat
                        (when gitmoji--display-utf8-emoji
                          (concat (string (caddr x)) " - "))
                        (cadr x)
                        " — "
                        (car x))
                       x))
                    gitmojis-list)
            :action (lambda (x)
                      (if gitmoji--insert-utf8-emoji
                          (insert-char (caddr (cdr x)))
                        (insert (cadr (cdr x))))
                      (insert " "))))

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
