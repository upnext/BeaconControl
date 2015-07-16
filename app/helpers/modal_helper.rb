###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module ModalHelper
  def prompt_modal(title, body, partial='shared/delete_modal')
    render partial: partial,
           locals: {
             title: title,
             body:  body
           }
  end
end
