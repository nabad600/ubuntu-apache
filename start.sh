#!/usr/bin/env bash
echo 'Starting Apache';
apache2ctl -D FOREGROUND
# "apache2ctl", "-D", "FOREGROUND"