###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

brand_factory = Brand::Factory.new(name: "Beacon OS")
brand = brand_factory.create

email = ENV['SEED_ADMIN_EMAIL'] || 'admin@example.com'
password  = ENV['SEED_ADMIN_PASSWORD'] || 'test123'

admin_factory = Admin::Factory.new(
  email:                 email,
  password:              password,
  password_confirmation: password,
)
admin = admin_factory.create!
account = admin.account

puts 'Creating sample beacons...'
Beacon.first_or_create(
  [
    { uuid: SecureRandom.uuid, major: 1, minor: 2, account_id: account.id, name: 'Sample beacon 1', floor: nil },
    { uuid: SecureRandom.uuid, major: 1, minor: 2, account_id: account.id, name: 'Sample beacon 2', floor: 1 },
    { uuid: SecureRandom.uuid, major: 1, minor: 2, account_id: account.id, name: 'Sample beacon 3', floor: 2 },
  ]
)
puts 'Sample beacons created.'

puts 'Creating sample zones...'
Zone.first_or_create(
  [
    { account_id: account.id, name: 'test zone 1' },
    { account_id: account.id, name: 'test zone 2' },
    { account_id: account.id, name: 'test zone 2' }
  ]
)
Zone.find_by(name: 'test zone 2').beacons << Beacon.find_by(name: 'Sample beacon 3')
puts 'Sample zones created.'

puts "Admin credentials: email: #{email}, password: #{password}"

if application = admin.applications.first
  puts "API App credentials:"
  puts "UID:    #{application.doorkeeper_application.uid}"
  puts "Secret: #{application.doorkeeper_application.secret}"
end

puts "S2S API App credentials:"
puts "UID:    #{brand.doorkeeper_application.uid}"
puts "Secret: #{brand.doorkeeper_application.secret}"
