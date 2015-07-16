###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class String
  def red;    "\033[31m#{self}\033[0m" end
  def green;  "\033[32m#{self}\033[0m" end
end
