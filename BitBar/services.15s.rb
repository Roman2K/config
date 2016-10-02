#!/usr/bin/env ruby

$:.unshift __dir__ + "/lib"

require 'services_status'

ServicesStatus.print %[
  tmux-status-server
]
