Name
====

ngx_hawk - A proxy server implementation of the hawk authetication scheme for OpenResty.

Description
===========

Hawk is an HTTP authentication scheme using a message authentication code (MAC) algorithm to provide partial HTTP request cryptographic verification.

This module will proxy HTTP requests to an upstream service after validating a hawk request header.

Status
======

This library is still under active development and is almost production ready.

Currently, payload validation is not implemented.  All public requests should be made over HTTPS.

In addition, there is no plan to support bewit requests (3rd party temporary access).


Installation
============

After installing OpenResty, clone/download this repo and run the command:

```$ sudo make install```

See the conf directory for a sample nginx configuration.

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2015, Dave Pederson (dave.pederson@gmail.com)

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

References
========

* The hawk reference implementation: https://github.com/hueniverse/hawk
* The OpenResty project: http://openresty.org
* The ngx_lua module: http://wiki.nginx.org/HttpLuaModule
* A HMAC module for ngx_lua and LuaJIT: https://github.com/jkeys089/lua-resty-hmac
* PyHawk a python library for hawk HTTP authentication: https://github.com/mozilla/PyHawk
