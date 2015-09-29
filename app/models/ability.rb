###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Ability
  include CanCan::Ability
  include Ability::ExtensionManageable

  disallow_extension('beacon_manager') { BeaconControl::KontaktIoExtension }

  def initialize(user)
    case user.role
    when 'admin'
      can :manage, Admin, account_id: user.account_id
      can :manage, Application, account_id: user.account_id
      can :manage, ApplicationSetting, application: { account_id: user.account_id }
      can :manage, Zone, account_id: user.account_id
      can :manage, Beacon, account_id: user.account_id
      can :manage, Extension
      can :create, Activity
      can :manage, Activity, trigger: { application: { account_id: user.account_id } }
      can :manage, BeaconConfig
    when 'beacon_manager'
      can [:read, :update], Admin, id: user.id
      can :manage, Zone, manager_id: user.id
      can :manage, Beacon, manager_id: user.id
      can :manage, Extension do |extension|
        !disallowed_extension?(user.role, extension)
      end
    else
    end
  end
end
