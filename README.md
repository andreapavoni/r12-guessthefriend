Guess The Friend - [:game_die: Click here to play](http://i.sindro.me)
======================================================================

This is a complete Rails app developed in 48 hours during the 2012 [Rails Rumble](http://railsrumble.com).

It implements the classic [Guess The Friend](http://player.vimeo.com/video/1193166?title=1&byline=1&portrait=1)
game, picking the choices from your recently contacted Facebook friends, getting their details and giving you
hints :smile:.

Everything is in the RailsRumble aftermath state - so don't expect clean code and full coverage - it is left
here just for posterity :smiley:.

App setup:
----------

* Clone the repo
* Add "127.0.0.1 dev.r12.railsrumble.com" to your /etc/hosts (as root)
* mkdir log/
* bundle
* rails server
* Go to http://dev.r12.railsrumble.com:3000/ - required to work around FB auth strictness

App deploy:
-----------

* Give your SSH key to vjt@openssl.it
* cap deploy
* If you want to deploy another branch, use `cap -S branch=foobar deploy`
