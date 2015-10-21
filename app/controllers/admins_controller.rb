###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AdminsController < AdminController
  inherit_resources
  load_and_authorize_resource

  respond_to :html, except: [:show]

  before_action :build_for_create, only: [:create]

  has_scope :sorted,
            using: [:column, :direction],
            type: :hash,
            default: {
                column: 'admins.email',
                direction: 'asc'
            }
  has_scope :with_email, as: :admin_email

  def index
    @admins = apply_scopes(collection).all
    index!
  end

  def create
    create! do
      admins_path
    end
  end

  def update
    update! { admins_path }
  end

  def batch_delete
    collection.destroy_all(id: params[:admin_ids])
    redirect_to admins_path
  end

  private

  def permitted_params
    {
        admin: params.fetch(:admin, {}).permit(:email, :role)
    }
  end

  def begin_of_association_chain
    current_admin.account
  end

  def resource
    @admin = super.decorate
  end

  def build_for_create
    @admin = build_resource
    @admin.password = @admin.password_confirmation = Devise.friendly_token.first(8)
  end

  def order_direction
    if (order = params[:sorted])
      order[:direction] == 'asc' ? 'asc' : 'desc'
    else
      'asc'
    end
  end

  def collection
    @admins = super.order(email: order_direction)
  end
end
