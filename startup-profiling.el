;;; startup-profiling.el --- Emacs startup profiling and optimization

;; Startup profiling
(add-hook 'emacs-startup-hook
  (lambda ()
    (message "Emacs ready in %s with %d garbage collections."
             (format "%.2f seconds"
                     (float-time
                      (time-subtract after-init-time before-init-time)))
             gcs-done)))

;; Optimize garbage collection during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Restore normal GC settings after startup
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq gc-cons-threshold 100000000
          gc-cons-percentage 0.1)))

(provide 'startup-profiling)
;;; startup-profiling.el ends here