#lang racket

#|

Racket Arcade (r-cade) - a simple game engine

Copyright (c) 2020 by Jeffrey Massung
All rights reserved.

|#

(require ffi/vector)
(require csfml)

;; ----------------------------------------------------

(require "riff.rkt")
(require "voice.rkt")
(require "sound.rkt")
(require "music.rkt")

;; ----------------------------------------------------

(provide (all-defined-out))

;; ----------------------------------------------------

(define channels
  (list (sfSound_create)
        (sfSound_create)
        (sfSound_create)
        (sfSound_create)))

;; ----------------------------------------------------

(define (with-channel thunk)
  (let* ([in-use (λ (channel)
                   (let ([status (sfSound_getStatus channel)])
                     (not (eq? status 'sfStopped))))]
         
         ; find the first, stopped voice available
         [avail-channels (dropf channels in-use)])
    (unless (null? avail-channels)
      (thunk (first avail-channels)))))

;; ----------------------------------------------------

(define (play-sound sound #:volume [volume 100.0] #:pitch [pitch 1.0] #:loop [loop #f])
  (with-channel (λ (channel)
                  (sfSound_setBuffer channel (sound-buffer sound))

                  ; channel settings
                  (sfSound_setVolume channel volume)
                  (sfSound_setPitch channel pitch)
                  (sfSound_setLoop channel loop)

                  ; play it
                  (sfSound_play channel))))

;; ----------------------------------------------------

(define (stop-sound channel)
  (void))

;; ----------------------------------------------------

(define make-tune transcribe-notes)

;; ----------------------------------------------------

(define music
  (let ([pointer (u8vector->cpointer riff-header)]
        [length (u8vector-length riff-header)])
    (sfMusic_createFromMemory pointer length)))

;; ----------------------------------------------------

(define (play-music tune #:volume [volume 100.0] #:pitch [pitch 1.0] #:loop [loop #t])
  (stop-music)

  ; set the new, active music tune
  (set! music (tune-music tune))
  
  ; start playing the new music
  (sfMusic_setVolume music volume)
  (sfMusic_setPitch music pitch)
  (sfMusic_setLoop music loop)
  (sfMusic_play music))

;; ----------------------------------------------------

(define (pause-music [pause #t])
  ((if pause sfMusic_pause sfMusic_play) music))

;; ----------------------------------------------------

(define (stop-music)
  (sfMusic_stop music))
