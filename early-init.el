;; Emacs 28
(when (fboundp 'native-compile-async)
  (setenv "LIBRARY_PATH" 
          (concat (getenv "LIBRARY_PATH") 
                  "/usr/local/opt/gcc/lib/gcc/11:/usr/local/opt/gcc/lib/gcc/11/gcc/x86_64-apple-darwin20/11.2.0"))
  (setq native-comp-speed 2
        native-comp-async-jobs-number 4
        native-comp-deferred-compilation nil
        native-comp-deferred-compilation-deny-list '()))
(setq package-native-compile t)

(tool-bar-mode -1)
(menu-bar-no-scroll-bar)
(menu-bar-mode nil)
(global-font-lock-mode t)
(transient-mark-mode t)

;; Defer garbage collection further back in the startup process
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.5)

;; Increase how much is read from processes in a single chunk (default is 4kb)
(setq read-process-output-max #x10000)  ; 64kb

;; Don't ping things that look like domain names.
(setq ffap-machine-p-known 'reject)

(setq frame-resize-pixelwise t)

;; 默认先最大化。
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)

;; Speed up startup
(setq auto-mode-case-fold nil)  

;; 在Mac平台, Emacs不能进入Mac原生的全屏模式,否则会导致 `make-frame' 创建时也集
;; 成原生全屏属性后造成白屏和左右滑动现象. 所以先设置 `ns-use-native-fullscreen'
;; 和 `ns-use-fullscreen-animation' 禁止Emacs使用Mac原生的全屏模式. 而是采用传统
;; 的全屏模式, 传统的全屏模式, 只会在当前工作区全屏,而不是切换到Mac那种单独的全
;; 屏工作区,这样执行 `make-frame' 先关代码或插件时,就不会因为Mac单独工作区左右滑
;; 动产生的bug.
;;
;; Mac平台下,不能直接使用 `set-frame-parameter' 和 `fullboth' 来设置全屏,那样也
;; 会导致Mac窗口管理器直接把Emacs窗口扔到单独的工作区, 从而对 `make-frame' 产生
;; 同样的Bug. 所以, 启动的时候通过 `set-frame-parameter' 和 `maximized' 先设置
;; Emacs为最大化窗口状态, 启动5秒以后再设置成全屏状态, Mac就不会移动Emacs窗口到
;; 单独的工作区, 最终解决Mac平台下原生全屏窗口导致 `make-frame' 左右滑动闪烁的问
;; 题.
(when (eq system-type 'darwin)
  (setq ns-use-native-fullscreen nil
        ns-use-fullscreen-animation nil))

(add-hook 'after-init-hook #'toggle-frame-fullscreen)
;;(add-hook 'after-init-hook #'toggle-frame-maximized)

(defconst sys/macp
  (eq system-type 'darwin)
  "Are we running on a Mac system?")

(defconst sys/mac-x-p
  (and (display-graphic-p) sys/macp)
  "Are we running under X on a Mac system?")

(defconst sys/mac-ns-p
  (eq window-system 'ns)
  "Are we running on a GNUstep or Macintosh Cocoa display?")

(defconst sys/mac-cocoa-p
  (featurep 'cocoa)
  "Are we running with Cocoa on a Mac system?")

(defconst sys/mac-port-p
  (eq window-system 'mac)
  "Are we running a macport build on a Mac system?")
