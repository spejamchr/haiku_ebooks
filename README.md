haiku_ebooks
===========

Tweet random haikus

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

* `msgpack` for storing the Markov Chains
* `twitter` for tweeting

Install
-------

* Clone the git repo
* Rename `data/keys.example.yml` to `data/keys.yml`
* Put your Twitter keys and access tokens in the new `data/keys.yml` file
* Run `bundle install`

Author
------

Original author: Spencer Christiansen

License
-------

(The MIT License)

Copyright (c) 2018 Spencer Christiansen

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.