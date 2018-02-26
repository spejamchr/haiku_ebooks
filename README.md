haiku_ebooks
===========

Tweet random haikus

[See the result on Twitter](https://twitter.com/EbooksHaiku)

I like Markov Chains, and I like haikus, so this is my attempt at creating a
Twitter bot that tweets Markov-Chain-generated haikus. It's not meant to be
blazing fast, but it should count syllables very accurately.

Examples
--------

Tweet a random haiku:

```bash
cd /path/to/haiku_ebooks/bin
./haiku_ebooks
```

The first time will take longer than normal (~1 minute), because it has to parse
the CMU pronunciation dictionary for word syllable lengths and generate a
persistent Markov Chain. Subsequent runs should only take ~10 seconds.

Requirements
------------

* `ruby` (I'm using `ruby 2.4.2`)
* [`bundler`](http://bundler.io/) for installing:
  * [`msgpack`](https://github.com/msgpack/msgpack-ruby/) for storing the Markov
    Chains
  * [`twitter`](https://github.com/sferik/twitter) for tweeting
* You'll also need to bring your own source texts. Consider using [Project
  Gutenberg](https://www.gutenberg.org/).

Install
-------

* Clone the git repo: `git clone https://github.com/spejamchr/haiku_ebooks.git`
* Run `bundle install`
* Rename `data/keys.example.yml` to `data/keys.yml` and put your Twitter keys
  and access tokens in there
* Put some `.txt` files in the `data/text/` directory. Your Markov Chain will be
  built from them.

Author
------

Original author: Spencer Christiansen
