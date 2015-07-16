###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ExtensionAssignmentsController < ApplicationController
  def show
    @extension_assignment = ExtensionAssignment.find(params[:id])
  end

  def edit
    @extension_assignment = ExtensionAssignment.find(params[:id])
  end

  def update
    @extension_assignment = ExtensionAssignment.find(params[:id])
    @extension_assignment.save

    render :show
  end

  private

  def permitted_params
    params.require(:extension_assignment).permit(:username, :password)
  end
end
