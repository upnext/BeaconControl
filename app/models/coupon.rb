###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Coupon < ActiveRecord::Base
  TEMPLATE_FIELDS = {
    template_1: %w[logo image],
    template_2: %w[image],
    template_3: %w[logo image encoding_type unique_identifier_number identifier_number],
    template_4: %w[image encoding_type unique_identifier_number identifier_number],
    template_5: %w[logo image button_font_color button_background_color button_label button_link]
  }

  TEMPLATES = TEMPLATE_FIELDS.keys.map(&:to_s)

  enum encoding_type: { qr_code: 0, code_128: 1 }

  belongs_to :activity

  has_one :logo,  ->{ where(type: "logo") },  class_name: "CouponImage", dependent: :destroy
  has_one :image, ->{ where(type: "image") }, class_name: "CouponImage", dependent: :destroy

  accepts_nested_attributes_for :logo,  allow_destroy: true,
    reject_if: ->(params) { params[:file].blank? && params[:file_cache].blank? && params[:remove_file].blank? }
  accepts_nested_attributes_for :image, allow_destroy: true,
    reject_if: ->(params) { params[:file].blank? && params[:file_cache].blank? && params[:remove_file].blank? }

  validates :template, inclusion: { in: TEMPLATES }

  validates :name, length: { maximum: 12 }
  validates :title, length: { maximum: 50 }

  with_options if: :with_barcode? do |model|
    model.validates :unique_identifier_number, presence: true, uniqueness: true
    model.validates :identifier_number,        presence: true
  end

  with_options if: :with_button? do |model|
    model.validates :button_font_color,       presence: true
    model.validates :button_background_color, presence: true
    model.validates :button_label,            presence: true, length: { maximum: 30 }
    model.validates :button_link,             presence: true
  end

  after_initialize :build_files

  def barcode(options = {})
    Coupon::Code.new(self).to_image(options)
  end

  def with_button?
    %w[template_5].include?(template)
  end

  def with_barcode?
    %w[template_3 template_4].include?(template)
  end

  private

  def build_files
    build_logo  if logo.nil?
    build_image if image.nil?
  end
end
