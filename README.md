# ruby-runner

A docker image for running ruby projects

## Usage

ruby-runner provides `supervisor` for executing processes. If you're using a
Procfile, `/usr/local/bin/proc2super` will convert it to supervisor format.

The build process runs as a user `builder` with sudo rights.

Also, a non-privileged user `app` has been created for running the process.

An example Dockerfile is as follows:

```
FROM peer60/ruby-runner

ADD . /app
WORKDIR /app
RUN sudo chown -R app:app /app
USER app

RUN bundle install --binstubs=vendor/bundle/bin --path=vendor/bundle --without development test
RUN rake assets:precompile
RUN proc2super < /app/Procfile > /app/supervisord.conf
CMD supervisord -c supervisord.conf
```

Start it with

```
docker run username/myapp -p 5000:5000
```

And hit your browser at `localhost:5000`


## License - BSD

Copyright (c) 2014, peer60
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
DAMAGE.
